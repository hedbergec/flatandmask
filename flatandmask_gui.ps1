param(
    [string]$InputFile,
    [string]$OutputFolder,
    [string]$KeyFile,
    [string]$SecretKey,
    [string[]]$MaskFields = @()
)

function Show-InputForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'flatandmask - Enter parameters'
    $form.Size = New-Object System.Drawing.Size(600,320)
    $form.StartPosition = 'CenterScreen'

    $lblInput = New-Object System.Windows.Forms.Label
    $lblInput.Text = 'Input File:'
    $lblInput.Location = New-Object System.Drawing.Point(10,20)
    $lblInput.Size = New-Object System.Drawing.Size(80,20)
    $form.Controls.Add($lblInput)

    $txtInput = New-Object System.Windows.Forms.TextBox
    $txtInput.Location = New-Object System.Drawing.Point(100,18)
    $txtInput.Size = New-Object System.Drawing.Size(360,20)
    $form.Controls.Add($txtInput)

    $btnBrowseInput = New-Object System.Windows.Forms.Button
    $btnBrowseInput.Text = 'Browse'
    $btnBrowseInput.Location = New-Object System.Drawing.Point(470,16)
    $btnBrowseInput.Size = New-Object System.Drawing.Size(75,23)
    $btnBrowseInput.Add_Click({
        $ofd = New-Object System.Windows.Forms.OpenFileDialog
        $ofd.Filter = 'JSON, CSV, Excel|*.json;*.csv;*.xlsx|All files|*.*'
        if ($ofd.ShowDialog() -eq 'OK') { $txtInput.Text = $ofd.FileName }
    })
    $form.Controls.Add($btnBrowseInput)

    $lblOut = New-Object System.Windows.Forms.Label
    $lblOut.Text = 'Output Folder:'
    $lblOut.Location = New-Object System.Drawing.Point(10,60)
    $lblOut.Size = New-Object System.Drawing.Size(80,20)
    $form.Controls.Add($lblOut)

    $txtOut = New-Object System.Windows.Forms.TextBox
    $txtOut.Location = New-Object System.Drawing.Point(100,58)
    $txtOut.Size = New-Object System.Drawing.Size(360,20)
    $form.Controls.Add($txtOut)

    $btnBrowseOut = New-Object System.Windows.Forms.Button
    $btnBrowseOut.Text = 'Browse'
    $btnBrowseOut.Location = New-Object System.Drawing.Point(470,56)
    $btnBrowseOut.Size = New-Object System.Drawing.Size(75,23)
    $btnBrowseOut.Add_Click({
        $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($fbd.ShowDialog() -eq 'OK') { $txtOut.Text = $fbd.SelectedPath }
    })
    $form.Controls.Add($btnBrowseOut)

    $lblKey = New-Object System.Windows.Forms.Label
    $lblKey.Text = 'Key File (CSV):'
    $lblKey.Location = New-Object System.Drawing.Point(10,100)
    $lblKey.Size = New-Object System.Drawing.Size(80,20)
    $form.Controls.Add($lblKey)

    $txtKey = New-Object System.Windows.Forms.TextBox
    $txtKey.Location = New-Object System.Drawing.Point(100,98)
    $txtKey.Size = New-Object System.Drawing.Size(360,20)
    $form.Controls.Add($txtKey)

    $btnBrowseKey = New-Object System.Windows.Forms.Button
    $btnBrowseKey.Text = 'Browse'
    $btnBrowseKey.Location = New-Object System.Drawing.Point(470,96)
    $btnBrowseKey.Size = New-Object System.Drawing.Size(75,23)
    $btnBrowseKey.Add_Click({
        $sfd = New-Object System.Windows.Forms.SaveFileDialog
        $sfd.Filter = 'CSV file|*.csv|All files|*.*'
        $sfd.FileName = 'keyfile.csv'
        if ($sfd.ShowDialog() -eq 'OK') { $txtKey.Text = $sfd.FileName }
    })
    $form.Controls.Add($btnBrowseKey)

    $lblSecret = New-Object System.Windows.Forms.Label
    $lblSecret.Text = 'Secret Key:'
    $lblSecret.Location = New-Object System.Drawing.Point(10,140)
    $lblSecret.Size = New-Object System.Drawing.Size(80,20)
    $form.Controls.Add($lblSecret)

    $txtSecret = New-Object System.Windows.Forms.TextBox
    $txtSecret.Location = New-Object System.Drawing.Point(100,138)
    $txtSecret.Size = New-Object System.Drawing.Size(360,20)
    $form.Controls.Add($txtSecret)

    $lblMask = New-Object System.Windows.Forms.Label
    $lblMask.Text = 'Mask Fields (comma-separated):'
    $lblMask.Location = New-Object System.Drawing.Point(10,180)
    $lblMask.Size = New-Object System.Drawing.Size(200,20)
    $form.Controls.Add($lblMask)

    $txtMask = New-Object System.Windows.Forms.TextBox
    $txtMask.Location = New-Object System.Drawing.Point(10,200)
    $txtMask.Size = New-Object System.Drawing.Size(540,20)
    $form.Controls.Add($txtMask)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = 'OK'
    $btnOK.Location = New-Object System.Drawing.Point(370,240)
    $btnOK.Size = New-Object System.Drawing.Size(80,28)
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = 'Cancel'
    $btnCancel.Location = New-Object System.Drawing.Point(470,240)
    $btnCancel.Size = New-Object System.Drawing.Size(80,28)

    $btnOK.Add_Click({ $form.Tag = 'OK'; $form.Close() })
    $btnCancel.Add_Click({ $form.Tag = 'Cancel'; $form.Close() })

    $form.Controls.Add($btnOK)
    $form.Controls.Add($btnCancel)

    $form.Add_Shown({ $form.Activate() })

    $form.ShowDialog() | Out-Null

    if ($form.Tag -ne 'OK') { return $null }

    $res = [ordered]@{
        InputFile = $txtInput.Text.Trim()
        OutputFolder = $txtOut.Text.Trim()
        KeyFile = $txtKey.Text.Trim()
        SecretKey = $txtSecret.Text
        MaskFields = @()
    }

    if ($txtMask.Text.Trim().Length -gt 0) {
        $res.MaskFields = $txtMask.Text -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }

    return $res
}

# If required params not supplied, show GUI
if (-not ($InputFile -and $OutputFolder -and $KeyFile -and $SecretKey)) {
    $vals = Show-InputForm
    if ($null -eq $vals) { Write-Host 'Cancelled.'; exit }

    $InputFile = $vals.InputFile
    $OutputFolder = $vals.OutputFolder
    $KeyFile = $vals.KeyFile
    $SecretKey = $vals.SecretKey
    $MaskFields = $vals.MaskFields
}

# Validate minimal inputs
if (-not (Test-Path $InputFile)) { throw "Input file not found: $InputFile" }

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

            $sheets = Get-ExcelSheetInfo -Path $Path
            $result = @()

            foreach ($sheet in $sheets) {
                $data = Import-Excel -Path $Path -WorksheetName $sheet.Name
                foreach ($row in $data) {
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
