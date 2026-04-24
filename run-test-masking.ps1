# Test script to run masking and verify output
$ErrorActionPreference = "Stop"

# Load the DataMaskingTool functions by sourcing the script
# But we need to skip the GUI part

$script:SelectedFields = @("email", "phone", "ssn", "firstName", "lastName")
$script:SecretKey = "testkey123"
$script:Mapping = @{}
$script:MappingWithRows = @()
$script:Tables = @{}
$script:ProcessedLines = 0
$script:TablesProduced = 0
$script:InputWasJson = $false

# Define the functions inline (copied from DataMaskingTool.ps1)

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
    foreach ($maskField in $script:SelectedFields) {
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
        if (-not $script:Mapping.ContainsKey($strVal)) {
            $script:Mapping[$strVal] = @{
                Masked = Get-MaskedValue $strVal $script:SecretKey
                Field = $normalizedField
            }
        }
        
        $script:MappingWithRows += [PSCustomObject]@{
            Original = $strVal
            Masked   = $script:Mapping[$strVal].Masked
            Field    = $normalizedField
            RowIndex = $RowIndex
        }
        
        return $script:Mapping[$strVal].Masked
    }
    return $Value
}

function Apply-Masking-ToObject {
    param($Object, [string]$Prefix = "root")
    
    if ($Object -is [PSCustomObject]) {
        $script:ProcessedLines++
        
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
                # FIX: Collect array items explicitly
                $maskedArray = @()
                foreach ($item in $value) {
                    if ($item -is [PSCustomObject]) {
                        $maskedArray += Apply-Masking-ToObject $item $fieldPath
                    } else {
                        $maskedArray += Mask-IfNeeded $fieldPath $item
                    }
                }
                $maskedObj | Add-Member -NotePropertyName $name -NotePropertyValue $maskedArray
            }
            else {
                $maskedObj | Add-Member -NotePropertyName $name -NotePropertyValue (Mask-IfNeeded $fieldPath $value)
            }
        }
        return $maskedObj
    }
    elseif ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        # FIX: Collect items explicitly into array
        $result = @()
        foreach ($item in $Object) { 
            $result += Apply-Masking-ToObject $item $Prefix 
        }
        return $result
    }
    else {
        return Mask-IfNeeded $Prefix $Object
    }
}

# Test with JSON file
$InputFile = ".\test_data\test_data.json"
$OutputFolder = ".\test_output"

Write-Host "Testing JSON masking..." -ForegroundColor Cyan

$json = Get-Content $InputFile -Raw | ConvertFrom-Json
$script:InputWasJson = $true
$script:OriginalData = $json

if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
    $script:TotalLines = @($json).Count
    Write-Host "Processing $($script:TotalLines) JSON objects..."
    
    # FIX: Collect all items into an array explicitly
    $maskedItems = @()
    foreach ($item in $json) { 
        $maskedItems += Apply-Masking-ToObject $item 
    }
    $script:MaskedData = $maskedItems
} else {
    $script:TotalLines = 1
    $script:MaskedData = @(@(Apply-Masking-ToObject $json))
}

Write-Host "MaskedData type: $($script:MaskedData.GetType().FullName)"
Write-Host "MaskedData count: $(@($script:MaskedData).Count)"

# Write output
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
}

$inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$jsonOutputPath = Join-Path $OutputFolder "${inputFileName}_masked.json"

# FIX: Ensure proper array output with brackets
$jsonOutput = @($script:MaskedData)
# Convert to JSON and ensure it's an array by wrapping
$jsonText = $jsonOutput | ConvertTo-Json -Depth 100
# If it's not already wrapped in brackets, add them
if ($jsonText.Trim().StartsWith("{")) {
    $jsonText = "[" + $jsonText + "]"
}
$jsonText | Out-File -FilePath $jsonOutputPath -Encoding UTF8 -Force

Write-Host "Output written to: $jsonOutputPath" -ForegroundColor Green

# Verify output
$verify = Get-Content $jsonOutputPath -Raw | ConvertFrom-Json
Write-Host "Verified output count: $(@($verify).Count)" -ForegroundColor Yellow

# Show first few lines
Write-Host ""
Write-Host "Output preview:" -ForegroundColor Cyan
Get-Content $jsonOutputPath | Select-Object -First 20