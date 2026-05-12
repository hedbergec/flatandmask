[CmdletBinding()]
param()

function Normalize-FieldName {
    param([string]$FieldPath)

    if ($FieldPath.StartsWith("root.")) {
        return $FieldPath.Substring(5)
    }

    return $FieldPath
}

function Should-MaskField {
    param(
        [string]$FieldPath,
        [string[]]$MaskFields
    )

    $normalized = Normalize-FieldName $FieldPath
    foreach ($maskField in $MaskFields) {
        if ($normalized -eq (Normalize-FieldName $maskField)) {
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
    return [Convert]::ToBase64String($hash).Substring(0, 12)
}

function New-MaskingState {
    return @{
        Mapping         = @{}
        MappingWithRows = New-Object System.Collections.Generic.List[object]
        Tables          = @{}
        TableCounters   = @{}
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
    return "{0}-{1:d4}" -f $TableName.Replace("root_", "").Replace("_", "-"), $State.TableCounters[$TableName]
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

function Invoke-ExampleMasking {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputFile,

        [Parameter(Mandatory = $true)]
        [string]$OutputFolder,

        [Parameter(Mandatory = $true)]
        [string]$SecretKey,

        [Parameter(Mandatory = $true)]
        [string[]]$MaskFields
    )

    $state = New-MaskingState
    $extension = [System.IO.Path]::GetExtension($InputFile).ToLowerInvariant()
    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)

    if (Test-Path $OutputFolder) {
        Remove-Item -LiteralPath $OutputFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

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
        $originalRows = @(Import-Csv -Path $InputFile)
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
        throw "Unsupported file type: $InputFile"
    }

    foreach ($tableName in $state.Tables.Keys) {
        $fileName = if ($tableName -eq "root") { "data.csv" } else { "$($tableName.Replace('root_', '')).csv" }
        $tablePath = Join-Path $OutputFolder $fileName
        Export-QuotedCsv -Rows (Convert-RowsForCsvExport -Rows @($state.Tables[$tableName].ToArray())) -Path $tablePath
    }

    $keyFile = Join-Path $OutputFolder "masking_key.csv"
    if ($state.MappingWithRows.Count -gt 0) {
        Export-QuotedCsv -Rows @($state.MappingWithRows) -Path $keyFile -Columns @("Original", "Masked", "Field", "RowIndex")
    }
    else {
        Export-QuotedCsv -Rows @() -Path $keyFile -Columns @("Original", "Masked", "Field", "RowIndex")
    }

    Write-Host "Masked '$InputFile' into '$OutputFolder'." -ForegroundColor Green
}
