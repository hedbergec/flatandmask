
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:AppVersion = "1.0.1"
$script:AppTitle = "Data Masking Tool"
$script:LastInputFile = $null
$script:LastOutputFolder = $null
$script:SelectedFields = @()
$script:SecretKey = ""
$script:Mapping = @{}
$script:MappingWithRows = @()
$script:Tables = @{}
$script:OriginalData = $null
$script:MaskedData = $null
$script:InputWasJson = $false
$script:TotalLines = 0
$script:ProcessedLines = 0
$script:TablesProduced = 0

# ==================== CSV Field Selector ====================
function Get-CsvFields {
    param([string]$FilePath)
    try {
        $csv = Import-Csv $FilePath -ErrorAction Stop
        if ($csv -is [System.Collections.IEnumerable]) {
            $first = $csv | Select-Object -First 1
            if ($null -ne $first) {
                return @($first.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" } | Select-Object -ExpandProperty Name)
            }
        }
        elseif ($csv -is [PSCustomObject]) {
            return @($csv.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" } | Select-Object -ExpandProperty Name)
        }
        return @()
    }
    catch {
        throw "Error reading CSV file: $($_.Exception.Message)"
    }
}

function Show-CsvFieldSelector {
    param([string]$FilePath)
    try {
        $fields = Get-CsvFields -FilePath $FilePath
        if (-not $fields -or $fields.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No fields found in CSV file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return @()
        }
        
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Select Fields to Mask"
        $form.Size = New-Object System.Drawing.Size(500, 600)
        $form.StartPosition = "CenterScreen"
        $form.TopMost = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        
        $list = New-Object System.Windows.Forms.CheckedListBox
        $list.Left = 10
        $list.Top = 10
        $list.Width = 460
        $list.Height = 520
        $list.Sorted = $true
        $list.Items.AddRange($fields)
        
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Dock = "Bottom"
        $panel.Height = 50
        
        $ok = New-Object System.Windows.Forms.Button
        $ok.Text = "OK"
        $ok.Width = 80
        $ok.Height = 30
        $ok.Left = 200
        $ok.Top = 10
        $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
        
        $cancel = New-Object System.Windows.Forms.Button
        $cancel.Text = "Cancel"
        $cancel.Width = 80
        $cancel.Height = 30
        $cancel.Left = 300
        $cancel.Top = 10
        $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        
        $panel.Controls.Add($ok)
        $panel.Controls.Add($cancel)
        $form.Controls.Add($list)
        $form.Controls.Add($panel)
        
        $result = $form.ShowDialog()
        $selected = @()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            for ($i = 0; $i -lt $list.Items.Count; $i++) {
                if ($list.GetItemChecked($i)) {
                    $selected += $list.Items[$i]
                }
            }
        }
        $form.Dispose()
        return $selected
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return @()
    }
}

# ==================== Masking Functions ====================
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
        if ($mainForm) {
            $mainForm.Invoke([action]{
                $progressBar.Value = [Math]::Min($script:ProcessedLines, $progressBar.Maximum)
                $progressLabel.Text = "Processing: $($script:ProcessedLines) lines | Tables: $($script:TablesProduced)"
                $mainForm.Refresh()
            })
        }
        
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
        if (-not $script:Tables.ContainsKey($TableName)) {
            $script:Tables[$TableName] = @()
            $script:TablesProduced++
        }
        $script:Tables[$TableName] += [PSCustomObject]$row
    }
}

function Invoke-Masking {
    param(
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string]$SecretKey,
        [string[]]$MaskFields
    )
    
    $script:SelectedFields = $MaskFields
    $script:SecretKey = $SecretKey
    $script:Mapping = @{}
    $script:MappingWithRows = @()
    $script:Tables = @{}
    $script:ProcessedLines = 0
    $script:TablesProduced = 0
    $script:InputWasJson = $false
    
    $ext = [System.IO.Path]::GetExtension($InputFile).ToLower()
    
    if ($ext -eq ".json") {
        $json = Get-Content $InputFile -Raw | ConvertFrom-Json
        $script:InputWasJson = $true
        $script:OriginalData = $json
        
        if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
            $script:TotalLines = @($json).Count
            $progressBar.Maximum = $script:TotalLines
            # FIX: Collect all items into an array explicitly
            $maskedItems = @()
            foreach ($item in $json) { 
                $maskedItems += Apply-Masking-ToObject $item 
            }
            $script:MaskedData = $maskedItems
        } else {
            $script:TotalLines = 1
            $progressBar.Maximum = 1
            $script:MaskedData = @(@(Apply-Masking-ToObject $json))
        }
        
        if ($script:MaskedData -is [System.Collections.IEnumerable] -and $script:MaskedData -isnot [string]) {
            $maskedArray = @($script:MaskedData)
            foreach ($item in $maskedArray) {
                Process-MaskedObject -Object $item -TableName "root" -IdMap @{}
            }
        } else {
            Process-MaskedObject -Object $script:MaskedData -TableName "root" -IdMap @{}
        }
        
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
    }
    elseif ($ext -eq ".csv") {
        $data = Import-Csv $InputFile -ErrorAction Stop
        $script:OriginalData = $data
        $dataArray = @($data)
        $script:TotalLines = $dataArray.Count
        $progressBar.Maximum = $script:TotalLines
        
        $script:MaskedData = @($dataArray | ForEach-Object -Begin { $rowIdx = 0 } -Process {
            $script:ProcessedLines++
            $mainForm.Invoke([action]{
                $progressBar.Value = $script:ProcessedLines
                $progressLabel.Text = "Processing: $($script:ProcessedLines) lines | Tables: $($script:TablesProduced)"
                $mainForm.Refresh()
            })
            
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
        
        if (-not (Test-Path $OutputFolder)) {
            New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
        }
        
        if (-not $script:Tables.ContainsKey("root")) {
            $script:Tables["root"] = @()
            $script:TablesProduced++
        }
        $script:Tables["root"] += $script:MaskedData
    }
    
    foreach ($tableName in $script:Tables.Keys) {
        $name = if ($tableName -eq "root") { "data" } else { $tableName.Replace("root_", "") }
        $path = Join-Path $OutputFolder "$name.csv"
        $script:Tables[$tableName] | Export-Csv -NoTypeInformation -Path $path -Force -Encoding UTF8
    }
    
    if ($script:MappingWithRows.Count -gt 0) {
        $script:MappingWithRows | Select-Object Original, Masked, Field, RowIndex | Export-Csv -NoTypeInformation -Path $KeyFile -Force -Encoding UTF8
    } elseif ($script:Mapping.Count -gt 0) {
        $script:Mapping.GetEnumerator() | ForEach-Object {
            [PSCustomObject]@{
                Original = $_.Key
                Masked   = $_.Value.Masked
                Field    = $_.Value.Field
            }
        } | Export-Csv -NoTypeInformation -Path $KeyFile -Force -Encoding UTF8
    } else {
        @() | Export-Csv -NoTypeInformation -Path $KeyFile -Force -Encoding UTF8
    }
    
    Generate-ReplicationScript -OutputFolder $OutputFolder -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
}

function Generate-ReplicationScript {
    param(
        [string]$OutputFolder,
        [string]$InputFile,
        [string]$SecretKey,
        [string[]]$MaskFields
    )
    
    $maskFieldsList = @()
    foreach ($field in $MaskFields) {
        $maskFieldsList += "`"$field`""
    }
    $maskFieldsForScript = $maskFieldsList -join ','
    
    $scriptContent = @"
param(
    [string]`$InputFile = "$InputFile",
    [string]`$OutputFolder = "$OutputFolder",
    [string]`$SecretKey = "$SecretKey"
)

`$MaskFields = @($maskFieldsForScript)
`$Mapping = @{}
`$MappingWithRows = @()
`$Tables = @{}

function Normalize-FieldName {
    param([string]`$FieldPath)
    if (`$FieldPath.StartsWith("root.")) {
        return `$FieldPath.Substring(5)
    }
    return `$FieldPath
}

function Should-MaskField {
    param([string]`$FieldPath)
    `$normalized = Normalize-FieldName `$FieldPath
    foreach (`$maskField in `$MaskFields) {
        `$normalizedMask = Normalize-FieldName `$maskField
        if (`$normalized -eq `$normalizedMask) {
            return `$true
        }
    }
    return `$false
}

function Get-MaskedValue {
    param(`$Value, `$Key)
    if ([string]::IsNullOrEmpty(`$Value)) { return `$Value }
    `$hmac = New-Object System.Security.Cryptography.HMACSHA256
    `$hmac.Key = [Text.Encoding]::UTF8.GetBytes(`$Key)
    `$bytes = [Text.Encoding]::UTF8.GetBytes([string]`$Value)
    `$hash = `$hmac.ComputeHash(`$bytes)
    return ([Convert]::ToBase64String(`$hash).Substring(0, 12))
}

function Mask-IfNeeded {
    param(`$FieldName, `$Value, `$RowIndex = `$null)
    if (Should-MaskField `$FieldName) {
        `$strVal = [string]`$Value
        `$normalizedField = Normalize-FieldName `$FieldName
        if (-not `$Mapping.ContainsKey(`$strVal)) {
            `$Mapping[`$strVal] = @{
                Masked = Get-MaskedValue `$strVal `$SecretKey
                Field = `$normalizedField
            }
        }
        
        `$MappingWithRows += [PSCustomObject]@{
            Original = `$strVal
            Masked   = `$Mapping[`$strVal].Masked
            Field    = `$normalizedField
            RowIndex = `$RowIndex
        }
        
        return `$Mapping[`$strVal].Masked
    }
    return `$Value
}

function Apply-Masking-ToObject {
    param(`$Object, [string]`$Prefix = "root")
    
    if (`$Object -is [PSCustomObject]) {
        `$maskedObj = [PSCustomObject]@{}
        `$properties = `$Object.PSObject.Properties | Where-Object { -not (`$_.Name -like "PS*") -and `$_.Name -ne "SyncRoot" }
        
        foreach (`$prop in `$properties) {
            `$name = `$prop.Name
            `$value = `$prop.Value
            `$fieldPath = "`$Prefix.`$name"
            
            if (`$value -is [PSCustomObject]) {
                `$maskedObj | Add-Member -NotePropertyName `$name -NotePropertyValue (Apply-Masking-ToObject `$value `$fieldPath)
            }
            elseif (`$value -is [System.Collections.IEnumerable] -and `$value -isnot [string]) {
                `$maskedArray = foreach (`$item in `$value) {
                    if (`$item -is [PSCustomObject]) {
                        Apply-Masking-ToObject `$item `$fieldPath
                    } else {
                        Mask-IfNeeded `$fieldPath `$item
                    }
                }
                `$maskedObj | Add-Member -NotePropertyName `$name -NotePropertyValue @(`$maskedArray)
            }
            else {
                `$maskedObj | Add-Member -NotePropertyName `$name -NotePropertyValue (Mask-IfNeeded `$fieldPath `$value)
            }
        }
        return `$maskedObj
    }
    elseif (`$Object -is [System.Collections.IEnumerable] -and `$Object -isnot [string]) {
        return foreach (`$item in `$Object) { 
            Apply-Masking-ToObject `$item `$Prefix 
        }
    }
    else {
        return Mask-IfNeeded `$Prefix `$Object
    }
}

function Get-TableNameFromPath {
    param([string]`$Path)
    `$parts = `$Path -split "_"
    return `$parts[-1]
}

function Process-MaskedObject {
    param(`$Object, [string]`$TableName = "root", [hashtable]`$IdMap = @{})
    if (`$null -eq `$Object) { return }
    
    `$tableSuffix = Get-TableNameFromPath `$TableName
    `$currentIdKey = "`${tableSuffix}_id"
    `$currentId = [guid]::NewGuid().ToString().Substring(0, 8)
    
    `$row = @{}
    foreach (`$parentKey in `$IdMap.Keys | Sort-Object) {
        `$row[`$parentKey] = `$IdMap[`$parentKey]
    }
    `$row[`$currentIdKey] = `$currentId
    
    `$properties = `$Object.PSObject.Properties | Where-Object { -not (`$_.Name -like "PS*") -and `$_.Name -ne "SyncRoot" }
    
    foreach (`$prop in `$properties) {
        `$name = `$prop.Name
        `$value = `$prop.Value
        
        if (`$value -is [PSCustomObject]) {
            `$newIdMap = `$IdMap.Clone()
            `$newIdMap[`$currentIdKey] = `$currentId
            Process-MaskedObject -Object `$value -TableName "`${TableName}_`$name" -IdMap `$newIdMap
        }
        elseif (`$value -is [System.Collections.IEnumerable] -and `$value -isnot [string]) {
            foreach (`$item in `$value) {
                if (`$item -is [PSCustomObject]) {
                    `$newIdMap = `$IdMap.Clone()
                    `$newIdMap[`$currentIdKey] = `$currentId
                    Process-MaskedObject -Object `$item -TableName "`${TableName}_`$name" -IdMap `$newIdMap
                }
            }
        }
        else {
            `$row[`$name] = `$value
        }
    }
    
    if (`$row.Count -gt 0) {
        if (-not `$Tables.ContainsKey(`$TableName)) {
            `$Tables[`$TableName] = @()
        }
        `$Tables[`$TableName] += [PSCustomObject]`$row
    }
}

Write-Host "Replicating masking operation..."
Write-Host "Input: `$InputFile"
Write-Host "Output: `$OutputFolder"

if (-not (Test-Path `$OutputFolder)) {
    New-Item -ItemType Directory -Force -Path `$OutputFolder | Out-Null
}

`$ext = [System.IO.Path]::GetExtension(`$InputFile).ToLower()

if (`$ext -eq ".json") {
    `$json = Get-Content `$InputFile -Raw | ConvertFrom-Json
    if (`$json -is [System.Collections.IEnumerable] -and `$json -isnot [string]) {
        `$maskedData = foreach (`$item in `$json) { 
            Apply-Masking-ToObject `$item 
        }
    } else {
        `$maskedData = Apply-Masking-ToObject `$json
    }
    
    if (`$maskedData -is [System.Collections.IEnumerable] -and `$maskedData -isnot [string]) {
        foreach (`$item in `$maskedData) {
            Process-MaskedObject -Object `$item -TableName "root" -IdMap @{}
        }
    } else {
        Process-MaskedObject -Object `$maskedData -TableName "root" -IdMap @{}
    }
    
    `$inputFileName = [System.IO.Path]::GetFileNameWithoutExtension(`$InputFile)
    `$jsonOutputPath = Join-Path `$OutputFolder "`${inputFileName}_masked.json"
    `$jsonOutput = @(`$maskedData)
    `$jsonOutput | ConvertTo-Json -Depth 100 | Out-File -FilePath `$jsonOutputPath -Encoding UTF8 -Force
}
elseif (`$ext -eq ".csv") {
    `$data = Import-Csv `$InputFile
    `$maskedData = @(`$data | ForEach-Object -Begin { `$rowIdx = 0 } -Process {
        `$maskedRow = [PSCustomObject]@{}
        `$_.PSObject.Properties | ForEach-Object {
            if (-not (`$_.Name -like "PS*") -and `$_.Name -ne "SyncRoot") {
                `$name = `$_.Name
                `$value = `$_.Value
                `$fieldPath = "root.`$name"
                `$maskedValue = Mask-IfNeeded `$fieldPath `$value `$rowIdx
                `$maskedRow | Add-Member -NotePropertyName `$name -NotePropertyValue `$maskedValue
            }
        }
        `$rowIdx++
        `$maskedRow
    })
    if (-not `$Tables.ContainsKey("root")) {
        `$Tables["root"] = @()
    }
    `$Tables["root"] += `$maskedData
}

foreach (`$tableName in `$Tables.Keys) {
    `$name = if (`$tableName -eq "root") { "data" } else { `$tableName.Replace("root_", "") }
    `$path = Join-Path `$OutputFolder "`$name.csv"
    `$Tables[`$tableName] | Export-Csv -NoTypeInformation -Path `$path -Force -Encoding UTF8
}

`$keyFile = Join-Path `$OutputFolder "masking_key.csv"
if (`$MappingWithRows.Count -gt 0) {
    `$MappingWithRows | Select-Object Original, Masked, Field, RowIndex | Export-Csv -NoTypeInformation -Path `$keyFile -Force -Encoding UTF8
} elseif (`$Mapping.Count -gt 0) {
    `$Mapping.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Original = `$_.Key
            Masked   = `$_.Value.Masked
            Field    = `$_.Value.Field
        }
    } | Export-Csv -NoTypeInformation -Path `$keyFile -Force -Encoding UTF8
} else {
    @() | Export-Csv -NoTypeInformation -Path `$keyFile -Force -Encoding UTF8
}

Write-Host "Replication complete!" -ForegroundColor Green
Write-Host "Output: `$OutputFolder"
"@
    
    $scriptPath = Join-Path $OutputFolder "replicate_masking.ps1"
    $scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
}

# ==================== Tree Viewer ====================
function Show-TreeViewer {
    param([string]$JsonFilePath)
    try {
        $json = Get-Content $JsonFilePath -Raw | ConvertFrom-Json
        
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "JSON Schema Tree"
        $form.Size = New-Object System.Drawing.Size(600, 700)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        
        $searchLabel = New-Object System.Windows.Forms.Label
        $searchLabel.Text = "Search:"
        $searchLabel.AutoSize = $true
        $searchLabel.Left = 10
        $searchLabel.Top = 10
        
        $searchBox = New-Object System.Windows.Forms.TextBox
        $searchBox.Width = 570
        $searchBox.Left = 10
        $searchBox.Top = 35
        
        $tree = New-Object System.Windows.Forms.TreeView
        $tree.Left = 10
        $tree.Top = 65
        $tree.Width = 570
        $tree.Height = 590
        
        $allPaths = New-Object System.Collections.Generic.List[string]
        
        function BuildTreeNode {
            param($Object, [string]$Prefix = "root", $ParentNode = $null)
            if ($Object -is [PSCustomObject]) {
                $properties = @($Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" } | Select-Object -ExpandProperty Name)
                foreach ($name in $properties) {
                    $value = $Object.$name
                    $newPrefix = "$Prefix.$name"
                    $allPaths.Add($newPrefix) | Out-Null
                    $node = New-Object System.Windows.Forms.TreeNode
                    $node.Text = $name
                    $node.Tag = $newPrefix
                    if ($ParentNode) {
                        $ParentNode.Nodes.Add($node) | Out-Null
                    } else {
                        $tree.Nodes.Add($node) | Out-Null
                    }
                    BuildTreeNode -Object $value -Prefix $newPrefix -ParentNode $node
                }
            }
            elseif ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
                $first = $Object | Select-Object -First 1
                if ($null -ne $first) {
                    BuildTreeNode -Object $first -Prefix $Prefix -ParentNode $ParentNode
                }
            }
        }
        
        if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
            $first = $json | Select-Object -First 1
            if ($null -ne $first) {
                BuildTreeNode -Object $first -Prefix "root"
            }
        } else {
            BuildTreeNode -Object $json -Prefix "root"
        }
        
        $searchBox.Add_TextChanged({
            $tree.Nodes.Clear()
            $query = $searchBox.Text.ToLower()
            
            if ([string]::IsNullOrEmpty($query)) {
                foreach ($path in $allPaths) {
                    $parts = $path.Split('.')
                    $currentNode = $null
                    foreach ($part in $parts) {
                        $foundNode = $null
                        if ($currentNode) {
                            $foundNode = $currentNode.Nodes | Where-Object { $_.Text -eq $part } | Select-Object -First 1
                        } else {
                            $foundNode = $tree.Nodes | Where-Object { $_.Text -eq $part } | Select-Object -First 1
                        }
                        if (-not $foundNode) {
                            $foundNode = New-Object System.Windows.Forms.TreeNode
                            $foundNode.Text = $part
                            if ($currentNode) {
                                $currentNode.Nodes.Add($foundNode) | Out-Null
                            } else {
                                $tree.Nodes.Add($foundNode) | Out-Null
                            }
                        }
                        $currentNode = $foundNode
                    }
                }
            } else {
                $filtered = @($allPaths | Where-Object { $_.ToLower().Contains($query) })
                foreach ($path in $filtered) {
                    $parts = $path.Split('.')
                    $currentNode = $null
                    foreach ($part in $parts) {
                        $foundNode = $null
                        if ($currentNode) {
                            $foundNode = $currentNode.Nodes | Where-Object { $_.Text -eq $part } | Select-Object -First 1
                        } else {
                            $foundNode = $tree.Nodes | Where-Object { $_.Text -eq $part } | Select-Object -First 1
                        }
                        if (-not $foundNode) {
                            $foundNode = New-Object System.Windows.Forms.TreeNode
                            $foundNode.Text = $part
                            if ($currentNode) {
                                $currentNode.Nodes.Add($foundNode) | Out-Null
                            } else {
                                $tree.Nodes.Add($foundNode) | Out-Null
                            }
                        }
                        $currentNode = $foundNode
                    }
                }
            }
        })
        
        $form.Controls.Add($searchLabel)
        $form.Controls.Add($searchBox)
        $form.Controls.Add($tree)
        $form.ShowDialog() | Out-Null
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# ==================== Main GUI ====================
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = $script:AppTitle
$mainForm.Size = New-Object System.Drawing.Size(700, 700)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedDialog"
$mainForm.MaximizeBox = $false

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Data Masking Tool v$($script:AppVersion)"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoSize = $true
$titleLabel.Left = 20
$titleLabel.Top = 20

$inputLabel = New-Object System.Windows.Forms.Label
$inputLabel.Text = "Input File (JSON/CSV):"
$inputLabel.AutoSize = $true
$inputLabel.Left = 20
$inputLabel.Top = 60

$inputTextBox = New-Object System.Windows.Forms.TextBox
$inputTextBox.ReadOnly = $true
$inputTextBox.Width = 400
$inputTextBox.Left = 20
$inputTextBox.Top = 85

$inputButton = New-Object System.Windows.Forms.Button
$inputButton.Text = "Browse..."
$inputButton.Width = 80
$inputButton.Left = 430
$inputButton.Top = 85

$treeButton = New-Object System.Windows.Forms.Button
$treeButton.Text = "View Tree"
$treeButton.Width = 80
$treeButton.Left = 520
$treeButton.Top = 85
$treeButton.Enabled = $false

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output Folder:"
$outputLabel.AutoSize = $true
$outputLabel.Left = 20
$outputLabel.Top = 120

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.ReadOnly = $true
$outputTextBox.Width = 400
$outputTextBox.Left = 20
$outputTextBox.Top = 145

$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Browse..."
$outputButton.Width = 80
$outputButton.Left = 430
$outputButton.Top = 145

$keyLabel = New-Object System.Windows.Forms.Label
$keyLabel.Text = "Secret Key:"
$keyLabel.AutoSize = $true
$keyLabel.Left = 20
$keyLabel.Top = 180

$keyTextBox = New-Object System.Windows.Forms.TextBox
$keyTextBox.Width = 480
$keyTextBox.Left = 20
$keyTextBox.Top = 205
$keyTextBox.UseSystemPasswordChar = $true

$selectFieldsButton = New-Object System.Windows.Forms.Button
$selectFieldsButton.Text = "Select Fields to Mask"
$selectFieldsButton.Width = 480
$selectFieldsButton.Height = 40
$selectFieldsButton.Left = 20
$selectFieldsButton.Top = 240
$selectFieldsButton.Enabled = $false

$fieldsLabel = New-Object System.Windows.Forms.Label
$fieldsLabel.Text = "Selected Fields: None"
$fieldsLabel.AutoSize = $false
$fieldsLabel.Width = 480
$fieldsLabel.Height = 70
$fieldsLabel.Left = 20
$fieldsLabel.Top = 290
$fieldsLabel.BorderStyle = "FixedSingle"
$fieldsLabel.BackColor = [System.Drawing.Color]::WhiteSmoke

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Text = "Processing: 0 lines | Tables: 0"
$progressLabel.AutoSize = $false
$progressLabel.Width = 480
$progressLabel.Height = 20
$progressLabel.Left = 20
$progressLabel.Top = 368
$progressLabel.Font = New-Object System.Drawing.Font("Arial", 9)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Left = 20
$progressBar.Top = 390
$progressBar.Width = 480
$progressBar.Height = 25
$progressBar.Value = 0
$progressBar.Maximum = 100

$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Left = 20
$buttonPanel.Top = 425
$buttonPanel.Width = 480
$buttonPanel.Height = 50

$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Run Masking"
$runButton.Width = 220
$runButton.Height = 40
$runButton.Left = 0
$runButton.Top = 0
$runButton.Enabled = $false
$runButton.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$runButton.BackColor = [System.Drawing.Color]::LimeGreen
$runButton.ForeColor = [System.Drawing.Color]::White

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Reset"
$resetButton.Width = 220
$resetButton.Height = 40
$resetButton.Left = 240
$resetButton.Top = 0
$resetButton.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$resetButton.BackColor = [System.Drawing.Color]::Silver

$buttonPanel.Controls.Add($runButton)
$buttonPanel.Controls.Add($resetButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready"
$statusLabel.AutoSize = $false
$statusLabel.Width = 660
$statusLabel.Height = 30
$statusLabel.Left = 20
$statusLabel.Top = 485
$statusLabel.BorderStyle = "FixedSingle"

$inputButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Data Files (*.json;*.csv)|*.json;*.csv|JSON Files (*.json)|*.json|CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    
    if ($dialog.ShowDialog() -eq "OK") {
        $script:LastInputFile = $dialog.FileName
        $inputTextBox.Text = $dialog.FileName
        $selectFieldsButton.Enabled = $true
        $statusLabel.Text = "Input file selected"
        
        $ext = [System.IO.Path]::GetExtension($dialog.FileName).ToLower()
        $treeButton.Enabled = ($ext -eq ".json")
    }
})

$treeButton.Add_Click({
    if ($script:LastInputFile -and (Test-Path $script:LastInputFile)) {
        Show-TreeViewer -JsonFilePath $script:LastInputFile
    }
})

$outputButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select output folder"
    
    if ($dialog.ShowDialog() -eq "OK") {
        $script:LastOutputFolder = $dialog.SelectedPath
        $outputTextBox.Text = $dialog.SelectedPath
        $statusLabel.Text = "Output folder selected"
    }
})

$selectFieldsButton.Add_Click({
    if ($script:LastInputFile) {
        $ext = [System.IO.Path]::GetExtension($script:LastInputFile).ToLower()
        
        $selected = @()
        if ($ext -eq ".json") {
            $selected = @(Show-CheckboxForm -Fields (Get-JsonFields $script:LastInputFile))
        }
        elseif ($ext -eq ".csv") {
            $selected = @(Show-CsvFieldSelector -FilePath $script:LastInputFile)
        }
        
        # FIX: Ensure we capture the selection properly
        if ($selected -is [System.Collections.IEnumerable] -and $selected -isnot [string]) {
            $script:SelectedFields = @($selected)
        } elseif ($null -ne $selected) {
            $script:SelectedFields = @($selected)
        } else {
            $script:SelectedFields = @()
        }
        
        $displayText = if ($script:SelectedFields.Count -gt 0) { $script:SelectedFields -join "`r`n" } else { "(none)" }
        $fieldsLabel.Text = "Selected Fields:`r`n$displayText"
        $statusLabel.Text = "Selected $($script:SelectedFields.Count) fields"
        
        Write-Host "Selected Fields: $($script:SelectedFields -join ', ')" -ForegroundColor Cyan
        
        # FIX: Enable Run button only when fields are selected
        if ($script:LastInputFile -and $script:LastOutputFolder -and $keyTextBox.Text -and $script:SelectedFields.Count -gt 0) {
            $runButton.Enabled = $true
        } else {
            $runButton.Enabled = $false
        }
    }
})

function Get-JsonFields {
    param([string]$FilePath)
    $json = Get-Content $FilePath -Raw | ConvertFrom-Json
    $treeLines = New-Object System.Collections.Generic.List[string]
    
    function BuildTree {
        param($Object, [string]$Prefix = "root")
        if ($Object -is [PSCustomObject]) {
            $properties = @($Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" } | Select-Object -ExpandProperty Name)
            foreach ($name in $properties) {
                $value = $Object.$name
                $newPrefix = "$Prefix.$name"
                $treeLines.Add($newPrefix) | Out-Null
                BuildTree -Object $value -Prefix $newPrefix
            }
        }
        elseif ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
            $first = $Object | Select-Object -First 1
            if ($null -ne $first) {
                BuildTree -Object $first -Prefix $Prefix
            }
        }
    }
    
    if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
        $first = $json | Select-Object -First 1
        if ($null -ne $first) {
            BuildTree -Object $first -Prefix "root"
        }
    } else {
        BuildTree -Object $json -Prefix "root"
    }
    return @($treeLines | Sort-Object -Unique)
}

function Show-CheckboxForm {
    param([string[]]$Fields)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Fields to Mask"
    $form.Size = New-Object System.Drawing.Size(500, 600)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    
    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Left = 10
    $list.Top = 10
    $list.Width = 460
    $list.Height = 520
    $list.Sorted = $true
    $list.Items.AddRange($Fields)
    
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Dock = "Bottom"
    $panel.Height = 50
    
    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "OK"
    $ok.Width = 80
    $ok.Height = 30
    $ok.Left = 200
    $ok.Top = 10
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    
    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Width = 80
    $cancel.Height = 30
    $cancel.Left = 300
    $cancel.Top = 10
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    
    $panel.Controls.Add($ok)
    $panel.Controls.Add($cancel)
    $form.Controls.Add($list)
    $form.Controls.Add($panel)
    
    $result = $form.ShowDialog()
    $selected = @()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        for ($i = 0; $i -lt $list.Items.Count; $i++) {
            if ($list.GetItemChecked($i)) {
                $selected += $list.Items[$i]
            }
        }
    }
    $form.Dispose()
    return $selected
}

$keyTextBox.Add_TextChanged({
    $script:SecretKey = $keyTextBox.Text
    if ($script:LastInputFile -and $script:LastOutputFolder -and $script:SecretKey -and $script:SelectedFields.Count -gt 0) {
        $runButton.Enabled = $true
    } else {
        $runButton.Enabled = $false
    }
})

$runButton.Add_Click({
    if (-not $script:LastInputFile -or -not $script:LastOutputFolder -or -not $script:SecretKey) {
        [System.Windows.Forms.MessageBox]::Show("Fill in all fields", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    if ($script:SelectedFields.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one field to mask", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    # DEBUG: Print what we're about to process
    Write-Host "=== DEBUG INFO ===" -ForegroundColor Magenta
    Write-Host "Input File: $($script:LastInputFile)" -ForegroundColor Magenta
    Write-Host "Output Folder: $($script:LastOutputFolder)" -ForegroundColor Magenta
    Write-Host "Selected Fields Count: $($script:SelectedFields.Count)" -ForegroundColor Magenta
    Write-Host "Selected Fields: $($script:SelectedFields -join ', ')" -ForegroundColor Magenta
    Write-Host "Secret Key Length: $($script:SecretKey.Length)" -ForegroundColor Magenta
    
    # Load original data to see what we're working with
    $ext = [System.IO.Path]::GetExtension($script:LastInputFile).ToLower()
    if ($ext -eq ".json") {
        $testJson = Get-Content $script:LastInputFile -Raw | ConvertFrom-Json
        $testCount = if ($testJson -is [System.Collections.IEnumerable]) { @($testJson).Count } else { 1 }
        Write-Host "Original JSON object count: $testCount" -ForegroundColor Magenta
    }
    Write-Host "=================`n" -ForegroundColor Magenta
    
    $statusLabel.Text = "Processing..."
    $runButton.Enabled = $false
    $mainForm.Refresh()
    
    try {
        $keyFile = Join-Path $script:LastOutputFolder "masking_key.csv"
        Invoke-Masking -InputFile $script:LastInputFile -OutputFolder $script:LastOutputFolder -KeyFile $keyFile -SecretKey $script:SecretKey -MaskFields $script:SelectedFields
        $statusLabel.Text = "Complete! Processed $($script:ProcessedLines) lines | Generated $($script:TablesProduced) tables"
        $progressBar.Value = $progressBar.Maximum
        [System.Windows.Forms.MessageBox]::Show("Masking completed successfully!`n`nLines processed: $($script:ProcessedLines)`nTables produced: $($script:TablesProduced)", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        $statusLabel.Text = "Error: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    finally {
        $runButton.Enabled = $true
    }
})

$resetButton.Add_Click({
    $inputTextBox.Text = ""
    $outputTextBox.Text = ""
    $keyTextBox.Text = ""
    $fieldsLabel.Text = "Selected Fields: None"
    $progressBar.Value = 0
    $progressLabel.Text = "Processing: 0 lines | Tables: 0"
    $statusLabel.Text = "Ready"
    $script:LastInputFile = $null
    $script:LastOutputFolder = $null
    $script:SelectedFields = @()
    $script:SecretKey = ""
    $selectFieldsButton.Enabled = $false
    $treeButton.Enabled = $false
    $runButton.Enabled = $false
})

$mainForm.Controls.Add($titleLabel)
$mainForm.Controls.Add($inputLabel)
$mainForm.Controls.Add($inputTextBox)
$mainForm.Controls.Add($inputButton)
$mainForm.Controls.Add($treeButton)
$mainForm.Controls.Add($outputLabel)
$mainForm.Controls.Add($outputTextBox)
$mainForm.Controls.Add($outputButton)
$mainForm.Controls.Add($keyLabel)
$mainForm.Controls.Add($keyTextBox)
$mainForm.Controls.Add($selectFieldsButton)
$mainForm.Controls.Add($fieldsLabel)
$mainForm.Controls.Add($progressLabel)
$mainForm.Controls.Add($progressBar)
$mainForm.Controls.Add($buttonPanel)
$mainForm.Controls.Add($statusLabel)

$mainForm.ShowDialog() | Out-Null
