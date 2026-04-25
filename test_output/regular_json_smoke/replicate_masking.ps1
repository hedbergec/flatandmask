param(
    [string]$InputFile = "",
    [string]$OutputFolder = "$PSScriptRoot",
    [string]$SecretKey = "smoke-test"
)

if ([string]::IsNullOrWhiteSpace($InputFile)) {
    throw "Provide -InputFile when running replicate_masking.ps1."
}

$MaskFields = @("root.ssn")
$Mapping = @{}
$MappingWithRows = @()
$Tables = @{}

function Normalize-FieldName {
    param([string]$FieldPath)
    if ($FieldPath.StartsWith("root.")) {
        return $FieldPath.Substring(5)
    }
    return $FieldPath
}

function Should-MaskField {
    param([string]$FieldPath)
    $normalized = Normalize-FieldName $FieldPath
    foreach ($maskField in $MaskFields) {
        $normalizedMask = Normalize-FieldName $maskField
        if ($normalized -eq $normalizedMask) {
            return $true
        }
    }
    return $false
}

function Get-MaskedValue {
    param($Value, $Key)
    if ([string]::IsNullOrEmpty($Value)) { return $Value }
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($Key)
    $bytes = [Text.Encoding]::UTF8.GetBytes([string]$Value)
    $hash = $hmac.ComputeHash($bytes)
    return ([Convert]::ToBase64String($hash).Substring(0, 12))
}

function Mask-IfNeeded {
    param($FieldName, $Value, $RowIndex = $null)
    if (Should-MaskField $FieldName) {
        $strVal = [string]$Value
        $normalizedField = Normalize-FieldName $FieldName
        if (-not $Mapping.ContainsKey($strVal)) {
            $Mapping[$strVal] = @{
                Masked = Get-MaskedValue $strVal $SecretKey
                Field = $normalizedField
            }
        }
        
        $MappingWithRows += [PSCustomObject]@{
            Original = $strVal
            Masked   = $Mapping[$strVal].Masked
            Field    = $normalizedField
            RowIndex = $RowIndex
        }
        
        return $Mapping[$strVal].Masked
    }
    return $Value
}

function Apply-Masking-ToObject {
    param($Object, [string]$Prefix = "root")
    
    if ($Object -is [PSCustomObject]) {
        $maskedObj = [PSCustomObject]@{}
        $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
        
        foreach ($prop in $properties) {
            $name = $prop.Name
            $value = $prop.Value
            $fieldPath = "$Prefix.$name"
            
            if ($value -is [PSCustomObject]) {
                $maskedObj | Add-Member -NotePropertyName $name -NotePropertyValue (Apply-Masking-ToObject $value $fieldPath)
            }
            elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
                $maskedArray = foreach ($item in $value) {
                    if ($item -is [PSCustomObject]) {
                        Apply-Masking-ToObject $item $fieldPath
                    } else {
                        Mask-IfNeeded $fieldPath $item
                    }
                }
                $maskedObj | Add-Member -NotePropertyName $name -NotePropertyValue @($maskedArray)
            }
            else {
                $maskedObj | Add-Member -NotePropertyName $name -NotePropertyValue (Mask-IfNeeded $fieldPath $value)
            }
        }
        return $maskedObj
    }
    elseif ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        return foreach ($item in $Object) { 
            Apply-Masking-ToObject $item $Prefix 
        }
    }
    else {
        return Mask-IfNeeded $Prefix $Object
    }
}

function Get-TableNameFromPath {
    param([string]$Path)
    $parts = $Path -split "_"
    return $parts[-1]
}

function Process-MaskedObject {
    param($Object, [string]$TableName = "root", [hashtable]$IdMap = @{})
    if ($null -eq $Object) { return }
    
    $tableSuffix = Get-TableNameFromPath $TableName
    $currentIdKey = "${tableSuffix}_id"
    $currentId = [guid]::NewGuid().ToString().Substring(0, 8)
    
    $row = @{}
    foreach ($parentKey in $IdMap.Keys | Sort-Object) {
        $row[$parentKey] = $IdMap[$parentKey]
    }
    $row[$currentIdKey] = $currentId
    
    $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
    
    foreach ($prop in $properties) {
        $name = $prop.Name
        $value = $prop.Value
        
        if ($value -is [PSCustomObject]) {
            $newIdMap = $IdMap.Clone()
            $newIdMap[$currentIdKey] = $currentId
            Process-MaskedObject -Object $value -TableName "${TableName}_$name" -IdMap $newIdMap
        }
        elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
            foreach ($item in $value) {
                if ($item -is [PSCustomObject]) {
                    $newIdMap = $IdMap.Clone()
                    $newIdMap[$currentIdKey] = $currentId
                    Process-MaskedObject -Object $item -TableName "${TableName}_$name" -IdMap $newIdMap
                }
            }
        }
        else {
            $row[$name] = $value
        }
    }
    
    if ($row.Count -gt 0) {
        if (-not $Tables.ContainsKey($TableName)) {
            $Tables[$TableName] = @()
        }
        $Tables[$TableName] += [PSCustomObject]$row
    }
}

Write-Host "Replicating masking operation..."
Write-Host "Input: $InputFile"
Write-Host "Output: $OutputFolder"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
}

$ext = [System.IO.Path]::GetExtension($InputFile).ToLower()

if ($ext -eq ".json") {
    $json = Get-Content $InputFile -Raw | ConvertFrom-Json
    if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
        $maskedData = foreach ($item in $json) { 
            Apply-Masking-ToObject $item 
        }
    } else {
        $maskedData = Apply-Masking-ToObject $json
    }
    
    if ($maskedData -is [System.Collections.IEnumerable] -and $maskedData -isnot [string]) {
        foreach ($item in $maskedData) {
            Process-MaskedObject -Object $item -TableName "root" -IdMap @{}
        }
    } else {
        Process-MaskedObject -Object $maskedData -TableName "root" -IdMap @{}
    }
    
    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $jsonOutputPath = Join-Path $OutputFolder "${inputFileName}_masked.json"
    $jsonOutput = @($maskedData)
    $jsonOutput | ConvertTo-Json -Depth 100 | Out-File -FilePath $jsonOutputPath -Encoding UTF8 -Force
}
elseif ($ext -eq ".csv") {
    $data = Import-Csv $InputFile
    $maskedData = @($data | ForEach-Object -Begin { $rowIdx = 0 } -Process {
        $maskedRow = [PSCustomObject]@{}
        $_.PSObject.Properties | ForEach-Object {
            if (-not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot") {
                $name = $_.Name
                $value = $_.Value
                $fieldPath = "root.$name"
                $maskedValue = Mask-IfNeeded $fieldPath $value $rowIdx
                $maskedRow | Add-Member -NotePropertyName $name -NotePropertyValue $maskedValue
            }
        }
        $rowIdx++
        $maskedRow
    })
    if (-not $Tables.ContainsKey("root")) {
        $Tables["root"] = @()
    }
    $Tables["root"] += $maskedData
}

foreach ($tableName in $Tables.Keys) {
    $name = if ($tableName -eq "root") { "data" } else { $tableName.Replace("root_", "") }
    $path = Join-Path $OutputFolder "$name.csv"
    $Tables[$tableName] | Export-Csv -NoTypeInformation -Path $path -Force -Encoding UTF8
}

$keyFile = Join-Path $OutputFolder "masking_key.csv"
if ($MappingWithRows.Count -gt 0) {
    $MappingWithRows | Select-Object Original, Masked, Field, RowIndex | Export-Csv -NoTypeInformation -Path $keyFile -Force -Encoding UTF8
} elseif ($Mapping.Count -gt 0) {
    $Mapping.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Original = $_.Key
            Masked   = $_.Value.Masked
            Field    = $_.Value.Field
        }
    } | Export-Csv -NoTypeInformation -Path $keyFile -Force -Encoding UTF8
} else {
    @() | Export-Csv -NoTypeInformation -Path $keyFile -Force -Encoding UTF8
}

Write-Host "Replication complete!" -ForegroundColor Green
Write-Host "Output: $OutputFolder"
