param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,

    [Parameter(Mandatory=$true)]
    [string]$OutputFolder,

    [Parameter(Mandatory=$true)]
    [string]$KeyFile,

    [Parameter(Mandatory=$true)]
    [string]$SecretKey,

    [Parameter(Mandatory=$false)]
    [string[]]$MaskFields = @()
)

# Ensure output folder exists
New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null

# -----------------------------
# Load Input (JSON / CSV / Excel)
# -----------------------------
function Load-InputData {
    param($Path)

    $ext = [System.IO.Path]::GetExtension($Path).ToLower()

    switch ($ext) {
        ".json" {
            return (Get-Content $Path -Raw | ConvertFrom-Json)
        }
        ".csv" {
            return (Import-Csv $Path)
        }
        ".xlsx" {
            if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
                throw "Excel input requires ImportExcel module. Install with: Install-Module ImportExcel"
            }

            # Load all sheets as separate datasets
            $sheets = Get-ExcelSheetInfo -Path $Path
            $result = @()

            foreach ($sheet in $sheets) {
                $data = Import-Excel -Path $Path -WorksheetName $sheet.Name
                foreach ($row in $data) {
                    # tag sheet name as source
                    $row | Add-Member -NotePropertyName "_sheet" -NotePropertyValue $sheet.Name
                    $result += $row
                }
            }

            return $result
        }
        default {
            throw "Unsupported file type: $ext"
        }
    }
}

# -----------------------------
# Deterministic Masking
# -----------------------------
function Get-MaskedValue {
    param($Value, $Key)

    if ([string]::IsNullOrEmpty($Value)) { return $Value }

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($Key)

    $bytes = [Text.Encoding]::UTF8.GetBytes($Value)
    $hash = $hmac.ComputeHash($bytes)

    return ([Convert]::ToBase64String($hash).Substring(0,12))
}

$global:Mapping = @{}

function Mask-IfNeeded {
    param($FieldName, $Value)

    if ($MaskFields -contains $FieldName) {
        $strVal = [string]$Value

        if (-not $global:Mapping.ContainsKey($strVal)) {
            $global:Mapping[$strVal] = Get-MaskedValue $strVal $SecretKey
        }

        return $global:Mapping[$strVal]
    }

    return $Value
}

# -----------------------------
# Table Storage
# -----------------------------
$global:Tables = @{}

function Add-ToTable {
    param($TableName, $Row)

    if (-not $global:Tables.ContainsKey($TableName)) {
        $global:Tables[$TableName] = @()
    }

    $global:Tables[$TableName] += New-Object PSObject -Property $Row
}

# -----------------------------
# Recursive JSON Splitter
# -----------------------------
function Process-Object {
    param(
        $Object,
        [string]$TableName,
        [string]$ParentId = $null
    )

    $row = @{}
    $currentId = [guid]::NewGuid().ToString()

    $row["_id"] = $currentId
    if ($ParentId) { $row["_parent_id"] = $ParentId }

    foreach ($prop in $Object.PSObject.Properties) {
        $name = $prop.Name
        $value = $prop.Value

        if ($value -is [System.Collections.IDictionary]) {
            Process-Object -Object $value -TableName "$TableName`_$name" -ParentId $currentId
        }
        elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            foreach ($item in $value) {
                if ($item -is [System.Collections.IDictionary]) {
                    Process-Object -Object $item -TableName "$TableName`_$name" -ParentId $currentId
                }
                else {
                    $childRow = @{
                        "_id" = [guid]::NewGuid().ToString()
                        "_parent_id" = $currentId
                        "value" = Mask-IfNeeded "$TableName.$name" $item
                    }
                    Add-ToTable "$TableName`_$name" $childRow
                }
            }
        }
        else {
            $row[$name] = Mask-IfNeeded "$TableName.$name" $value
        }
    }

    Add-ToTable $TableName $row
}

# -----------------------------
# Normalize Flat Data (CSV/Excel)
# -----------------------------
function Process-FlatData {
    param($Data, $TableName)

    foreach ($row in $Data) {
        $newRow = @{}
        $id = [guid]::NewGuid().ToString()

        $newRow["_id"] = $id

        foreach ($prop in $row.PSObject.Properties) {
            $fieldName = "$TableName.$($prop.Name)"
            $newRow[$prop.Name] = Mask-IfNeeded $fieldName $prop.Value
        }

        Add-ToTable $TableName $newRow
    }
}

# -----------------------------
# MAIN
# -----------------------------
$data = Load-InputData $InputFile

if ($data -is [System.Collections.IEnumerable] -and
    $data.Count -gt 0 -and
    $data[0] -is [System.Management.Automation.PSObject] -and
    ($InputFile.ToLower().EndsWith(".csv") -or $InputFile.ToLower().EndsWith(".xlsx"))) {

    # Flat input
    Process-FlatData -Data $data -TableName "root"
}
else {
    # JSON input
    if ($data -isnot [System.Collections.IEnumerable]) {
        $data = @($data)
    }

    foreach ($obj in $data) {
        Process-Object -Object $obj -TableName "root"
    }
}

# -----------------------------
# Export Tables
# -----------------------------
foreach ($tableName in $global:Tables.Keys) {
    $path = Join-Path $OutputFolder "$tableName.csv"
    $global:Tables[$tableName] | Export-Csv -NoTypeInformation -Path $path
}

# -----------------------------
# Export Key File
# -----------------------------
$global:Mapping.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        Original = $_.Key
        Masked   = $_.Value
    }
} | Export-Csv -NoTypeInformation -Path $KeyFile

Write-Host "Done."
Write-Host "Tables: $OutputFolder"
Write-Host "Key file: $KeyFile"

