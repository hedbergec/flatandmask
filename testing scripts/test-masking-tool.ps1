[CmdletBinding()]
param(
    [string]$SecretKey = "testkey123",
    [string]$OutputRoot,
    [int]$MaxCsvRows = 250,
    [string[]]$ScenarioName,
    [switch]$ListScenarios,
    [switch]$SkipReplicationTests,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path -Parent $scriptRoot
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $repoRoot "test_output\regression"
}

function Normalize-FieldName {
    param([string]$FieldPath)
    if ($FieldPath.StartsWith("root.")) {
        return $FieldPath.Substring(5)
    }
    return $FieldPath
}

function New-OrdinalHashtable {
    return [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
}

function Should-MaskField {
    param(
        [string]$FieldPath,
        [string[]]$MaskFields
    )

    $normalized = Normalize-FieldName $FieldPath
    foreach ($maskField in $MaskFields) {
        if ($normalized -ceq (Normalize-FieldName $maskField)) {
            return $true
        }
    }
    return $false
}

function Get-MaskedValue {
    param(
        [AllowNull()]$Value,
        [string]$Key
    )

    if ([string]::IsNullOrEmpty([string]$Value)) {
        return [string]$Value
    }

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($Key)
    $bytes = [Text.Encoding]::UTF8.GetBytes([string]$Value)
    $hash = $hmac.ComputeHash($bytes)
    return ConvertTo-ExcelSafeMaskedValue ([Convert]::ToBase64String($hash).Substring(0, 12))
}

function ConvertTo-ExcelSafeMaskedValue {
    param($Value)

    if ($null -eq $Value) { return $null }
    return "x$Value"
}

function New-MaskingState {
    return @{
        Mapping         = New-OrdinalHashtable
        MappingWithRows = New-Object System.Collections.Generic.List[object]
        Tables          = New-OrdinalHashtable
        TableCounters   = New-OrdinalHashtable
    }
}

function Get-NextSyntheticId {
    param(
        [hashtable]$State,
        [string]$TableName
    )

    if (-not $State.TableCounters.ContainsKey($TableName)) {
        $State.TableCounters[$TableName] = 0
    }

    $State.TableCounters[$TableName]++
    return ConvertTo-ExcelSafeMaskedValue ("{0}-{1:d4}" -f $TableName.Replace("root_", "").Replace("_", "-"), $State.TableCounters[$TableName])
}

function Add-MaskingKeyEntry {
    param(
        [hashtable]$State,
        [string]$Original,
        [string]$Masked,
        [string]$Field,
        [AllowNull()]$RowIndex
    )

    $State.MappingWithRows.Add([PSCustomObject]@{
        Original = $Original
        Masked   = $Masked
        Field    = $Field
        RowIndex = $RowIndex
    })
}

function Mask-IfNeeded {
    param(
        [hashtable]$State,
        [string]$FieldName,
        [AllowNull()]$Value,
        [AllowNull()]$RowIndex,
        [string]$SecretKey,
        [string[]]$MaskFields
    )

    if (-not (Should-MaskField -FieldPath $FieldName -MaskFields $MaskFields)) {
        return $Value
    }

    $stringValue = [string]$Value
    if ([string]::IsNullOrEmpty($stringValue)) {
        return $Value
    }

    $normalizedField = Normalize-FieldName $FieldName
    if (-not $State.Mapping.ContainsKey($stringValue)) {
        $State.Mapping[$stringValue] = @{
            Masked = Get-MaskedValue -Value $stringValue -Key $SecretKey
            Field  = $normalizedField
        }
    }

    Add-MaskingKeyEntry -State $State -Original $stringValue -Masked $State.Mapping[$stringValue].Masked -Field $normalizedField -RowIndex $RowIndex
    return $State.Mapping[$stringValue].Masked
}

function Apply-Masking-ToObject {
    param(
        [hashtable]$State,
        [AllowNull()]$Object,
        [string]$Prefix = "root",
        [AllowNull()]$RowIndex,
        [string]$SecretKey,
        [string[]]$MaskFields
    )

    if ($null -eq $Object) {
        return $null
    }

    if ($Object -is [PSCustomObject]) {
        $maskedObject = [PSCustomObject]@{}
        $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }

        foreach ($property in $properties) {
            $name = $property.Name
            $value = $property.Value
            $fieldPath = "$Prefix.$name"

            if ($value -is [PSCustomObject]) {
                $maskedValue = Apply-Masking-ToObject -State $State -Object $value -Prefix $fieldPath -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
            }
            elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
                $maskedItems = @()
                foreach ($item in $value) {
                    if ($item -is [PSCustomObject]) {
                        $maskedItems += Apply-Masking-ToObject -State $State -Object $item -Prefix $fieldPath -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
                    }
                    else {
                        $maskedItems += Mask-IfNeeded -State $State -FieldName $fieldPath -Value $item -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
                    }
                }
                $maskedValue = @($maskedItems)
            }
            else {
                $maskedValue = Mask-IfNeeded -State $State -FieldName $fieldPath -Value $value -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
            }

            $maskedObject | Add-Member -NotePropertyName $name -NotePropertyValue $maskedValue
        }

        return $maskedObject
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $result = @()
        foreach ($item in $Object) {
            $result += Apply-Masking-ToObject -State $State -Object $item -Prefix $Prefix -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
        }
        return $result
    }

    return Mask-IfNeeded -State $State -FieldName $Prefix -Value $Object -RowIndex $RowIndex -SecretKey $SecretKey -MaskFields $MaskFields
}

function Get-TableNameFromPath {
    param([string]$Path)
    $parts = $Path -split "_"
    return $parts[-1]
}

function Process-ObjectToTables {
    param(
        [hashtable]$State,
        [AllowNull()]$Object,
        [string]$TableName = "root",
        [hashtable]$IdMap = @{}
    )

    if ($null -eq $Object) {
        return
    }

    $tableSuffix = Get-TableNameFromPath -Path $TableName
    $currentIdKey = "${tableSuffix}_id"
    $currentId = Get-NextSyntheticId -State $State -TableName $TableName

    $row = [ordered]@{}
    foreach ($parentKey in ($IdMap.Keys | Sort-Object)) {
        $row[$parentKey] = $IdMap[$parentKey]
    }
    $row[$currentIdKey] = $currentId

    $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
    foreach ($property in $properties) {
        $name = $property.Name
        $value = $property.Value

        if ($value -is [PSCustomObject]) {
            $childIdMap = $IdMap.Clone()
            $childIdMap[$currentIdKey] = $currentId
            Process-ObjectToTables -State $State -Object $value -TableName "${TableName}_$name" -IdMap $childIdMap
            continue
        }

        if ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
            foreach ($item in $value) {
                if ($item -is [PSCustomObject]) {
                    $childIdMap = $IdMap.Clone()
                    $childIdMap[$currentIdKey] = $currentId
                    Process-ObjectToTables -State $State -Object $item -TableName "${TableName}_$name" -IdMap $childIdMap
                }
            }
            continue
        }

        $row[$name] = $value
    }

    if ($row.Count -gt 0) {
        if (-not $State.Tables.ContainsKey($TableName)) {
            $State.Tables[$TableName] = New-Object System.Collections.Generic.List[object]
        }
        $State.Tables[$TableName].Add([PSCustomObject]$row)
    }
}

function Convert-RowsForCsvExport {
    param([object[]]$Rows)

    $columns = @($Rows | ForEach-Object { $_.PSObject.Properties.Name } | Sort-Object -Unique)
    $normalizedRows = @()

    foreach ($row in $Rows) {
        $normalizedRow = [ordered]@{}
        foreach ($column in $columns) {
            $property = $row.PSObject.Properties[$column]
            $normalizedRow[$column] = if ($null -ne $property) { $property.Value } else { $null }
        }
        $normalizedRows += [PSCustomObject]$normalizedRow
    }

    return @($normalizedRows)
}

function ConvertTo-CsvLine {
    param([object[]]$Values)

    $escaped = foreach ($value in $Values) {
        if ($null -eq $value) {
            '""'
        }
        else {
            '"' + ([string]$value).Replace('"', '""') + '"'
        }
    }

    return ($escaped -join ',')
}

function Export-QuotedCsv {
    param(
        [object[]]$Rows,
        [string]$Path,
        [string[]]$Columns
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $writer = $null
    try {
        $writer = New-Object System.IO.StreamWriter($Path, $false, $utf8NoBom)
        $columns = if ($Columns -and $Columns.Count -gt 0) {
            @($Columns)
        }
        else {
            $seen = @{}
            $ordered = @()
            foreach ($row in $Rows) {
                foreach ($name in @($row.PSObject.Properties.Name)) {
                    if (-not $seen.ContainsKey($name)) {
                        $seen[$name] = $true
                        $ordered += $name
                    }
                }
            }
            @($ordered)
        }
        $writer.WriteLine((ConvertTo-CsvLine -Values $columns))

        foreach ($row in $Rows) {
            $values = foreach ($column in $columns) {
                $property = $row.PSObject.Properties[$column]
                if ($null -ne $property) { $property.Value } else { $null }
            }
            $writer.WriteLine((ConvertTo-CsvLine -Values @($values)))
        }
    }
    finally {
        if ($writer) { $writer.Dispose() }
    }
}

function Export-MaskingArtifacts {
    param(
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$SecretKey,
        [string[]]$MaskFields,
        [int]$MaxCsvRows
    )

    $state = New-MaskingState
    $extension = [System.IO.Path]::GetExtension($InputFile).ToLowerInvariant()

    if (Test-Path $OutputFolder) {
        Remove-Item -LiteralPath $OutputFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $keyFile = Join-Path $OutputFolder "masking_key.csv"

    if ($extension -eq ".json") {
        $originalJson = Get-Content -Path $InputFile -Raw | ConvertFrom-Json
        $originalItems = if ($originalJson -is [System.Collections.IEnumerable] -and $originalJson -isnot [string]) { @($originalJson) } else { @($originalJson) }

        $maskedItems = @()
        foreach ($item in $originalItems) {
            $maskedItems += Apply-Masking-ToObject -State $state -Object $item -Prefix "root" -RowIndex $null -SecretKey $SecretKey -MaskFields $MaskFields
        }

        foreach ($item in $maskedItems) {
            Process-ObjectToTables -State $state -Object $item -TableName "root" -IdMap @{}
        }

        $jsonPath = Join-Path $OutputFolder "${inputFileName}_masked.json"
        @($maskedItems) | ConvertTo-Json -Depth 100 | Out-File -FilePath $jsonPath -Encoding UTF8 -Force
    }
    elseif ($extension -eq ".csv") {
        $originalRows = @(Import-Csv -Path $InputFile | Select-Object -First $MaxCsvRows)
        $maskedRows = @()

        for ($rowIndex = 0; $rowIndex -lt $originalRows.Count; $rowIndex++) {
            $maskedRow = [PSCustomObject]@{}
            foreach ($property in $originalRows[$rowIndex].PSObject.Properties) {
                if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                    continue
                }

                $fieldPath = "root.$($property.Name)"
                $maskedValue = Mask-IfNeeded -State $state -FieldName $fieldPath -Value $property.Value -RowIndex $rowIndex -SecretKey $SecretKey -MaskFields $MaskFields
                $maskedRow | Add-Member -NotePropertyName $property.Name -NotePropertyValue $maskedValue
            }
            $maskedRows += $maskedRow
        }

        $csvPath = Join-Path $OutputFolder "$inputFileName.csv"
        Export-QuotedCsv -Rows $maskedRows -Path $csvPath
    }
    else {
        throw "Unsupported file type for $InputFile"
    }

    if ($state.Tables.Count -gt 0) {
        foreach ($tableName in $state.Tables.Keys) {
            $fileName = if ($tableName -eq "root") { "data.csv" } else { "$($tableName.Replace('root_', '')).csv" }
            $tablePath = Join-Path $OutputFolder $fileName
            Export-QuotedCsv -Rows (Convert-RowsForCsvExport -Rows @($state.Tables[$tableName].ToArray())) -Path $tablePath
        }
    }

    if ($state.MappingWithRows.Count -gt 0) {
        Export-QuotedCsv -Rows @($state.MappingWithRows) -Path $keyFile -Columns @("Original", "Masked", "Field", "RowIndex")
    }
    else {
        Export-QuotedCsv -Rows @() -Path $keyFile -Columns @("Original", "Masked", "Field", "RowIndex")
    }

$replicationScript = @"
param(
    [string]`$SecretKey = "$SecretKey",
    [string]`$OutputRoot = "`$PSScriptRoot",
    [int]`$MaxCsvRows = $MaxCsvRows
)

& "`$PSScriptRoot\..\..\..\testing scripts\test-masking-tool.ps1" -SecretKey `$SecretKey -OutputRoot `$OutputRoot -MaxCsvRows `$MaxCsvRows
"@
    $replicationScript | Out-File -FilePath (Join-Path $OutputFolder "replicate_masking.ps1") -Encoding UTF8 -Force

    return [PSCustomObject]@{
        InputFile   = $InputFile
        OutputFolder = $OutputFolder
        KeyFile     = $keyFile
        MaskFields  = $MaskFields
        Type        = $extension.TrimStart(".")
    }
}

function ConvertTo-NormalizedValue {
    param([AllowNull()]$Value)

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [PSCustomObject]) {
        $ordered = [ordered]@{}
        foreach ($property in ($Value.PSObject.Properties | Sort-Object Name)) {
            if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                continue
            }
            $ordered[$property.Name] = ConvertTo-NormalizedValue -Value $property.Value
        }
        return $ordered
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $ordered = [ordered]@{}
        foreach ($key in ($Value.Keys | Sort-Object)) {
            $ordered[$key] = ConvertTo-NormalizedValue -Value $Value[$key]
        }
        return $ordered
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $items = New-Object System.Collections.Generic.List[object]
        foreach ($item in $Value) {
            $items.Add((ConvertTo-NormalizedValue -Value $item))
        }
        return @($items.ToArray())
    }

    return $Value
}

function Get-NormalizedJson {
    param([AllowNull()]$Value)
    return (($Value | ConvertTo-Json -Depth 100 -Compress) -join "")
}

function Is-Blank {
    param([AllowNull()]$Value)
    return [string]::IsNullOrWhiteSpace([string]$Value)
}

function Get-MaskOccurrenceCount {
    param(
        [AllowNull()]$Value,
        [string]$Prefix = "root",
        [AllowNull()]$RowIndex,
        [string[]]$MaskFields
    )

    if ($null -eq $Value) {
        return 0
    }

    if ($Value -is [PSCustomObject]) {
        $count = 0
        foreach ($property in $Value.PSObject.Properties) {
            if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                continue
            }
            $count += Get-MaskOccurrenceCount -Value $property.Value -Prefix "$Prefix.$($property.Name)" -RowIndex $RowIndex -MaskFields $MaskFields
        }
        return $count
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $count = 0
        foreach ($item in $Value) {
            $count += Get-MaskOccurrenceCount -Value $item -Prefix $Prefix -RowIndex $RowIndex -MaskFields $MaskFields
        }
        return $count
    }

    if ((Should-MaskField -FieldPath $Prefix -MaskFields $MaskFields) -and -not (Is-Blank -Value $Value)) {
        return 1
    }

    return 0
}

function Resolve-KeyMaskedValue {
    param(
        [object[]]$KeyRows,
        [string]$FieldPath,
        [AllowNull()]$OriginalValue,
        [AllowNull()]$RowIndex,
        [string]$ScenarioName
    )

    $originalString = [string]$OriginalValue
    if ([string]::IsNullOrEmpty($originalString)) {
        return $originalString
    }

    $normalizedField = Normalize-FieldName $FieldPath
    $matches = @(
        $KeyRows | Where-Object {
            $_.Original -ceq $originalString -and
            (Normalize-FieldName $_.Field) -ceq $normalizedField -and
            (
                ((Is-Blank $_.RowIndex) -and (Is-Blank $RowIndex)) -or
                ([string]$_.RowIndex -ceq [string]$RowIndex)
            )
        }
    )

    if ($matches.Count -eq 0) {
        throw "[$ScenarioName] Missing masking key entry for field '$normalizedField' and value '$originalString'."
    }

    $distinctMasks = @($matches | Select-Object -ExpandProperty Masked -Unique)
    if ($distinctMasks.Count -ne 1) {
        throw "[$ScenarioName] Multiple masked values found for field '$normalizedField' and value '$originalString'."
    }

    return $distinctMasks[0]
}

function Apply-ExpectedMasking {
    param(
        [AllowNull()]$Value,
        [object[]]$KeyRows,
        [string[]]$MaskFields,
        [string]$ScenarioName,
        [string]$Prefix = "root",
        [AllowNull()]$RowIndex
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [PSCustomObject]) {
        $maskedObject = [PSCustomObject]@{}
        foreach ($property in $Value.PSObject.Properties) {
            if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                continue
            }

            $fieldPath = "$Prefix.$($property.Name)"
            $maskedValue = Apply-ExpectedMasking -Value $property.Value -KeyRows $KeyRows -MaskFields $MaskFields -ScenarioName $ScenarioName -Prefix $fieldPath -RowIndex $RowIndex
            $maskedObject | Add-Member -NotePropertyName $property.Name -NotePropertyValue $maskedValue
        }
        return $maskedObject
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $maskedItems = @()
        foreach ($item in $Value) {
            $maskedItems += Apply-ExpectedMasking -Value $item -KeyRows $KeyRows -MaskFields $MaskFields -ScenarioName $ScenarioName -Prefix $Prefix -RowIndex $RowIndex
        }
        return ,@($maskedItems)
    }

    if ((Should-MaskField -FieldPath $Prefix -MaskFields $MaskFields) -and -not (Is-Blank -Value $Value)) {
        return Resolve-KeyMaskedValue -KeyRows $KeyRows -FieldPath $Prefix -OriginalValue $Value -RowIndex $RowIndex -ScenarioName $ScenarioName
    }

    return $Value
}

function Get-ComparableTablesFromJson {
    param([AllowNull()]$Json)

    $tables = @{}

    function Add-ComparableRow {
        param(
            [AllowNull()]$Object,
            [string]$TableName = "root"
        )

        if ($null -eq $Object) {
            return
        }

        $row = [ordered]@{}
        foreach ($property in $Object.PSObject.Properties) {
            if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                continue
            }

            $value = $property.Value
            if ($value -is [PSCustomObject]) {
                Add-ComparableRow -Object $value -TableName "${TableName}_$($property.Name)"
                continue
            }

            if ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
                foreach ($item in $value) {
                    if ($item -is [PSCustomObject]) {
                        Add-ComparableRow -Object $item -TableName "${TableName}_$($property.Name)"
                    }
                }
                continue
            }

            $row[$property.Name] = [string]$value
        }

        if ($row.Count -gt 0) {
            if (-not $tables.ContainsKey($TableName)) {
                $tables[$TableName] = New-Object System.Collections.Generic.List[object]
            }
            $tables[$TableName].Add([PSCustomObject]$row)
        }
    }

    $items = if ($Json -is [System.Collections.IEnumerable] -and $Json -isnot [string]) { @($Json) } else { @($Json) }
    foreach ($item in $items) {
        Add-ComparableRow -Object $item -TableName "root"
    }

    return $tables
}

function Get-TableFileName {
    param([string]$TableName)
    if ($TableName -eq "root") {
        return "data.csv"
    }
    return "$($TableName.Replace('root_', '')).csv"
}

function Get-FieldPrefixFromTableName {
    param([string]$TableName)
    if ($TableName -eq "root") {
        return "root"
    }
    return "root.$($TableName.Replace('root_', '').Replace('_', '.'))"
}

function Convert-TableRowsToExpectedMaskedRows {
    param(
        [object[]]$Rows,
        [string]$TableName,
        [object[]]$KeyRows,
        [string[]]$MaskFields,
        [string]$ScenarioName
    )

    $fieldPrefix = Get-FieldPrefixFromTableName -TableName $TableName
    $result = @()

    foreach ($row in $Rows) {
        $maskedRow = [ordered]@{}
        foreach ($property in $row.PSObject.Properties) {
            $fieldPath = "$fieldPrefix.$($property.Name)"
            $value = [string]$property.Value
            if ((Should-MaskField -FieldPath $fieldPath -MaskFields $MaskFields) -and -not (Is-Blank -Value $value)) {
                $maskedRow[$property.Name] = Resolve-KeyMaskedValue -KeyRows $KeyRows -FieldPath $fieldPath -OriginalValue $value -RowIndex $null -ScenarioName $ScenarioName
            }
            else {
                $maskedRow[$property.Name] = $value
            }
        }
        $result += [PSCustomObject]$maskedRow
    }

    return @($result)
}

function Normalize-TableRowsToColumns {
    param(
        [object[]]$Rows,
        [string[]]$ColumnsToKeep
    )

    $normalized = @()
    foreach ($row in $Rows) {
        $cleanRow = [ordered]@{}
        foreach ($column in $ColumnsToKeep) {
            $value = ""
            $property = $row.PSObject.Properties[$column]
            if ($null -ne $property) {
                $value = [string]$property.Value
            }
            $cleanRow[$column] = $value
        }
        $normalized += [PSCustomObject]$cleanRow
    }
    return @($normalized)
}

function Test-MaskingKeyFile {
    param(
        [string]$ScenarioName,
        [AllowNull()]$OriginalData,
        [object[]]$KeyRows,
        [string]$SecretKey,
        [string[]]$MaskFields,
        [string]$ScenarioType
    )

    $expectedCount = 0
    if ($ScenarioType -eq "json") {
        $items = if ($OriginalData -is [System.Collections.IEnumerable] -and $OriginalData -isnot [string]) { @($OriginalData) } else { @($OriginalData) }
        foreach ($item in $items) {
            $expectedCount += Get-MaskOccurrenceCount -Value $item -Prefix "root" -RowIndex $null -MaskFields $MaskFields
        }
    }
    else {
        for ($rowIndex = 0; $rowIndex -lt $OriginalData.Count; $rowIndex++) {
            foreach ($property in $OriginalData[$rowIndex].PSObject.Properties) {
                if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                    continue
                }
                if ((Should-MaskField -FieldPath "root.$($property.Name)" -MaskFields $MaskFields) -and -not (Is-Blank -Value $property.Value)) {
                    $expectedCount++
                }
            }
        }
    }

    if ($expectedCount -ne $KeyRows.Count) {
        throw "[$ScenarioName] masking_key.csv row count mismatch. Expected $expectedCount, got $($KeyRows.Count)."
    }

    $byOriginal = New-OrdinalHashtable
    foreach ($row in $KeyRows) {
        if (-not $byOriginal.ContainsKey($row.Original)) {
            $byOriginal[$row.Original] = $row.Masked
        }
        elseif ($byOriginal[$row.Original] -cne $row.Masked) {
            throw "[$ScenarioName] Original value '$($row.Original)' maps to more than one masked value."
        }

        $expectedMask = Get-MaskedValue -Value $row.Original -Key $SecretKey
        if ($row.Masked -cne $expectedMask) {
            throw "[$ScenarioName] masking_key.csv contains an unexpected mask for '$($row.Original)'."
        }

        if ($ScenarioType -eq "csv" -and (Is-Blank -Value $row.RowIndex)) {
            throw "[$ScenarioName] CSV key row for '$($row.Original)' is missing RowIndex."
        }

        if (-not (Should-MaskField -FieldPath ("root." + (Normalize-FieldName $row.Field)) -MaskFields $MaskFields)) {
            throw "[$ScenarioName] masking_key.csv contains unexpected field '$($row.Field)'."
        }
    }
}

function Test-JsonScenario {
    param(
        [pscustomobject]$Scenario,
        [pscustomobject]$Artifacts,
        [string]$SecretKey
    )

    $originalJson = Get-Content -Path $Scenario.InputFile -Raw | ConvertFrom-Json
    $maskedJsonPath = Join-Path $Artifacts.OutputFolder "$([System.IO.Path]::GetFileNameWithoutExtension($Scenario.InputFile))_masked.json"
    $actualMaskedJson = Get-Content -Path $maskedJsonPath -Raw | ConvertFrom-Json
    $keyRows = @(Import-Csv -Path $Artifacts.KeyFile)

    Test-MaskingKeyFile -ScenarioName $Scenario.Name -OriginalData $originalJson -KeyRows $keyRows -SecretKey $SecretKey -MaskFields $Scenario.MaskFields -ScenarioType "json"

    $expectedMaskedJson = @()
    $originalItems = if ($originalJson -is [System.Collections.IEnumerable] -and $originalJson -isnot [string]) { @($originalJson) } else { @($originalJson) }
    foreach ($item in $originalItems) {
        $expectedMaskedJson += Apply-ExpectedMasking -Value $item -KeyRows $keyRows -MaskFields $Scenario.MaskFields -ScenarioName $Scenario.Name -Prefix "root" -RowIndex $null
    }

    $actualJsonText = Get-NormalizedJson -Value $actualMaskedJson
    $expectedJsonText = Get-NormalizedJson -Value $expectedMaskedJson
    if ($actualJsonText -ne $expectedJsonText) {
        $expectedPath = Join-Path $Artifacts.OutputFolder "expected_masked.json"
        $actualPath = Join-Path $Artifacts.OutputFolder "actual_masked.normalized.json"
        $expectedJsonText | Out-File -FilePath $expectedPath -Encoding UTF8 -Force
        $actualJsonText | Out-File -FilePath $actualPath -Encoding UTF8 -Force
        throw "[$($Scenario.Name)] Masked JSON does not match the original data plus the expected masking."
    }

    $expectedTables = Get-ComparableTablesFromJson -Json $originalJson
    foreach ($tableName in $expectedTables.Keys) {
        $tablePath = Join-Path $Artifacts.OutputFolder (Get-TableFileName -TableName $tableName)
        if (-not (Test-Path $tablePath)) {
            throw "[$($Scenario.Name)] Missing expected table output '$tablePath'."
        }

        $expectedSourceRows = @($expectedTables[$tableName].ToArray())
        $expectedRows = Convert-TableRowsToExpectedMaskedRows -Rows $expectedSourceRows -TableName $tableName -KeyRows $keyRows -MaskFields $Scenario.MaskFields -ScenarioName $Scenario.Name
        $expectedColumns = @($expectedRows | ForEach-Object { $_.PSObject.Properties.Name } | Sort-Object -Unique)
        $actualRows = Normalize-TableRowsToColumns -Rows @(Import-Csv -Path $tablePath) -ColumnsToKeep $expectedColumns
        $expectedRows = Normalize-TableRowsToColumns -Rows $expectedRows -ColumnsToKeep $expectedColumns

        if ((Get-NormalizedJson -Value $actualRows) -ne (Get-NormalizedJson -Value $expectedRows)) {
            throw "[$($Scenario.Name)] Table '$tableName' does not match the original data plus the expected masking."
        }
    }
}

function Test-CsvScenario {
    param(
        [pscustomobject]$Scenario,
        [pscustomobject]$Artifacts,
        [string]$SecretKey,
        [int]$MaxCsvRows
    )

    $originalRows = @(Import-Csv -Path $Scenario.InputFile | Select-Object -First $MaxCsvRows)
    $maskedPath = Join-Path $Artifacts.OutputFolder "$([System.IO.Path]::GetFileNameWithoutExtension($Scenario.InputFile)).csv"
    $actualMaskedRows = @(Import-Csv -Path $maskedPath)
    $keyRows = @(Import-Csv -Path $Artifacts.KeyFile)

    Test-MaskingKeyFile -ScenarioName $Scenario.Name -OriginalData $originalRows -KeyRows $keyRows -SecretKey $SecretKey -MaskFields $Scenario.MaskFields -ScenarioType "csv"

    if ($originalRows.Count -ne $actualMaskedRows.Count) {
        throw "[$($Scenario.Name)] Row count changed after masking."
    }

    $expectedRows = @()
    for ($rowIndex = 0; $rowIndex -lt $originalRows.Count; $rowIndex++) {
        $expectedRow = [ordered]@{}
        foreach ($property in $originalRows[$rowIndex].PSObject.Properties) {
            if ($property.Name -like "PS*" -or $property.Name -eq "SyncRoot") {
                continue
            }

            $fieldPath = "root.$($property.Name)"
            $value = [string]$property.Value
            if ((Should-MaskField -FieldPath $fieldPath -MaskFields $Scenario.MaskFields) -and -not (Is-Blank -Value $value)) {
                $expectedRow[$property.Name] = Resolve-KeyMaskedValue -KeyRows $keyRows -FieldPath $fieldPath -OriginalValue $value -RowIndex $rowIndex -ScenarioName $Scenario.Name
            }
            else {
                $expectedRow[$property.Name] = $value
            }
        }
        $expectedRows += [PSCustomObject]$expectedRow
    }

    if ((Get-NormalizedJson -Value $actualMaskedRows) -ne (Get-NormalizedJson -Value $expectedRows)) {
        throw "[$($Scenario.Name)] Masked CSV does not match the original data plus the expected masking."
    }
}

function Get-ComparableReplicationFiles {
    param([string]$Folder)

    $extensions = @(".csv", ".json", ".ndjson")
    return @(
        Get-ChildItem -Path $Folder -File |
            Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() } |
            Sort-Object Name
    )
}

function Test-ReplicationScript {
    param(
        [pscustomobject]$Scenario,
        [string]$OutputFolder
    )

    $replicationScript = Join-Path $OutputFolder "replicate_masking.ps1"
    $toolCopy = Join-Path $OutputFolder "DataMaskingTool.ps1"

    if (-not (Test-Path -LiteralPath $replicationScript)) {
        throw "[$($Scenario.Name)] Missing replicate_masking.ps1."
    }
    if (-not (Test-Path -LiteralPath $toolCopy)) {
        throw "[$($Scenario.Name)] Missing DataMaskingTool.ps1 beside replicate_masking.ps1."
    }

    $replicationText = Get-Content -LiteralPath $replicationScript -Raw
    if ($replicationText -notmatch [regex]::Escape($Scenario.InputFile)) {
        throw "[$($Scenario.Name)] replicate_masking.ps1 does not remember the original input path."
    }
    if ($replicationText -notmatch "Invoke-Masking") {
        throw "[$($Scenario.Name)] replicate_masking.ps1 does not call Invoke-Masking."
    }

    $toolText = Get-Content -LiteralPath $toolCopy -Raw
    if ($toolText -notmatch "github.com/hedbergec/flatandmask") {
        throw "[$($Scenario.Name)] DataMaskingTool.ps1 copy is missing the Git source reference."
    }
    if ($toolText -notmatch "NO WARRANTY") {
        throw "[$($Scenario.Name)] DataMaskingTool.ps1 copy is missing the warranty disclaimer."
    }

    $replayOutput = Join-Path $OutputFolder "_replication_replay"
    if (Test-Path -LiteralPath $replayOutput) {
        Remove-Item -LiteralPath $replayOutput -Recurse -Force
    }

    $replayLog = Join-Path $OutputFolder "replication_replay.log"
    try {
        & $replicationScript -OutputFolder $replayOutput *> $replayLog
        if (-not $?) {
            throw "replicate_masking.ps1 returned an unsuccessful status."
        }
    }
    catch {
        $tail = ""
        if (Test-Path -LiteralPath $replayLog) {
            $tail = (Get-Content -LiteralPath $replayLog -Tail 25) -join "`n"
        }
        throw "[$($Scenario.Name)] replicate_masking.ps1 failed. $($_.Exception.Message)`nReplay log tail:`n$tail"
    }

    $sourceFiles = @(Get-ComparableReplicationFiles -Folder $OutputFolder)
    $replayFiles = @(Get-ComparableReplicationFiles -Folder $replayOutput)
    $sourceNames = @($sourceFiles | Select-Object -ExpandProperty Name)
    $replayNames = @($replayFiles | Select-Object -ExpandProperty Name)

    $missing = @($sourceNames | Where-Object { $_ -notin $replayNames })
    if ($missing.Count -gt 0) {
        throw "[$($Scenario.Name)] Replication replay is missing output files: $($missing -join ', ')."
    }

    $extra = @($replayNames | Where-Object { $_ -notin $sourceNames })
    if ($extra.Count -gt 0) {
        throw "[$($Scenario.Name)] Replication replay produced unexpected output files: $($extra -join ', ')."
    }

    foreach ($sourceFile in $sourceFiles) {
        $replayFile = Join-Path $replayOutput $sourceFile.Name
        $sourceHash = (Get-FileHash -LiteralPath $sourceFile.FullName -Algorithm SHA256).Hash
        $replayHash = (Get-FileHash -LiteralPath $replayFile -Algorithm SHA256).Hash
        if ($sourceHash -ne $replayHash) {
            throw "[$($Scenario.Name)] Replication replay output '$($sourceFile.Name)' does not match the original run."
        }
    }
}

function Invoke-RealToolScenario {
    param(
        [pscustomobject]$Scenario,
        [string]$SecretKey,
        [string]$OutputRoot,
        [switch]$SkipReplicationTests
    )

    if (-not (Get-Command Invoke-Masking -ErrorAction SilentlyContinue)) {
        $toolPath = Join-Path $repoRoot "DataMaskingTool.ps1"
        $toolText = Get-Content -Path $toolPath -Raw
        $marker = "# ==================== Main GUI ===================="
        $markerIndex = $toolText.IndexOf($marker)
        if ($markerIndex -lt 0) {
            throw "Could not load DataMaskingTool.ps1 functions; GUI marker was not found."
        }
        Invoke-Expression $toolText.Substring(0, $markerIndex)
    }

    $scenarioOutput = Join-Path $OutputRoot $Scenario.Name
    if (Test-Path $scenarioOutput) {
        Remove-Item -LiteralPath $scenarioOutput -Recurse -Force
    }
    New-Item -ItemType Directory -Path $scenarioOutput -Force | Out-Null

    $script:VerboseLogging = $false
    $mainForm = $null
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressLabel = New-Object System.Windows.Forms.Label
    $keyFile = Join-Path $scenarioOutput "masking_key.csv"

    Invoke-Masking -InputFile $Scenario.InputFile -OutputFolder $scenarioOutput -KeyFile $keyFile -SecretKey $SecretKey -MaskFields $Scenario.MaskFields

    if (-not (Test-Path $keyFile)) {
        throw "[$($Scenario.Name)] Missing masking_key.csv."
    }

    $keyRows = @(Import-Csv -Path $keyFile)
    if ($keyRows.Count -eq 0) {
        throw "[$($Scenario.Name)] Expected masking_key.csv to contain at least one masked value."
    }

    foreach ($maskField in $Scenario.MaskFields) {
        $normalized = Normalize-FieldName $maskField
        if (-not @($keyRows | Where-Object { $_.Field -ceq $normalized })) {
            throw "[$($Scenario.Name)] masking_key.csv does not include expected field '$normalized'."
        }
    }

    $byOriginal = New-OrdinalHashtable
    foreach ($row in $keyRows) {
        $expectedMask = Get-MaskedValue -Value $row.Original -Key $SecretKey
        if ($row.Masked -cne $expectedMask) {
            throw "[$($Scenario.Name)] masking_key.csv contains an unexpected mask for '$($row.Original)'."
        }
        if (-not $byOriginal.ContainsKey($row.Original)) {
            $byOriginal[$row.Original] = $row.Masked
        }
        elseif ($byOriginal[$row.Original] -cne $row.Masked) {
            throw "[$($Scenario.Name)] Original value '$($row.Original)' maps to more than one masked value."
        }
    }

    $dataCsv = Join-Path $scenarioOutput "data.csv"
    if (-not (Test-Path $dataCsv)) {
        throw "[$($Scenario.Name)] Missing data.csv."
    }
    if (@(Import-Csv -Path $dataCsv).Count -eq 0) {
        throw "[$($Scenario.Name)] data.csv is empty."
    }

    $inputName = [System.IO.Path]::GetFileNameWithoutExtension($Scenario.InputFile)
    $jsonPath = Join-Path $scenarioOutput "${inputName}_masked.json"
    $ndjsonPath = Join-Path $scenarioOutput "${inputName}_masked.ndjson"
    if ($Scenario.Type -eq "tool-json" -and -not (Test-Path $jsonPath) -and -not (Test-Path $ndjsonPath)) {
        throw "[$($Scenario.Name)] Missing masked JSON/NDJSON output."
    }

    if ($Scenario.Name -eq "test-socrata-json") {
        $maskedJson = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json
        if (@($maskedJson.data).Count -ne 2) {
            throw "[$($Scenario.Name)] Expected 2 Socrata data rows."
        }
        if (@(@($maskedJson.data)[0]).Count -ne 13) {
            throw "[$($Scenario.Name)] Expected Socrata row arrays to preserve 13 columns."
        }
    }

    if (-not $SkipReplicationTests) {
        Test-ReplicationScript -Scenario $Scenario -OutputFolder $scenarioOutput
    }

    return [PSCustomObject]@{
        Scenario = $Scenario.Name
        Type     = $Scenario.Type
        Output   = $scenarioOutput
        Status   = "Passed"
    }
}

function Invoke-Scenario {
    param(
        [pscustomobject]$Scenario,
        [string]$SecretKey,
        [string]$OutputRoot,
        [int]$MaxCsvRows,
        [switch]$SkipReplicationTests
    )

    if ($Scenario.Type -like "tool-*") {
        return Invoke-RealToolScenario -Scenario $Scenario -SecretKey $SecretKey -OutputRoot $OutputRoot -SkipReplicationTests:$SkipReplicationTests
    }

    $scenarioOutput = Join-Path $OutputRoot $Scenario.Name
    $artifacts = Export-MaskingArtifacts -InputFile $Scenario.InputFile -OutputFolder $scenarioOutput -SecretKey $SecretKey -MaskFields $Scenario.MaskFields -MaxCsvRows $MaxCsvRows

    if ($Scenario.Type -eq "json") {
        Test-JsonScenario -Scenario $Scenario -Artifacts $artifacts -SecretKey $SecretKey
    }
    else {
        Test-CsvScenario -Scenario $Scenario -Artifacts $artifacts -SecretKey $SecretKey -MaxCsvRows $MaxCsvRows
    }

    return [PSCustomObject]@{
        Scenario = $Scenario.Name
        Type     = $Scenario.Type
        Output   = $scenarioOutput
        Status   = "Passed"
    }
}

function Test-CaseSensitiveMaskingSemantics {
    $secret = "case-sensitive-test-key"
    $state = New-MaskingState
    $maskFields = @("root.Value")

    $upper = Mask-IfNeeded -State $state -FieldName "root.Value" -Value "CaseValue" -RowIndex 0 -SecretKey $secret -MaskFields $maskFields
    $lower = Mask-IfNeeded -State $state -FieldName "root.Value" -Value "casevalue" -RowIndex 1 -SecretKey $secret -MaskFields $maskFields

    if ($upper -ceq $lower) {
        throw "[case-sensitive-masking] Case-only distinct original values produced the same mask."
    }
    if ($upper -cne (Get-MaskedValue -Value "CaseValue" -Key $secret)) {
        throw "[case-sensitive-masking] Upper-case variant did not match exact-string HMAC."
    }
    if ($lower -cne (Get-MaskedValue -Value "casevalue" -Key $secret)) {
        throw "[case-sensitive-masking] Lower-case variant did not match exact-string HMAC."
    }
    if ($state.Mapping.Count -ne 2 -or $state.MappingWithRows.Count -ne 2) {
        throw "[case-sensitive-masking] Mapping state collapsed case-only distinct values."
    }
}

Test-CaseSensitiveMaskingSemantics

$scenarios = @(
    [PSCustomObject]@{
        Name       = "sample-json-basic"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\sample.json")
        MaskFields = @(
            "name",
            "email"
        )
    },
    [PSCustomObject]@{
        Name       = "case-sensitive-values-csv"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "test_data\test_case_sensitive_values.csv")
        MaskFields = @(
            "root.Value"
        )
    },
    [PSCustomObject]@{
        Name       = "complex-json-sensitive"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\complex3.json")
        MaskFields = @(
            "firstName",
            "lastName",
            "email",
            "phone",
            "contacts.name",
            "contacts.email",
            "contacts.phone",
            "company.headquarters.street",
            "company.headquarters.city",
            "addresses.street",
            "addresses.city",
            "paymentMethods.cardNumber",
            "paymentMethods.cardholderName",
            "paymentMethods.billingAddress",
            "paymentMethods.accountHolderName"
        )
    },
    [PSCustomObject]@{
        Name       = "complex1-json-sensitive"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\complex1.json")
        MaskFields = @(
            "name",
            "email",
            "address.street",
            "address.city",
            "contacts.number",
            "contacts.value"
        )
    },
    [PSCustomObject]@{
        Name       = "complex2-json-sensitive"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\complex2.json")
        MaskFields = @(
            "name",
            "email",
            "address.street",
            "address.city",
            "contacts.number",
            "contacts.value"
        )
    },
    [PSCustomObject]@{
        Name       = "synthetic-hr-role-dates-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\synthetic_hr_dataset_with_role_dates.json")
        MaskFields = @(
            "root.employees.employee_id",
            "root.employees.personal.first_name",
            "root.employees.personal.last_name",
            "root.employees.personal.ssn_like_test_value",
            "root.employees.contact.work_email",
            "root.employees.contact.personal_email",
            "root.employees.contact.phone",
            "root.employees.contact.address.street"
        )
    },
    [PSCustomObject]@{
        Name       = "large-hr-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\large_hr_dataset_approx_10mb.json")
        MaskFields = @(
            "root.employees.employee_id",
            "root.employees.name",
            "root.employees.ssn_like",
            "root.employees.history.department",
            "root.employees.history.job_title"
        )
    },
    [PSCustomObject]@{
        Name       = "city-of-london-street"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "example data\2026-02-city-of-london-street.csv")
        MaskFields = @(
            "Reported by",
            "Falls within",
            "Location"
        )
    },
    [PSCustomObject]@{
        Name       = "city-of-london-stop-and-search"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "example data\2026-02-city-of-london-stop-and-search.csv")
        MaskFields = @(
            "Gender",
            "Age range",
            "Self-defined ethnicity",
            "Officer-defined ethnicity"
        )
    },
    [PSCustomObject]@{
        Name       = "city-of-london-outcomes"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "example data\2026-02-city-of-london-outcomes.csv")
        MaskFields = @(
            "Reported by",
            "Falls within",
            "Location"
        )
    },
    [PSCustomObject]@{
        Name       = "nypd-officer-profile-csv"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "example data\NYPD_Officer_Profile_-_Title_Shield_History.csv")
        MaskFields = @(
            "PROFILE_ID",
            "SHIELD_NO"
        )
    },
    [PSCustomObject]@{
        Name       = "nypd-officer-profile-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "example data\NYPD Officer Profile - Title Shield History.json")
        MaskFields = @(
            "root.PROFILE_ID",
            "root.SHIELD_NO"
        )
    },
    [PSCustomObject]@{
        Name       = "test-data-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_data.json")
        MaskFields = @("root.ssn")
    },
    [PSCustomObject]@{
        Name       = "test-ndjson"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_ndjson.json")
        MaskFields = @("root.email")
    },
    [PSCustomObject]@{
        Name       = "test-concatenated-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_concatenated.json")
        MaskFields = @("root.email")
    },
    [PSCustomObject]@{
        Name       = "test-envelope-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_envelope.json")
        MaskFields = @("root.email")
    },
    [PSCustomObject]@{
        Name       = "test-geojson"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_geojson.json")
        MaskFields = @("root.properties.email")
    },
    [PSCustomObject]@{
        Name       = "test-header-array-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_header_array.json")
        MaskFields = @("root.email")
    },
    [PSCustomObject]@{
        Name       = "test-socrata-json"
        Type       = "tool-json"
        InputFile  = (Join-Path $repoRoot "test_data\test_socrata.json")
        MaskFields = @("root.PROFILE_ID", "root.SHIELD_NO")
    },
    [PSCustomObject]@{
        Name       = "test-data-csv"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "test_data\test_data.csv")
        MaskFields = @("root.Email", "root.Phone", "root.SSN")
    },
    [PSCustomObject]@{
        Name       = "test-data-fewer-rows-csv"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "test_data\test_data_fewer_rows.csv")
        MaskFields = @("root.Email", "root.Phone", "root.SSN")
    },
    [PSCustomObject]@{
        Name       = "test-data-missing-values-csv"
        Type       = "tool-csv"
        InputFile  = (Join-Path $repoRoot "test_data\test_data_missing_values.csv")
        MaskFields = @("root.Email", "root.Phone", "root.SSN")
    }
)

if ($ListScenarios) {
    $scenarios | Select-Object Name, Type, InputFile | Format-Table -AutoSize
    return
}

if ($ScenarioName -and $ScenarioName.Count -gt 0) {
    $requestedScenarios = @($ScenarioName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $selectedScenarios = @(
        foreach ($scenario in $scenarios) {
            foreach ($requestedScenario in $requestedScenarios) {
                if ($scenario.Name -like $requestedScenario) {
                    $scenario
                    break
                }
            }
        }
    )

    $matchedScenarioNames = @($selectedScenarios | Select-Object -ExpandProperty Name -Unique)
    $missingScenarios = @(
        foreach ($requestedScenario in $requestedScenarios) {
            if (-not @($scenarios | Where-Object { $_.Name -like $requestedScenario })) {
                $requestedScenario
            }
        }
    )
    if ($missingScenarios.Count -gt 0) {
        throw "Unknown scenario name(s): $($missingScenarios -join ', '). Use -ListScenarios to see available data-specific tests."
    }

    $scenarios = @($selectedScenarios | Where-Object { $_.Name -in $matchedScenarioNames })
    Write-Host "Filtered scenarios: $($matchedScenarioNames -join ', ')" -ForegroundColor Cyan
}

if ($Clean -and (Test-Path $OutputRoot)) {
    Remove-Item -LiteralPath $OutputRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

$results = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[object]
$testStart = Get-Date

foreach ($scenario in $scenarios) {
    Write-Host ""
    Write-Host "Running scenario: $($scenario.Name)" -ForegroundColor Cyan
    Write-Host "Input: $($scenario.InputFile)" -ForegroundColor DarkCyan

    try {
        $result = Invoke-Scenario -Scenario $scenario -SecretKey $SecretKey -OutputRoot $OutputRoot -MaxCsvRows $MaxCsvRows -SkipReplicationTests:$SkipReplicationTests
        $results.Add($result)
        Write-Host "Passed: $($scenario.Name)" -ForegroundColor Green
    }
    catch {
        $failure = [PSCustomObject]@{
            Scenario = $scenario.Name
            Type     = $scenario.Type
            Output   = Join-Path $OutputRoot $scenario.Name
            Status   = "Failed"
            Error    = "{0}`n{1}`n{2}" -f $_.Exception.Message, $_.InvocationInfo.PositionMessage, $_.ScriptStackTrace
        }
        $results.Add($failure)
        $failures.Add($failure)
        Write-Host "Failed: $($scenario.Name)" -ForegroundColor Red
        Write-Host $failure.Error -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Regression Summary" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
$results | Select-Object Scenario, Type, Status, Output | Format-Table -AutoSize

$testEnd = Get-Date
$resultsPath = Join-Path $OutputRoot "test-results.json"
$resultsStatus = if ($failures.Count -gt 0) { "Failed" } else { "Passed" }
$resultArray = @($results.ToArray())
$scenarioCount = @($scenarios).Count
$passedCount = @($resultArray | Where-Object { $_.Status -eq "Passed" }).Count
$failedCount = $failures.Count
$resultsReceipt = [PSCustomObject]@{
    StartedAt            = $testStart.ToString("o")
    FinishedAt           = $testEnd.ToString("o")
    DurationSeconds      = [Math]::Round(($testEnd - $testStart).TotalSeconds, 3)
    OutputRoot           = $OutputRoot
    MaxCsvRows           = $MaxCsvRows
    SkipReplicationTests = [bool]$SkipReplicationTests
    ScenarioCount        = $scenarioCount
    PassedCount          = $passedCount
    FailedCount          = $failedCount
    Status               = $resultsStatus
    Results              = $resultArray
}
$resultsReceipt | ConvertTo-Json -Depth 6 | Out-File -FilePath $resultsPath -Encoding UTF8 -Force
Write-Host "Wrote test results: $resultsPath" -ForegroundColor Green

if ($failedCount -gt 0) {
    Write-Host ""
    Write-Host "Failures" -ForegroundColor Red
    Write-Host "--------" -ForegroundColor Red
    $failures | Select-Object Scenario, Error | Format-Table -Wrap -AutoSize
    throw "$failedCount masking regression scenario(s) failed. See $resultsPath for details."
}

Write-Host ""
Write-Host "All masking regression scenarios passed." -ForegroundColor Green
