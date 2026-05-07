
# Flat & Mask / Data Masking Tool
#
# Git reference:
# - Repository: https://github.com/hedbergec/flatandmask
# - Source file: https://github.com/hedbergec/flatandmask/blob/main/DataMaskingTool.ps1
#
# License and disclaimers:
# - MIT License, Copyright (c) 2026 Design Effects, LLC.
# - NO WARRANTY: This tool is provided as-is, without warranty of any kind.
# - THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# - IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
#   USE OR OTHER DEALINGS IN THE SOFTWARE.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:AppVersion = "1.4.0"
$script:AppTitle = "Data Masking Tool"
$script:AuthorName = "Eric Hedberg"
$script:AuthorEmail = "hedbergec@outlook.com"
$script:RepoUrl = "https://github.com/hedbergec/flatandmask"
$script:WarrantyDisclaimer = "NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: $($script:RepoUrl). Contact: $($script:AuthorName) <$($script:AuthorEmail)>."
$script:BundledSourceGzipBase64 = "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"

function New-OrdinalHashtable {
    return [System.Collections.Hashtable]::new([System.StringComparer]::Ordinal)
}

$script:LastInputFile = $null
$script:LastOutputFolder = $null
$script:SelectedFields = @()
$script:SecretKey = ""
$script:Mapping = New-OrdinalHashtable
$script:MappingWithRows = New-Object System.Collections.ArrayList
$script:Tables = New-OrdinalHashtable
$script:TableIdCounters = New-OrdinalHashtable
$script:OriginalData = $null
$script:MaskedData = $null
$script:InputWasJson = $false
$script:TotalLines = 0
$script:ProcessedLines = 0
$script:ProgressRecordPath = "root"
$script:ProgressRecordLabel = "Rows"
$script:TablesProduced = 0
$script:EstimatedFieldsToMask = 0
$script:EstimatedTablesToProduce = 0
$script:EstimatedWorkUnits = 0
$script:EstimateMethod = ""
$script:MaskedFieldsProcessed = 0
$script:VerboseLogging = $true  # Enable verbose logging by default
$script:StatusPanelInitialized = $false
$script:StatusPanelTop = 0
$script:StatusLastUpdate = [DateTime]::MinValue
$script:GuiLogMaxLines = 100
$script:GuiLogLines = New-Object System.Collections.Generic.Queue[string]
$script:StatusState = @{
    Mode     = "Ready"
    Phase    = "Idle"
    Progress = "0 / 0"
    Detail   = ""
    Mask     = ""
}

Write-Host $script:WarrantyDisclaimer -ForegroundColor Yellow
Write-Host ""

function Format-StatusLine {
    param([string]$Text)

    $width = 100
    try {
        if ([Console]::BufferWidth -gt 0) {
            $width = [Math]::Max(40, [Console]::BufferWidth - 1)
        }
    } catch {}

    if ($Text.Length -gt $width) {
        return $Text.Substring(0, $width - 3) + "..."
    }

    return $Text.PadRight($width)
}

function Add-GuiLogLine {
    param([string]$Message)

    if ([string]::IsNullOrWhiteSpace($Message)) { return }

    while ($script:GuiLogLines.Count -ge $script:GuiLogMaxLines) {
        $script:GuiLogLines.Dequeue() | Out-Null
    }
    $script:GuiLogLines.Enqueue("$(Get-Date -Format 'HH:mm:ss') $Message")

    if (-not $mainForm -or -not $guiLogBox) { return }

    $updateLog = [action]{
        $guiLogBox.Lines = @($script:GuiLogLines.ToArray())
        $guiLogBox.SelectionStart = $guiLogBox.TextLength
        $guiLogBox.ScrollToCaret()
    }

    if ($mainForm.InvokeRequired) {
        $mainForm.Invoke($updateLog)
    } else {
        $updateLog.Invoke()
    }
}

function Write-StatusPanel {
    param(
        [string]$Mode = $null,
        [string]$Phase = $null,
        [object]$Current = $null,
        [object]$Total = $null,
        [string]$Detail = $null,
        [string]$Mask = $null,
        [switch]$Force
    )

    if (-not $script:VerboseLogging) { return }

    if ($PSBoundParameters.ContainsKey("Mode")) { $script:StatusState.Mode = $Mode }
    if ($PSBoundParameters.ContainsKey("Phase")) { $script:StatusState.Phase = $Phase }
    if ($PSBoundParameters.ContainsKey("Detail")) { $script:StatusState.Detail = $Detail }
    if ($PSBoundParameters.ContainsKey("Mask")) { $script:StatusState.Mask = $Mask }
    if ($PSBoundParameters.ContainsKey("Current") -or $PSBoundParameters.ContainsKey("Total")) {
        $progressParts = $script:StatusState.Progress -split " / "
        $currentText = if ($PSBoundParameters.ContainsKey("Current")) { [string]$Current } else { $progressParts[0] }
        $totalText = if ($PSBoundParameters.ContainsKey("Total")) { [string]$Total } else { $progressParts[1] }
        $currentNumber = 0
        $totalNumber = 0
        if ([int]::TryParse($currentText, [ref]$currentNumber) -and [int]::TryParse($totalText, [ref]$totalNumber) -and $currentNumber -gt $totalNumber) {
            $totalText = $currentText
        }
        $script:StatusState.Progress = "$currentText / $totalText"
    }

    $now = Get-Date
    if (-not $Force -and (($now - $script:StatusLastUpdate).TotalMilliseconds -lt 250)) {
        return
    }
    $script:StatusLastUpdate = $now

    $lines = @(
        "Mode:     $($script:StatusState.Mode)",
        "Phase:    $($script:StatusState.Phase)",
        "Progress: $($script:StatusState.Progress)",
        "Detail:   $($script:StatusState.Detail)",
        "Mask:     $($script:StatusState.Mask)"
    )

    try {
        if (-not $script:StatusPanelInitialized) {
            $script:StatusPanelTop = [Console]::CursorTop
            for ($i = 0; $i -lt 5; $i++) { Write-Host "" }
            $script:StatusPanelInitialized = $true
        }

        $left = [Console]::CursorLeft
        $top = [Console]::CursorTop
        for ($i = 0; $i -lt 5; $i++) {
            [Console]::SetCursorPosition(0, $script:StatusPanelTop + $i)
            Write-Host (Format-StatusLine $lines[$i]) -NoNewline -ForegroundColor Cyan
        }
        [Console]::SetCursorPosition($left, [Math]::Max($top, $script:StatusPanelTop + 5))
    }
    catch {
        Write-Host ($lines -join " | ") -ForegroundColor Cyan
    }

    $logLine = "Mode=$($script:StatusState.Mode); Phase=$($script:StatusState.Phase); Progress=$($script:StatusState.Progress)"
    if (-not [string]::IsNullOrWhiteSpace($script:StatusState.Detail)) {
        $logLine += "; $($script:StatusState.Detail)"
    }
    if (-not [string]::IsNullOrWhiteSpace($script:StatusState.Mask)) {
        $logLine += "; $($script:StatusState.Mask)"
    }
    Add-GuiLogLine $logLine
}

function Write-VerboseLog {
    param([string]$Message)
    Write-StatusPanel -Detail $Message
}

function ConvertTo-AppVersion {
    param([string]$VersionText)

    if ([string]::IsNullOrWhiteSpace($VersionText)) {
        return $null
    }

    $cleanVersion = $VersionText.Trim() -replace '^[vV]', ''
    $match = [regex]::Match($cleanVersion, '\d+(\.\d+){0,3}')
    if (-not $match.Success) {
        return $null
    }

    try {
        return [version]$match.Value
    }
    catch {
        return $null
    }
}

function Get-ToolUpdateStatus {
    $headers = @{ "User-Agent" = "DataMaskingTool/$($script:AppVersion)" }
    $releaseUrl = "https://api.github.com/repos/hedbergec/flatandmask/releases/latest"
    $tagsUrl = "https://api.github.com/repos/hedbergec/flatandmask/tags"
    $rawHeaders = @{ "User-Agent" = "DataMaskingTool/$($script:AppVersion)" }

    try {
        $latestVersionText = $null
        $downloadUrl = $script:RepoUrl

        try {
            $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -UseBasicParsing -ErrorAction Stop
            $latestVersionText = if ($release.tag_name) { [string]$release.tag_name } else { [string]$release.name }
            if ($release.html_url) {
                $downloadUrl = [string]$release.html_url
            }
        }
        catch {
            $tags = @(Invoke-RestMethod -Uri $tagsUrl -Headers $headers -UseBasicParsing -ErrorAction Stop)
            $latestTag = $tags |
                ForEach-Object {
                    $parsed = ConvertTo-AppVersion -VersionText $_.name
                    if ($parsed) {
                        [PSCustomObject]@{ Name = [string]$_.name; Version = $parsed }
                    }
                } |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if ($latestTag) {
                $latestVersionText = $latestTag.Name
                $downloadUrl = "$($script:RepoUrl)/tree/$($latestTag.Name)"
            }
        }

        if (-not (ConvertTo-AppVersion -VersionText $latestVersionText)) {
            foreach ($branchName in @("main", "master")) {
                try {
                    $versionInfoUrl = "https://raw.githubusercontent.com/hedbergec/flatandmask/$branchName/build/dist/VERSION.json"
                    $versionInfo = Invoke-RestMethod -Uri $versionInfoUrl -Headers $rawHeaders -UseBasicParsing -ErrorAction Stop
                    if ($versionInfo.Version) {
                        $latestVersionText = [string]$versionInfo.Version
                        $downloadUrl = "$($script:RepoUrl)/tree/$branchName"
                        break
                    }
                }
                catch {}

                try {
                    $scriptUrl = "https://raw.githubusercontent.com/hedbergec/flatandmask/$branchName/DataMaskingTool.ps1"
                    $remoteScript = Invoke-RestMethod -Uri $scriptUrl -Headers $rawHeaders -UseBasicParsing -ErrorAction Stop
                    $versionMatch = [regex]::Match([string]$remoteScript, '(?m)^\$script:AppVersion\s*=\s*"([^"]+)"')
                    if ($versionMatch.Success) {
                        $latestVersionText = $versionMatch.Groups[1].Value
                        $downloadUrl = "$($script:RepoUrl)/tree/$branchName"
                        break
                    }
                }
                catch {}
            }
        }

        $currentVersion = ConvertTo-AppVersion -VersionText $script:AppVersion
        $latestVersion = ConvertTo-AppVersion -VersionText $latestVersionText
        if (-not $latestVersion) {
            return [PSCustomObject]@{
                Status = "Unknown"
                Message = "Could not find a release or tag version. Check the repo manually:`r`n$($script:RepoUrl)"
                Url = $script:RepoUrl
            }
        }

        if ($currentVersion -and $latestVersion -gt $currentVersion) {
            return [PSCustomObject]@{
                Status = "UpdateAvailable"
                Message = "Update available: $latestVersionText`r`nCurrent version: $($script:AppVersion)`r`nCheck the repo: $downloadUrl"
                Url = $downloadUrl
            }
        }

        return [PSCustomObject]@{
            Status = "Current"
            Message = "You are running the latest known version ($($script:AppVersion)).`r`nRepo: $($script:RepoUrl)"
            Url = $script:RepoUrl
        }
    }
    catch {
        return [PSCustomObject]@{
            Status = "Error"
            Message = "Could not check for updates: $($_.Exception.Message)`r`nCheck the repo manually: $($script:RepoUrl)"
            Url = $script:RepoUrl
        }
    }
}

function Write-MaskLog {
    param([string]$Field, [string]$OriginalValue, [string]$MaskedValue)
    if ($script:VerboseLogging -and $OriginalValue) {
        $truncated = if ($OriginalValue.Length -gt 30) { $OriginalValue.Substring(0, 27) + "..." } else { $OriginalValue }
        Write-StatusPanel -Mask "${Field}: $truncated -> $MaskedValue"
    }
}

function Set-GuiProgressStage {
    param(
        [System.Windows.Forms.ProgressBar]$Bar,
        [int]$Current,
        [int]$Total = 100,
        [switch]$Force
    )

    if (-not $mainForm -or -not $Bar) { return }
    if (-not $Force -and (($Current % 250) -ne 0) -and $Current -ne $Total) { return }

    $mainForm.Invoke([action]{
        $Bar.Maximum = [Math]::Max(1, $Total)
        $Bar.Value = [Math]::Min([Math]::Max(0, $Current), $Bar.Maximum)
        $mainForm.Refresh()
    })
}

function Reset-GuiProgressStages {
    if (-not $mainForm) { return }
    $mainForm.Invoke([action]{
        foreach ($bar in @($loadProgressBar, $progressBar, $normalizeProgressBar, $exportProgressBar)) {
            if ($bar) {
                $bar.Maximum = 100
                $bar.Value = 0
            }
        }
        $mainForm.Refresh()
    })
}

function Complete-GuiProgressStages {
    if (-not $mainForm) { return }
    $mainForm.Invoke([action]{
        foreach ($bar in @($loadProgressBar, $progressBar, $normalizeProgressBar, $exportProgressBar)) {
            if ($bar) {
                $bar.Value = $bar.Maximum
            }
        }
        $mainForm.Refresh()
    })
}

function Read-TextFileWithLoadProgress {
    param(
        [string]$Path,
        [int]$StartPercent = 0,
        [int]$EndPercent = 70
    )

    Set-GuiProgressStage -Bar $loadProgressBar -Current $StartPercent -Total 100 -Force
    $fileInfo = Get-Item -LiteralPath $Path
    if ($fileInfo.Length -le 0) {
        Set-GuiProgressStage -Bar $loadProgressBar -Current $EndPercent -Total 100 -Force
        return ""
    }

    $reader = $null
    $builder = New-Object System.Text.StringBuilder
    $buffer = New-Object char[] 65536
    $lastPercent = -1

    try {
        $reader = New-Object System.IO.StreamReader($Path, [System.Text.Encoding]::UTF8, $true)
        while (($charsRead = $reader.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $builder.Append($buffer, 0, $charsRead) | Out-Null
            $fraction = [Math]::Min(1.0, $reader.BaseStream.Position / [double]$fileInfo.Length)
            $percent = $StartPercent + [int][Math]::Floor(($EndPercent - $StartPercent) * $fraction)
            if ($percent -ne $lastPercent) {
                Set-GuiProgressStage -Bar $loadProgressBar -Current $percent -Total 100 -Force
                $lastPercent = $percent
            }
        }
    }
    finally {
        if ($reader) { $reader.Dispose() }
    }

    Set-GuiProgressStage -Bar $loadProgressBar -Current $EndPercent -Total 100 -Force
    Write-Output -NoEnumerate $builder.ToString()
}

function Read-JsonFileWithLoadProgress {
    param([string]$Path)

    Write-StatusPanel -Phase "Loading" -Current 0 -Total 100 -Detail "Reading input file" -Force
    $rawJson = [string](Read-TextFileWithLoadProgress -Path $Path -StartPercent 0 -EndPercent 70)
    if ([string]::IsNullOrWhiteSpace($rawJson)) {
        throw "Input file is empty or could not be read: $Path"
    }

    Write-StatusPanel -Phase "Parsing JSON" -Current 70 -Total 100 -Detail "Converting JSON text" -Force
    Set-GuiProgressStage -Bar $loadProgressBar -Current 80 -Total 100 -Force
    $json = ConvertFrom-Json -InputObject $rawJson
    Set-GuiProgressStage -Bar $loadProgressBar -Current 90 -Total 100 -Force
    return $json
}

function Update-ProcessingProgress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Phase = "Processing",
        [string]$Detail = $null,
        [switch]$Force
    )

    $progressDetail = Get-JobProgressDetail -Detail $Detail
    Write-StatusPanel -Phase $Phase -Current $Current -Total $Total -Detail $progressDetail -Force:$Force

    Set-GuiProgressStage -Bar $progressBar -Current $Current -Total $Total -Force:$Force
}

# ==================== Job Size Estimation ====================
function Reset-JobEstimate {
    $script:EstimatedFieldsToMask = 0
    $script:EstimatedTablesToProduce = 0
    $script:EstimatedWorkUnits = 0
    $script:EstimateMethod = ""
    $script:MaskedFieldsProcessed = 0
    $script:ProgressRecordPath = "root"
    $script:ProgressRecordLabel = "Rows"
}

function Set-JobEstimate {
    param(
        [int]$Rows,
        [int]$Fields,
        [int]$Tables,
        [string]$Method
    )

    $script:TotalLines = [Math]::Max(0, $Rows)
    $script:EstimatedFieldsToMask = [Math]::Max(0, $Fields)
    $script:EstimatedTablesToProduce = [Math]::Max(0, $Tables)
    $script:EstimatedWorkUnits = $script:TotalLines + $script:EstimatedFieldsToMask + $script:EstimatedTablesToProduce
    $script:EstimateMethod = $Method
}

function Sync-TableEstimateWithProduced {
    if ($script:EstimatedTablesToProduce -le 0 -and $script:Tables -and $script:Tables.Keys.Count -gt 0) {
        $script:EstimatedTablesToProduce = $script:Tables.Keys.Count
        $script:EstimatedWorkUnits = $script:TotalLines + $script:EstimatedFieldsToMask + $script:EstimatedTablesToProduce
    }
}

function Get-JobProgressDetail {
    param([string]$Detail = $null)

    $parts = @()
    if ($Detail) { $parts += $Detail }
    if ($script:EstimatedFieldsToMask -gt 0) {
        $parts += "fields $($script:MaskedFieldsProcessed)/~$($script:EstimatedFieldsToMask)"
    }
    if ($script:EstimatedTablesToProduce -gt 0) {
        $parts += "tables $($script:TablesProduced)/~$($script:EstimatedTablesToProduce)"
    }
    if ($script:EstimateMethod) {
        $parts += $script:EstimateMethod
    }

    return ($parts -join "; ")
}

function Write-JobEstimateStatus {
    param([string]$Mode = $null)

    $detail = "$($script:ProgressRecordLabel.ToLowerInvariant()) $($script:TotalLines); fields ~$($script:EstimatedFieldsToMask); tables ~$($script:EstimatedTablesToProduce)"
    if ($script:EstimatedWorkUnits -gt 0) {
        $detail += "; work units ~$($script:EstimatedWorkUnits)"
    }
    if ($script:EstimateMethod) {
        $detail += "; $($script:EstimateMethod)"
    }
    Write-StatusPanel -Mode $Mode -Phase "Estimated" -Current 0 -Total $script:TotalLines -Detail $detail -Force
    Set-GuiProgressStage -Bar $loadProgressBar -Current 100 -Total 100 -Force
}

function Set-ProgressRecordTarget {
    param(
        [string]$Path = "root",
        [string]$Label = "Rows"
    )

    $script:ProgressRecordPath = if ([string]::IsNullOrWhiteSpace($Path)) { "root" } else { $Path }
    $script:ProgressRecordLabel = if ([string]::IsNullOrWhiteSpace($Label)) { "Rows" } else { $Label }
}

function Get-SelectedFieldSet {
    param([string[]]$MaskFields)

    $set = New-OrdinalHashtable
    foreach ($field in @($MaskFields)) {
        if (-not [string]::IsNullOrWhiteSpace($field)) {
            $set[(Normalize-FieldName $field)] = $true
        }
    }
    return $set
}

function Test-EstimateFieldMatch {
    param(
        [string]$FieldName,
        [hashtable]$SelectedFieldSet
    )

    return $SelectedFieldSet.ContainsKey((Normalize-FieldName $FieldName))
}

function Count-MaskableFieldsInObject {
    param(
        $Object,
        [string]$Prefix = "root",
        [hashtable]$SelectedFieldSet
    )

    if ($null -eq $Object) {
        if (Test-EstimateFieldMatch -FieldName $Prefix -SelectedFieldSet $SelectedFieldSet) { return 1 }
        return 0
    }

    if ($Object -is [PSCustomObject]) {
        $count = 0
        $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
        foreach ($prop in $properties) {
            $count += Count-MaskableFieldsInObject -Object $prop.Value -Prefix "$Prefix.$($prop.Name)" -SelectedFieldSet $SelectedFieldSet
        }
        return $count
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $count = 0
        foreach ($item in $Object) {
            $count += Count-MaskableFieldsInObject -Object $item -Prefix $Prefix -SelectedFieldSet $SelectedFieldSet
        }
        return $count
    }

    if (Test-EstimateFieldMatch -FieldName $Prefix -SelectedFieldSet $SelectedFieldSet) { return 1 }
    return 0
}

function Add-EstimatedTableNamesFromObject {
    param(
        $Object,
        [string]$TableName = "root",
        [hashtable]$TableNames
    )

    if ($null -eq $Object -or $Object -isnot [PSCustomObject]) { return }

    $TableNames[$TableName] = $true
    $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
    foreach ($prop in $properties) {
        $value = $prop.Value
        if ($value -is [PSCustomObject]) {
            Add-EstimatedTableNamesFromObject -Object $value -TableName "${TableName}_$($prop.Name)" -TableNames $TableNames
        }
        elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
            foreach ($item in $value) {
                if ($item -is [PSCustomObject]) {
                    Add-EstimatedTableNamesFromObject -Object $item -TableName "${TableName}_$($prop.Name)" -TableNames $TableNames
                }
            }
        }
    }
}

function Set-JsonRecordJobEstimate {
    param(
        [object[]]$Records,
        [string[]]$MaskFields,
        [string]$ModeName
    )

    $rows = @($Records).Count
    $selectedFieldSet = Get-SelectedFieldSet -MaskFields $MaskFields
    $sampleSize = if ($rows -le 1000) { $rows } else { [Math]::Min($rows, [Math]::Max(1000, [int][Math]::Ceiling($rows * 0.10))) }
    $fieldCount = 0
    $tableNames = @{}

    if ($sampleSize -gt 0) {
        for ($i = 0; $i -lt $sampleSize; $i++) {
            $record = $Records[$i]
            $fieldCount += Count-MaskableFieldsInObject -Object $record -Prefix "root" -SelectedFieldSet $selectedFieldSet
            Add-EstimatedTableNamesFromObject -Object $record -TableName "root" -TableNames $tableNames
        }
    }

    $estimatedFields = if ($sampleSize -gt 0 -and $sampleSize -lt $rows) {
        [int][Math]::Ceiling(($fieldCount / [double]$sampleSize) * $rows)
    } else {
        $fieldCount
    }
    $method = if ($sampleSize -lt $rows) { "$ModeName estimate from $sampleSize/$rows records" } else { "$ModeName exact preflight" }
    Set-JobEstimate -Rows $rows -Fields $estimatedFields -Tables $tableNames.Count -Method $method
    Set-ProgressRecordTarget -Path "root" -Label "Records"
}

function Add-JsonObjectArrayCounts {
    param(
        [AllowNull()]$Object,
        [string]$Prefix = "root",
        [hashtable]$Counts
    )

    if ($null -eq $Object) { return }

    if ($Object -is [PSCustomObject]) {
        $properties = $Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" }
        foreach ($prop in $properties) {
            Add-JsonObjectArrayCounts -Object $prop.Value -Prefix "$Prefix.$($prop.Name)" -Counts $Counts
        }
        return
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        foreach ($item in $Object) {
            if ($item -is [PSCustomObject]) {
                if (-not $Counts.ContainsKey($Prefix)) {
                    $Counts[$Prefix] = 0
                }
                $Counts[$Prefix]++
                Add-JsonObjectArrayCounts -Object $item -Prefix $Prefix -Counts $Counts
            }
        }
    }
}

function Get-JsonProgressTarget {
    param(
        [AllowNull()]$Json,
        [string[]]$MaskFields
    )

    $counts = @{}
    Add-JsonObjectArrayCounts -Object $Json -Prefix "root" -Counts $counts
    if ($counts.Count -eq 0) {
        return [PSCustomObject]@{
            Path  = "root"
            Count = 1
            Label = "Objects"
        }
    }

    $selectedFieldSet = @(Get-SelectedFieldSet -MaskFields $MaskFields).Keys
    $candidates = @(
        foreach ($path in $counts.Keys) {
            $normalizedPath = Normalize-FieldName $path
            $matchesSelection = $false
            foreach ($field in $selectedFieldSet) {
                if ($field -eq $normalizedPath -or $field.StartsWith("$normalizedPath.")) {
                    $matchesSelection = $true
                    break
                }
            }

            [PSCustomObject]@{
                Path             = $path
                Count            = [int]$counts[$path]
                MatchesSelection = $matchesSelection
            }
        }
    )

    $target = $candidates | Where-Object { $_.MatchesSelection } | Sort-Object Count -Descending | Select-Object -First 1
    if (-not $target) {
        $target = $candidates | Sort-Object Count -Descending | Select-Object -First 1
    }

    return [PSCustomObject]@{
        Path  = $target.Path
        Count = [Math]::Max(1, $target.Count)
        Label = (($target.Path -split '\.')[-1])
    }
}

function Set-JsonObjectJobEstimate {
    param(
        [AllowNull()]$Json,
        [string[]]$MaskFields,
        [string]$ModeName
    )

    $selectedFieldSet = Get-SelectedFieldSet -MaskFields $MaskFields
    $fieldCount = Count-MaskableFieldsInObject -Object $Json -Prefix "root" -SelectedFieldSet $selectedFieldSet
    $tableNames = @{}
    Add-EstimatedTableNamesFromObject -Object $Json -TableName "root" -TableNames $tableNames
    $target = Get-JsonProgressTarget -Json $Json -MaskFields $MaskFields
    Set-JobEstimate -Rows $target.Count -Fields $fieldCount -Tables $tableNames.Count -Method "$ModeName exact preflight; progress by $($target.Path)"
    Set-ProgressRecordTarget -Path $target.Path -Label $target.Label
}

function Set-CsvJobEstimate {
    param(
        [string]$InputFile,
        [string[]]$MaskFields,
        [int]$RowCount
    )

    $selectedFieldSet = Get-SelectedFieldSet -MaskFields $MaskFields
    $sampleLimit = if ($RowCount -le 1000) { $RowCount } else { [Math]::Min($RowCount, [Math]::Max(1000, [int][Math]::Ceiling($RowCount * 0.10))) }
    $sampledRows = 0
    $selectedColumns = 0
    $fieldCount = 0

    if ($sampleLimit -gt 0) {
        Import-Csv $InputFile -ErrorAction Stop | Select-Object -First $sampleLimit | ForEach-Object {
            $sampledRows++
            $properties = @($_.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" })
            if ($sampledRows -eq 1) {
                foreach ($prop in $properties) {
                    if (Test-EstimateFieldMatch -FieldName "root.$($prop.Name)" -SelectedFieldSet $selectedFieldSet) {
                        $selectedColumns++
                    }
                }
            }
            foreach ($prop in $properties) {
                if (Test-EstimateFieldMatch -FieldName "root.$($prop.Name)" -SelectedFieldSet $selectedFieldSet) {
                    $fieldCount++
                }
            }
        }
    }

    if ($sampledRows -eq 0) {
        $selectedColumns = @($MaskFields).Count
    }

    $estimatedFields = if ($sampledRows -gt 0 -and $sampledRows -lt $RowCount) {
        [int][Math]::Ceiling(($fieldCount / [double]$sampledRows) * $RowCount)
    } elseif ($sampledRows -gt 0) {
        $fieldCount
    } else {
        $RowCount * $selectedColumns
    }
    $method = if ($sampledRows -lt $RowCount) { "CSV estimate from $sampledRows/$RowCount rows" } else { "CSV exact preflight" }
    Set-JobEstimate -Rows $RowCount -Fields $estimatedFields -Tables 1 -Method $method
}

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
    param(
        [string]$FilePath,
        [string[]]$InitialSelected = @()
    )
    try {
        $fields = Get-CsvFields -FilePath $FilePath
        if (-not $fields -or $fields.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No fields found in CSV file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return [PSCustomObject]@{ Accepted = $true; Fields = @() }
        }
        
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Select Fields to Mask"
        $form.Size = New-Object System.Drawing.Size(500, 600)
        $form.StartPosition = "CenterScreen"
        $form.TopMost = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false

        $searchLabel = New-Object System.Windows.Forms.Label
        $searchLabel.Text = "Search:"
        $searchLabel.AutoSize = $true
        $searchLabel.Left = 10
        $searchLabel.Top = 10

        $searchBox = New-Object System.Windows.Forms.TextBox
        $searchBox.Left = 65
        $searchBox.Top = 8
        $searchBox.Width = 405
        
        $list = New-Object System.Windows.Forms.CheckedListBox
        $list.Left = 10
        $list.Top = 40
        $list.Width = 460
        $list.Height = 490
        $list.Sorted = $true
        $fieldSelectorState = Add-SearchableFieldSelectorBehavior -List $list -SearchBox $searchBox -Fields $fields -InitialSelected $InitialSelected -Owner $form
        
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
        $form.Controls.Add($searchLabel)
        $form.Controls.Add($searchBox)
        $form.Controls.Add($list)
        $form.Controls.Add($panel)
        
        $result = $form.ShowDialog()
        $selected = @()
        $accepted = $result -eq [System.Windows.Forms.DialogResult]::OK
        if ($accepted) {
            foreach ($field in $fieldSelectorState.Fields) {
                if ($fieldSelectorState.Checked.ContainsKey($field)) { $selected += $field }
            }
        }
        $form.Dispose()
        return [PSCustomObject]@{ Accepted = $accepted; Fields = @($selected) }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return [PSCustomObject]@{ Accepted = $false; Fields = @() }
    }
}

function Add-SearchableFieldSelectorBehavior {
    param(
        [System.Windows.Forms.CheckedListBox]$List,
        [System.Windows.Forms.TextBox]$SearchBox,
        [string[]]$Fields,
        [string[]]$InitialSelected = @(),
        [System.Windows.Forms.Form]$Owner
    )

    $checkedFields = @{}
    $available = @($Fields | Sort-Object -Unique)
    foreach ($field in @($InitialSelected)) {
        if ($available -contains $field) {
            $checkedFields[$field] = $true
        }
    }

    $promptState = @{
        Fields = $available
        Checked = $checkedFields
        Asked = @{}
        Suppress = $false
        List = $List
        SearchBox = $SearchBox
        Owner = $Owner
    }
    $List.Tag = $promptState
    $SearchBox.Tag = $promptState

    $refreshList = {
        param($sender, $eventArgs)

        $state = if ($null -ne $sender) { $sender.Tag } else { $null }
        if ($null -eq $state) { return }

        $currentList = $state.List
        $query = $state.SearchBox.Text
        $state.Suppress = $true
        try {
            $currentList.BeginUpdate()
            $currentList.Items.Clear()
            foreach ($field in $state.Fields) {
                if ([string]::IsNullOrWhiteSpace($query) -or $field.IndexOf($query, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $index = $currentList.Items.Add($field)
                    if ($state.Checked.ContainsKey($field)) {
                        $currentList.SetItemChecked($index, $true)
                    }
                }
            }
        }
        finally {
            $currentList.EndUpdate()
            $state.Suppress = $false
        }
    }

    $List.Add_ItemCheck({
        param($sender, $eventArgs)

        $state = $sender.Tag
        if ($null -eq $state -or $state.Suppress) {
            return
        }

        $selectedField = [string]$sender.Items[$eventArgs.Index]
        if ($eventArgs.NewValue -eq [System.Windows.Forms.CheckState]::Checked) {
            $state.Checked[$selectedField] = $true
        } else {
            $state.Checked.Remove($selectedField)
            return
        }

        $leafName = ($selectedField -split '\.')[-1]
        if ([string]::IsNullOrWhiteSpace($leafName) -or $state.Asked.ContainsKey($leafName)) {
            return
        }

        $matches = @()
        foreach ($candidate in $state.Fields) {
            $candidateLeaf = ($candidate -split '\.')[-1]
            if ($candidate -ne $selectedField -and $candidateLeaf -eq $leafName -and -not $state.Checked.ContainsKey($candidate)) {
                $matches += $candidate
            }
        }

        if ($matches.Count -eq 0) {
            return
        }

        $state.Asked[$leafName] = $true
        $message = "The field '$leafName' also appears in $($matches.Count) other place(s). Select all matching '$leafName' fields?"
        $answer = [System.Windows.Forms.MessageBox]::Show(
            $state.Owner,
            $message,
            "Select matching fields?",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($answer -eq [System.Windows.Forms.DialogResult]::Yes) {
            $state.Suppress = $true
            try {
                foreach ($match in $matches) {
                    $state.Checked[$match] = $true
                    $visibleIndex = $sender.Items.IndexOf($match)
                    if ($visibleIndex -ge 0) {
                        $sender.SetItemChecked($visibleIndex, $true)
                    }
                }
            }
            finally {
                $state.Suppress = $false
            }
        }
    })

    $SearchBox.Add_TextChanged($refreshList)
    & $refreshList $SearchBox $null
    return $promptState
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
        if ($normalized -ceq $normalizedMask) {
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

function Add-MappingRow {
    param($Original, $Masked, $Field, $RowIndex = $null)

    $row = [PSCustomObject]@{
        Original = $Original
        Masked   = $Masked
        Field    = $Field
        RowIndex = $RowIndex
    }

    if ($script:MappingWithRows -is [System.Collections.IList]) {
        $script:MappingWithRows.Add($row) | Out-Null
    } else {
        $script:MappingWithRows += $row
    }
}

function Mask-IfNeeded {
    param($FieldName, $Value, $RowIndex = $null)
    if (Should-MaskField $FieldName) {
        $script:MaskedFieldsProcessed++
        $strVal = [string]$Value
        $normalizedField = Normalize-FieldName $FieldName
        if (-not $script:Mapping.ContainsKey($strVal)) {
            $script:Mapping[$strVal] = @{
                Masked = Get-MaskedValue $strVal $script:SecretKey
                Field = $normalizedField
            }
            Write-MaskLog -Field $normalizedField -OriginalValue $strVal -MaskedValue $script:Mapping[$strVal].Masked
        }
        
        Add-MappingRow -Original $strVal -Masked $script:Mapping[$strVal].Masked -Field $normalizedField -RowIndex $RowIndex
        
        return $script:Mapping[$strVal].Masked
    }
    return $Value
}

function Apply-Masking-ToObject {
    param($Object, [string]$Prefix = "root")
    
    if ($Object -is [PSCustomObject]) {
        if ($Prefix -eq $script:ProgressRecordPath) {
            $script:ProcessedLines++
            Update-ProcessingProgress -Current $script:ProcessedLines -Total $script:TotalLines -Phase "Masking JSON" -Detail "$($script:ProgressRecordLabel) $($script:ProcessedLines) of $($script:TotalLines)"
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

function New-TableRowId {
    param([string]$TableName)

    if (-not $script:TableIdCounters.ContainsKey($TableName)) {
        $script:TableIdCounters[$TableName] = 0
    }
    $script:TableIdCounters[$TableName]++

    $idSource = "$TableName|$($script:TableIdCounters[$TableName])"
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($idSource))
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "").Substring(0, 8)
    }
    finally {
        $sha.Dispose()
    }
}

function Process-MaskedObject {
    param($Object, [string]$TableName = "root", [hashtable]$IdMap = @{})
    if ($null -eq $Object) { return }
    
    $tableSuffix = Get-TableNameFromPath $TableName
    $currentIdKey = "${tableSuffix}_id"
    $currentId = New-TableRowId -TableName $TableName
    
    Write-VerboseLog "Processing table: $TableName (ID: $currentId)"
    
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
            $itemCount = 0
            foreach ($item in $value) {
                if ($item -is [PSCustomObject]) {
                    $itemCount++
                    $newIdMap = $IdMap.Clone()
                    $newIdMap[$currentIdKey] = $currentId
                    Process-MaskedObject -Object $item -TableName "${TableName}_$name" -IdMap $newIdMap
                }
            }
            if ($itemCount -gt 0) {
                Write-VerboseLog "  Found $itemCount nested objects in field: $name"
            }
        }
        else {
            $row[$name] = $value
        }
    }
    
    if ($row.Count -gt 0) {
        if (-not $script:Tables.ContainsKey($TableName)) {
            $script:Tables[$TableName] = @()
            $script:TablesProduced++  # INCREMENT counter when new table is created
            Write-VerboseLog "  Created new table: $TableName with $($row.Count) fields"
        }
        $script:Tables[$TableName] += [PSCustomObject]$row
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

function Test-SocrataJson {
    param($Json)
    return (
        $null -ne $Json -and
        $null -ne $Json.PSObject.Properties["meta"] -and
        $null -ne $Json.meta.PSObject.Properties["view"] -and
        $null -ne $Json.meta.view.PSObject.Properties["columns"] -and
        $null -ne $Json.PSObject.Properties["data"] -and
        $Json.data -is [System.Collections.IEnumerable]
    )
}

function Get-SocrataColumns {
    param($Json)

    $columns = @()
    foreach ($column in @($Json.meta.view.columns)) {
        $name = if ($column.PSObject.Properties["name"]) { [string]$column.name } else { $null }
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $fieldName = if ($column.PSObject.Properties["fieldName"]) { [string]$column.fieldName } else { $name }
        $columns += [PSCustomObject]@{
            Name      = $name
            FieldName = $fieldName
        }
    }

    return @($columns)
}

function Get-SocrataJsonFields {
    param([string]$FilePath)

    try {
        $json = Get-Content $FilePath -Raw | ConvertFrom-Json
    }
    catch {
        return $null
    }
    if (-not (Test-SocrataJson $json)) { return $null }

    return @(Get-SocrataColumns $json | ForEach-Object { "root.$($_.Name)" })
}

function Get-VisibleJsonProperties {
    param($Object)

    return @($Object.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" })
}

function Get-JsonRecordCollectionInfo {
    param($Json)

    if ($null -eq $Json -or $Json -isnot [PSCustomObject]) { return $null }

    if ($Json.PSObject.Properties["type"] -and $Json.type -eq "FeatureCollection" -and $Json.PSObject.Properties["features"] -and $Json.features -is [System.Collections.IEnumerable]) {
        return [PSCustomObject]@{
            Format = "GeoJSON"
            Path   = "features"
            Records = @($Json.features)
        }
    }

    foreach ($propertyName in @("data", "results", "items", "records")) {
        $property = $Json.PSObject.Properties[$propertyName]
        if ($null -ne $property -and $property.Value -is [System.Collections.IEnumerable] -and $property.Value -isnot [string]) {
            $records = @($property.Value)
            if ($records.Count -gt 0 -and $records[0] -is [PSCustomObject]) {
                return [PSCustomObject]@{
                    Format = "Envelope JSON"
                    Path   = $propertyName
                    Records = $records
                }
            }
        }
    }

    return $null
}

function Test-HeaderArrayJson {
    param($Json)

    if ($Json -isnot [System.Collections.IEnumerable] -or $Json -is [string]) { return $false }
    $rows = @($Json)
    if ($rows.Count -lt 2) { return $false }
    $header = @($rows[0])
    if ($header.Count -eq 0) { return $false }

    foreach ($value in $header) {
        if ([string]::IsNullOrWhiteSpace([string]$value)) { return $false }
    }

    return ($rows[1] -is [System.Collections.IEnumerable] -and $rows[1] -isnot [string])
}

function Convert-HeaderArrayRowsToObjects {
    param($Rows)

    $rowArray = @($Rows)
    if ($rowArray.Count -lt 2) { return @() }

    $headers = @($rowArray[0] | ForEach-Object { [string]$_ })
    $objects = New-Object System.Collections.ArrayList

    for ($rowIndex = 1; $rowIndex -lt $rowArray.Count; $rowIndex++) {
        $values = @($rowArray[$rowIndex])
        $obj = [ordered]@{}
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $obj[$headers[$i]] = if ($i -lt $values.Count) { $values[$i] } else { $null }
        }
        $objects.Add([PSCustomObject]$obj) | Out-Null
    }

    return @($objects)
}

function Read-LooseJsonRecords {
    param([string]$FilePath)

    $records = New-Object System.Collections.ArrayList
    $lines = Get-Content -Path $FilePath
    $nonEmptyLines = @($lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($nonEmptyLines.Count -eq 0) { return @() }

    $lineModeSucceeded = $true
    foreach ($line in $nonEmptyLines) {
        $trimmed = $line.Trim().TrimEnd(',')
        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        try {
            $records.Add(($trimmed | ConvertFrom-Json)) | Out-Null
        }
        catch {
            $lineModeSucceeded = $false
            break
        }
    }

    if ($lineModeSucceeded -and $records.Count -gt 0) {
        return @($records)
    }

    $raw = Get-Content -Path $FilePath -Raw
    foreach ($candidate in @("[$raw]", "[$($raw.Trim().Trim(','))]")) {
        try {
            $parsed = $candidate | ConvertFrom-Json
            if ($parsed -is [System.Collections.IEnumerable] -and $parsed -isnot [string]) {
                return @($parsed)
            }
            return @($parsed)
        }
        catch {}
    }

    $splitRecords = New-Object System.Collections.ArrayList
    $depth = 0
    $start = -1
    $inString = $false
    $escaped = $false

    for ($i = 0; $i -lt $raw.Length; $i++) {
        $ch = $raw[$i]

        if ($inString) {
            if ($escaped) {
                $escaped = $false
            }
            elseif ($ch -eq '\') {
                $escaped = $true
            }
            elseif ($ch -eq '"') {
                $inString = $false
            }
            continue
        }

        if ($ch -eq '"') {
            $inString = $true
            continue
        }

        if ($ch -eq '{') {
            if ($depth -eq 0) { $start = $i }
            $depth++
        }
        elseif ($ch -eq '}') {
            $depth--
            if ($depth -eq 0 -and $start -ge 0) {
                $jsonText = $raw.Substring($start, $i - $start + 1)
                $splitRecords.Add(($jsonText | ConvertFrom-Json)) | Out-Null
                $start = -1
            }
        }
    }

    if ($splitRecords.Count -gt 0) {
        return @($splitRecords)
    }

    throw "JSON is not a supported loose record format. Expected NDJSON, comma-separated objects, or concatenated JSON objects."
}

function Invoke-JsonRecordsMasking {
    param(
        [object[]]$Records,
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string]$ModeName,
        [string[]]$MaskFields,
        [string]$OutputFormat = "JsonArray"
    )

    Write-StatusPanel -Mode $ModeName -Phase "Preparing" -Current 0 -Total $Records.Count -Detail "Detected record collection" -Mask "" -Force

    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
    }

    $script:TotalLines = $Records.Count
    $script:ProcessedLines = 0
    $script:InputWasJson = $true
    Set-JsonRecordJobEstimate -Records $Records -MaskFields $MaskFields -ModeName $ModeName
    Write-JobEstimateStatus -Mode $ModeName
    if ($progressBar) {
        $progressBar.Maximum = [Math]::Max(1, $script:TotalLines)
    }

    $maskedItems = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $Records.Count; $i++) {
        $maskedItems.Add((Apply-Masking-ToObject $Records[$i])) | Out-Null
    }

    $script:MaskedData = @($maskedItems)
    $script:Tables = New-OrdinalHashtable
    $script:TablesProduced = 0
    Set-GuiProgressStage -Bar $normalizeProgressBar -Current 1 -Total 100 -Force
    foreach ($item in @($script:MaskedData)) {
        Process-MaskedObject -Object $item -TableName "root" -IdMap @{}
    }
    Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force

    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    if ($OutputFormat -eq "Ndjson") {
        $jsonOutputPath = Join-Path $OutputFolder "${inputFileName}_masked.ndjson"
        $writer = $null
        try {
            $writer = New-Object System.IO.StreamWriter($jsonOutputPath, $false, (New-Object System.Text.UTF8Encoding($false)))
            foreach ($item in @($script:MaskedData)) {
                $writer.WriteLine((ConvertTo-Json -InputObject $item -Compress -Depth 100))
            }
        }
        finally {
            if ($writer) { $writer.Dispose() }
        }
    } else {
        $jsonOutputPath = Join-Path $OutputFolder "${inputFileName}_masked.json"
        ConvertTo-Json -InputObject @($script:MaskedData) -Depth 100 | Out-File -FilePath $jsonOutputPath -Encoding UTF8 -Force
    }
}

function Invoke-HeaderArrayJsonMasking {
    param(
        $Json,
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string[]]$MaskFields
    )

    $records = @(Convert-HeaderArrayRowsToObjects $Json)
    Invoke-JsonRecordsMasking -Records $records -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -ModeName "Header Array JSON" -MaskFields $MaskFields
}

function Complete-MaskingOutputs {
    param(
        [string]$OutputFolder,
        [string]$KeyFile,
        [string]$InputFile,
        [string]$SecretKey,
        [string[]]$MaskFields,
        [switch]$SkipReplicationScript
    )

    Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
    $exportStep = 0
    $exportTotal = [Math]::Max(1, $script:Tables.Keys.Count + 2)

    foreach ($tableName in $script:Tables.Keys) {
        $name = if ($tableName -eq "root") { "data" } else { $tableName.Replace("root_", "") }
        $path = Join-Path $OutputFolder "$name.csv"
        $rowCount = (Convert-RowsForCsvExport -Rows @($script:Tables[$tableName])).Count
        Write-StatusPanel -Phase "Exporting CSV" -Detail "Writing $name.csv ($rowCount rows)" -Force
        Convert-RowsForCsvExport -Rows @($script:Tables[$tableName]) | Export-Csv -NoTypeInformation -Path $path -Force -Encoding UTF8
        $exportStep++
        Set-GuiProgressStage -Bar $exportProgressBar -Current $exportStep -Total $exportTotal -Force
    }
    
    Write-StatusPanel -Phase "Finalizing" -Detail "Writing masking key" -Force
    Export-MaskingKey -KeyFile $KeyFile
    $exportStep++
    Set-GuiProgressStage -Bar $exportProgressBar -Current $exportStep -Total $exportTotal -Force
    
    if (-not $SkipReplicationScript) {
        Generate-ReplicationScript -OutputFolder $OutputFolder -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
    }
    $exportStep++
    Set-GuiProgressStage -Bar $exportProgressBar -Current $exportStep -Total $exportTotal -Force
    Sync-TableEstimateWithProduced
    Write-StatusPanel -Phase "Complete" -Current $script:ProcessedLines -Total $script:TotalLines -Detail "Tables: $($script:Tables.Keys.Count); unique masked values: $($script:Mapping.Count); fields masked: $($script:MaskedFieldsProcessed) (est ~$($script:EstimatedFieldsToMask))" -Force
}

function Export-MaskingKey {
    param([string]$KeyFile)

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
}

function Get-ReplicationToolSourceText {
    if (-not [string]::IsNullOrWhiteSpace($script:BundledSourceGzipBase64)) {
        $compressedBytes = [Convert]::FromBase64String($script:BundledSourceGzipBase64)
        $inputStream = New-Object System.IO.MemoryStream(,$compressedBytes)
        $gzipStream = $null
        $reader = $null
        try {
            $gzipStream = New-Object System.IO.Compression.GZipStream($inputStream, [System.IO.Compression.CompressionMode]::Decompress)
            $reader = New-Object System.IO.StreamReader($gzipStream, [System.Text.Encoding]::UTF8)
            return $reader.ReadToEnd()
        }
        finally {
            if ($reader) { $reader.Dispose() }
            elseif ($gzipStream) { $gzipStream.Dispose() }
            if ($inputStream) { $inputStream.Dispose() }
        }
    }

    $candidatePaths = @()
    if (-not [string]::IsNullOrWhiteSpace($PSCommandPath)) {
        $candidatePaths += $PSCommandPath
    }
    if ($MyInvocation.MyCommand.Path) {
        $candidatePaths += $MyInvocation.MyCommand.Path
    }
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $candidatePaths += (Join-Path $PSScriptRoot "DataMaskingTool.ps1")
    }
    $candidatePaths += (Join-Path (Get-Location) "DataMaskingTool.ps1")

    foreach ($candidate in @($candidatePaths | Select-Object -Unique)) {
        if (
            -not [string]::IsNullOrWhiteSpace($candidate) -and
            (Test-Path -LiteralPath $candidate) -and
            ([System.IO.Path]::GetExtension($candidate) -ieq ".ps1")
        ) {
            return Get-Content -LiteralPath $candidate -Raw -ErrorAction Stop
        }
    }

    throw "Unable to locate or decode DataMaskingTool.ps1 for replication output."
}

function Export-ReplicationToolSource {
    param([string]$OutputFolder)

    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
    }

    $sourceText = Get-ReplicationToolSourceText
    $sourcePath = Join-Path $OutputFolder "DataMaskingTool.ps1"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($sourcePath, $sourceText, $utf8NoBom)
}

function ConvertTo-CsvLine {
    param([object[]]$Values)

    $escaped = foreach ($value in $Values) {
        if ($null -eq $value) {
            '""'
        } else {
            '"' + ([string]$value).Replace('"', '""') + '"'
        }
    }

    return ($escaped -join ',')
}

function Invoke-SocrataJsonMasking {
    param(
        $Json,
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string[]]$MaskFields
    )

    Write-StatusPanel -Mode "Socrata JSON" -Phase "Preparing" -Current 0 -Total 0 -Detail "Detected indexed row-array JSON" -Mask "" -Force

    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
    }

    $columns = @(Get-SocrataColumns $Json)
    $maskIndexes = @{}
    for ($i = 0; $i -lt $columns.Count; $i++) {
        $namePath = "root.$($columns[$i].Name)"
        $fieldPath = "root.$($columns[$i].FieldName)"
        foreach ($maskField in $MaskFields) {
            $normalizedMask = Normalize-FieldName $maskField
            if ((Normalize-FieldName $namePath) -eq $normalizedMask -or (Normalize-FieldName $fieldPath) -eq $normalizedMask) {
                $maskIndexes[$i] = $namePath
                break
            }
        }
    }

    $script:TotalLines = @($Json.data).Count
    $script:ProcessedLines = 0
    $script:TablesProduced = 1
    $script:InputWasJson = $true
    $script:MaskedData = $null
    $script:OriginalData = $null
    Set-JobEstimate -Rows $script:TotalLines -Fields ($script:TotalLines * $maskIndexes.Count) -Tables 1 -Method "Socrata exact column preflight"
    Write-JobEstimateStatus -Mode "Socrata JSON"

    if ($progressBar) {
        $progressBar.Maximum = [Math]::Max(1, $script:TotalLines)
    }
    Write-StatusPanel -Current 0 -Total $script:TotalLines -Detail "Opening output writers" -Force

    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $jsonOutputPath = Join-Path $OutputFolder "${inputFileName}_masked.json"
    $csvOutputPath = Join-Path $OutputFolder "data.csv"
    $dataRows = @($Json.data)

    $jsonWriter = $null
    $csvWriter = $null
    try {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $jsonWriter = New-Object System.IO.StreamWriter($jsonOutputPath, $false, $utf8NoBom)
        $csvWriter = New-Object System.IO.StreamWriter($csvOutputPath, $false, $utf8NoBom)

        $csvWriter.WriteLine((ConvertTo-CsvLine -Values $columns.Name))

        $jsonWithoutData = $Json | Select-Object -Property * -ExcludeProperty data
        $jsonPrefix = ($jsonWithoutData | ConvertTo-Json -Depth 100).TrimEnd()
        if ($jsonPrefix.EndsWith("}")) {
            $jsonPrefix = $jsonPrefix.Substring(0, $jsonPrefix.Length - 1).TrimEnd()
        }
        $jsonWriter.Write($jsonPrefix)
        if (-not $jsonPrefix.EndsWith("{")) {
            $jsonWriter.WriteLine(",")
        }
        $jsonWriter.WriteLine('  "data": [')

        $firstRow = $true
        $rowIndex = 0
        foreach ($row in $dataRows) {
            $rowValues = @($row)
            for ($i = 0; $i -lt $rowValues.Count; $i++) {
                if ($maskIndexes.ContainsKey($i)) {
                    $rowValues[$i] = Mask-IfNeeded $maskIndexes[$i] $rowValues[$i] $rowIndex
                }
            }

            if (-not $firstRow) {
                $jsonWriter.WriteLine(",")
            }
            $jsonWriter.Write("    ")
            $jsonWriter.Write((ConvertTo-Json -InputObject $rowValues -Compress -Depth 20))
            $firstRow = $false

            $csvWriter.WriteLine((ConvertTo-CsvLine -Values $rowValues))

            $rowIndex++
            $script:ProcessedLines = $rowIndex
            Update-ProcessingProgress -Current $script:ProcessedLines -Total $script:TotalLines -Phase "Masking Socrata JSON" -Detail "Writing data.csv and masked JSON"
        }

        $jsonWriter.WriteLine()
        $jsonWriter.WriteLine("  ]")
        $jsonWriter.WriteLine("}")
    }
    finally {
        if ($jsonWriter) { $jsonWriter.Dispose() }
        if ($csvWriter) { $csvWriter.Dispose() }
    }

    Export-MaskingKey -KeyFile $KeyFile
    Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
    Set-GuiProgressStage -Bar $exportProgressBar -Current 100 -Total 100 -Force
    Sync-TableEstimateWithProduced
    Write-StatusPanel -Phase "Complete" -Current $script:ProcessedLines -Total $script:TotalLines -Detail "Wrote data.csv, masked JSON, and masking key; fields masked: $($script:MaskedFieldsProcessed) (est ~$($script:EstimatedFieldsToMask))" -Force
}

function Invoke-CsvMaskingFast {
    param(
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string]$SecretKey,
        [string[]]$MaskFields
    )

    Write-StatusPanel -Mode "CSV" -Phase "Loading" -Current 0 -Total 0 -Detail "Counting rows" -Mask "" -Force

    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
    }

    $lineCount = ([System.IO.File]::ReadLines($InputFile) | Measure-Object).Count
    $script:TotalLines = [Math]::Max(0, $lineCount - 1)
    $script:ProcessedLines = 0
    $script:TablesProduced = 1
    $script:MaskedData = $null
    $script:OriginalData = $null
    $script:Tables = New-OrdinalHashtable

    Set-CsvJobEstimate -InputFile $InputFile -MaskFields $MaskFields -RowCount $script:TotalLines
    Write-JobEstimateStatus -Mode "CSV"

    if ($progressBar) {
        $progressBar.Maximum = [Math]::Max(1, $script:TotalLines)
    }

    $csvOutputPath = Join-Path $OutputFolder "data.csv"
    $writer = $null
    $headers = $null

    try {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $writer = New-Object System.IO.StreamWriter($csvOutputPath, $false, $utf8NoBom)

        Import-Csv $InputFile -ErrorAction Stop | ForEach-Object {
            if ($null -eq $headers) {
                $headers = @($_.PSObject.Properties | Where-Object { -not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot" } | Select-Object -ExpandProperty Name)
                $writer.WriteLine((ConvertTo-CsvLine -Values $headers))
                Write-StatusPanel -Phase "Masking CSV" -Current 0 -Total $script:TotalLines -Detail "Writing data.csv" -Force
            }

            $rowValues = New-Object object[] $headers.Count
            for ($i = 0; $i -lt $headers.Count; $i++) {
                $name = $headers[$i]
                $rowValues[$i] = Mask-IfNeeded "root.$name" $_.$name $script:ProcessedLines
            }

            $writer.WriteLine((ConvertTo-CsvLine -Values $rowValues))
            $script:ProcessedLines++
            Update-ProcessingProgress -Current $script:ProcessedLines -Total $script:TotalLines -Phase "Masking CSV" -Detail "Writing data.csv"
        }
    }
    finally {
        if ($writer) { $writer.Dispose() }
    }

    Write-StatusPanel -Phase "Finalizing" -Detail "Writing masking key" -Force
    Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
    Set-GuiProgressStage -Bar $exportProgressBar -Current 1 -Total 2 -Force
    Export-MaskingKey -KeyFile $KeyFile
    Generate-ReplicationScript -OutputFolder $OutputFolder -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
    Set-GuiProgressStage -Bar $exportProgressBar -Current 2 -Total 2 -Force
    Sync-TableEstimateWithProduced
    Write-StatusPanel -Phase "Complete" -Current $script:ProcessedLines -Total $script:TotalLines -Detail "Wrote data.csv and masking key; fields masked: $($script:MaskedFieldsProcessed) (est ~$($script:EstimatedFieldsToMask))" -Force
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
    $script:Mapping = New-OrdinalHashtable
    $script:MappingWithRows = New-Object System.Collections.ArrayList
    $script:Tables = New-OrdinalHashtable
    $script:TableIdCounters = New-OrdinalHashtable
    $script:ProcessedLines = 0
    $script:TablesProduced = 0
    $script:InputWasJson = $false
    Reset-JobEstimate
    Reset-GuiProgressStages
    
    $ext = [System.IO.Path]::GetExtension($InputFile).ToLower()
    
    if ($ext -eq ".json") {
        Write-StatusPanel -Mode "JSON" -Phase "Loading" -Current 0 -Total 0 -Detail "Reading input file" -Mask "" -Force
        
        $json = $null
        try {
            $json = Read-JsonFileWithLoadProgress -Path $InputFile
        }
        catch {
            Write-StatusPanel -Mode "Loose JSON" -Phase "Parsing" -Current 0 -Total 0 -Detail "Trying NDJSON / loose object records" -Mask "" -Force
            $records = @(Read-LooseJsonRecords -FilePath $InputFile)
            Invoke-JsonRecordsMasking -Records $records -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -ModeName "Loose JSON" -MaskFields $MaskFields -OutputFormat "Ndjson"
            Complete-MaskingOutputs -OutputFolder $OutputFolder -KeyFile $KeyFile -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
            return
        }
        $script:InputWasJson = $true
        $script:OriginalData = $json

        if (Test-SocrataJson $json) {
            Invoke-SocrataJsonMasking -Json $json -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -MaskFields $MaskFields
            Generate-ReplicationScript -OutputFolder $OutputFolder -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
            return
        }

        $recordCollection = Get-JsonRecordCollectionInfo $json

        if (Test-HeaderArrayJson $json) {
            Invoke-HeaderArrayJsonMasking -Json $json -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -MaskFields $MaskFields
            Complete-MaskingOutputs -OutputFolder $OutputFolder -KeyFile $KeyFile -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
            return
        }

        $recordCollection = Get-JsonRecordCollectionInfo $json
        if ($null -ne $recordCollection) {
            Invoke-JsonRecordsMasking -Records @($recordCollection.Records) -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -ModeName $recordCollection.Format -MaskFields $MaskFields
            Complete-MaskingOutputs -OutputFolder $OutputFolder -KeyFile $KeyFile -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
            return
        }
        
        # Detect if JSON is an array or a single object
        $isArray = $false
        if ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
            $isArray = $true
            $jsonElementCount = @($json).Count
            Write-StatusPanel -Phase "Loaded JSON" -Current 0 -Total $jsonElementCount -Detail "Array with $jsonElementCount elements" -Force
        } else {
            Write-StatusPanel -Phase "Loaded JSON" -Current 0 -Total 1 -Detail "Single object" -Force
        }

        Set-JsonObjectJobEstimate -Json $json -MaskFields $MaskFields -ModeName "JSON"
        Write-JobEstimateStatus -Mode "JSON"

        if ($progressBar) {
            $progressBar.Maximum = [Math]::Max(1, $script:TotalLines)
        }
        
        if ($isArray) {
            # FIX: Collect all items into an array explicitly
            $maskedItems = @()
            foreach ($item in $json) { 
                $maskedItems += Apply-Masking-ToObject $item 
            }
            $script:MaskedData = $maskedItems
        } else {
            Write-StatusPanel -Phase "Masking JSON" -Current 0 -Total 1 -Detail "Processing single object" -Force
            $script:MaskedData = @(@(Apply-Masking-ToObject $json))
        }
        
        Write-StatusPanel -Phase "Normalizing" -Detail "Generating CSV tables from masked JSON" -Force
        Set-GuiProgressStage -Bar $normalizeProgressBar -Current 1 -Total 100 -Force
        
        if ($script:MaskedData -is [System.Collections.IEnumerable] -and $script:MaskedData -isnot [string]) {
            $maskedArray = @($script:MaskedData)
            $script:Tables = New-OrdinalHashtable  # Reset tables
            $script:TablesProduced = 0  # Reset counter BEFORE processing
            foreach ($item in $maskedArray) {
                Process-MaskedObject -Object $item -TableName "root" -IdMap @{}
            }
            Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
        } else {
            $script:Tables = New-OrdinalHashtable  # Reset tables
            $script:TablesProduced = 0  # Reset counter BEFORE processing
            Process-MaskedObject -Object $script:MaskedData -TableName "root" -IdMap @{}
            Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
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
        Invoke-CsvMaskingFast -InputFile $InputFile -OutputFolder $OutputFolder -KeyFile $KeyFile -SecretKey $SecretKey -MaskFields $MaskFields
        return
    }
    
    Complete-MaskingOutputs -OutputFolder $OutputFolder -KeyFile $KeyFile -InputFile $InputFile -SecretKey $SecretKey -MaskFields $MaskFields
}

function Generate-ReplicationScript {
    param(
        [string]$OutputFolder,
        [string]$InputFile,
        [string]$SecretKey,
        [string[]]$MaskFields
    )
    
    Export-ReplicationToolSource -OutputFolder $OutputFolder

    $maskFieldsList = @()
    foreach ($field in $MaskFields) {
        $maskFieldsList += "'" + ([string]$field).Replace("'", "''") + "'"
    }
    $maskFieldsForScript = $maskFieldsList -join ','
    $inputFileForScript = "'" + ([string]$InputFile).Replace("'", "''") + "'"
    $secretKeyForScript = "'" + ([string]$SecretKey).Replace("'", "''") + "'"
    
$scriptContent = @"
# Replicate a Flat & Mask masking run.
#
# IMPORTANT:
# - This script is intentionally a thin wrapper around DataMaskingTool.ps1.
# - Put DataMaskingTool.ps1 in the same directory as this replicate_masking.ps1 file.
# - The wrapper loads DataMaskingTool.ps1 without opening the GUI, then calls Invoke-Masking.
# - This avoids maintaining a second masking implementation inside this generated script.
#
# Git reference for DataMaskingTool.ps1:
# - Repository: $($script:RepoUrl)
# - Source file: $($script:RepoUrl)/blob/main/DataMaskingTool.ps1
#
# License and disclaimers:
# - MIT License, Copyright (c) 2026 Design Effects, LLC.
# - NO WARRANTY: This tool is provided as-is, without warranty of any kind.
# - THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# - IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#   DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
#   USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Example:
#   powershell -ExecutionPolicy Bypass -File .\replicate_masking.ps1 -InputFile .\input.json -OutputFolder .\masked_output

param(
    [string]`$InputFile = $inputFileForScript,
    [string]`$OutputFolder = "`$PSScriptRoot",
    [string]`$SecretKey = $secretKeyForScript
)

if ([string]::IsNullOrWhiteSpace(`$InputFile)) {
    throw "Provide -InputFile when running replicate_masking.ps1. Example: powershell -ExecutionPolicy Bypass -File .\replicate_masking.ps1 -InputFile .\input.json"
}

if (-not (Test-Path -LiteralPath `$InputFile)) {
    throw "The input file could not be found: `$InputFile. If the original file moved, rerun with -InputFile pointing to the current file path."
}

`$MaskFields = @($maskFieldsForScript)
`$replicationInputFile = `$InputFile
`$replicationOutputFolder = `$OutputFolder
`$replicationSecretKey = `$SecretKey

Write-Host "Replicating masking operation..."
Write-Host "Input: `$replicationInputFile"
Write-Host "Output: `$replicationOutputFolder"

`$toolPath = Join-Path `$PSScriptRoot "DataMaskingTool.ps1"
if (-not (Test-Path -LiteralPath `$toolPath)) {
    throw "DataMaskingTool.ps1 must be in the same directory as replicate_masking.ps1. Download it from $($script:RepoUrl)/blob/main/DataMaskingTool.ps1."
}

`$toolText = Get-Content -LiteralPath `$toolPath -Raw -ErrorAction Stop
`$guiMarker = '# ====================' + ' Main GUI ' + '===================='
`$markerIndex = `$toolText.IndexOf(`$guiMarker)
if (`$markerIndex -lt 0) {
    throw "Unable to find the GUI marker in DataMaskingTool.ps1. Make sure this script is paired with the matching Flat & Mask source file."
}

Invoke-Expression `$toolText.Substring(0, `$markerIndex)

`$keyFile = Join-Path `$replicationOutputFolder "masking_key.csv"
Invoke-Masking -InputFile `$replicationInputFile -OutputFolder `$replicationOutputFolder -KeyFile `$keyFile -SecretKey `$replicationSecretKey -MaskFields `$MaskFields

Write-Host "Replication complete!" -ForegroundColor Green
Write-Host "Output: `$replicationOutputFolder"
"@
    
    $scriptPath = Join-Path $OutputFolder "replicate_masking.ps1"
    $scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
}

# ==================== Tree Viewer ====================
function Show-TreeViewer {
    param([string]$JsonFilePath)
    try {
        $json = $null
        try {
            $json = Get-Content $JsonFilePath -Raw | ConvertFrom-Json
        }
        catch {
            $json = @(Read-LooseJsonRecords -FilePath $JsonFilePath)
        }
        
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
        
        if (Test-HeaderArrayJson $json) {
            foreach ($header in @(@($json)[0])) {
                $path = "root.$([string]$header)"
                $allPaths.Add($path) | Out-Null
                $node = New-Object System.Windows.Forms.TreeNode
                $node.Text = [string]$header
                $node.Tag = $path
                $tree.Nodes.Add($node) | Out-Null
            }
        }
        elseif ($null -ne $recordCollection) {
            if (@($recordCollection.Records).Count -gt 0) {
                BuildTreeNode -Object @($recordCollection.Records)[0] -Prefix "root"
            }
        }
        elseif ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
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
$mainForm.Size = New-Object System.Drawing.Size(700, 900)
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

$loadProgressBar = New-Object System.Windows.Forms.ProgressBar
$loadProgressBar.Left = 20
$loadProgressBar.Top = 368
$loadProgressBar.Width = 480
$loadProgressBar.Height = 10
$loadProgressBar.Value = 0
$loadProgressBar.Maximum = 100

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Left = 20
$progressBar.Top = 382
$progressBar.Width = 480
$progressBar.Height = 10
$progressBar.Value = 0
$progressBar.Maximum = 100

$normalizeProgressBar = New-Object System.Windows.Forms.ProgressBar
$normalizeProgressBar.Left = 20
$normalizeProgressBar.Top = 396
$normalizeProgressBar.Width = 480
$normalizeProgressBar.Height = 10
$normalizeProgressBar.Value = 0
$normalizeProgressBar.Maximum = 100

$exportProgressBar = New-Object System.Windows.Forms.ProgressBar
$exportProgressBar.Left = 20
$exportProgressBar.Top = 410
$exportProgressBar.Width = 480
$exportProgressBar.Height = 10
$exportProgressBar.Value = 0
$exportProgressBar.Maximum = 100

$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Left = 20
$buttonPanel.Top = 438
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
$statusLabel.Top = 500
$statusLabel.BorderStyle = "FixedSingle"

$guiLogBox = New-Object System.Windows.Forms.RichTextBox
$guiLogBox.ReadOnly = $true
$guiLogBox.Width = 660
$guiLogBox.Height = 150
$guiLogBox.Left = 20
$guiLogBox.Top = 540
$guiLogBox.BorderStyle = "FixedSingle"
$guiLogBox.BackColor = [System.Drawing.Color]::White
$guiLogBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$guiLogBox.WordWrap = $false

$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "NO WARRANTY: This tool is provided as-is, without warranty of any kind.`r`nCheck the Git repo for source and updates: $($script:RepoUrl)`r`n$($script:AuthorName) <$($script:AuthorEmail)>"
$footerLabel.AutoSize = $false
$footerLabel.Width = 500
$footerLabel.Height = 70
$footerLabel.Left = 20
$footerLabel.Top = 715
$footerLabel.Font = New-Object System.Drawing.Font("Arial", 11)

$repoButton = New-Object System.Windows.Forms.Button
$repoButton.Text = "Open Repo"
$repoButton.Width = 90
$repoButton.Height = 28
$repoButton.Left = 530
$repoButton.Top = 715

$updateButton = New-Object System.Windows.Forms.Button
$updateButton.Text = "Check for Update"
$updateButton.Width = 130
$updateButton.Height = 32
$updateButton.Left = 530
$updateButton.Top = 750

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

$repoButton.Add_Click({
    try {
        Start-Process $script:RepoUrl
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Repo URL:`r`n$($script:RepoUrl)", "Git Repository", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

$updateButton.Add_Click({
    $updateButton.Enabled = $false
    $previousStatus = $statusLabel.Text
    $statusLabel.Text = "Checking for updates..."
    $mainForm.Refresh()

    try {
        $updateStatus = Get-ToolUpdateStatus
        $statusLabel.Text = if ($updateStatus.Status -eq "UpdateAvailable") { "Update available" } elseif ($updateStatus.Status -eq "Current") { "No update found" } else { "Update check inconclusive" }
        $icon = if ($updateStatus.Status -eq "UpdateAvailable") { [System.Windows.Forms.MessageBoxIcon]::Information } elseif ($updateStatus.Status -eq "Error") { [System.Windows.Forms.MessageBoxIcon]::Warning } else { [System.Windows.Forms.MessageBoxIcon]::Information }
        [System.Windows.Forms.MessageBox]::Show($updateStatus.Message, "Update Check", [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
    }
    catch {
        $statusLabel.Text = $previousStatus
        [System.Windows.Forms.MessageBox]::Show("Could not check for updates: $($_.Exception.Message)`r`nCheck the repo manually: $($script:RepoUrl)", "Update Check", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
    finally {
        $updateButton.Enabled = $true
    }
})

$selectFieldsButton.Add_Click({
    if ($script:LastInputFile) {
        $ext = [System.IO.Path]::GetExtension($script:LastInputFile).ToLower()
        
        $selection = $null
        if ($ext -eq ".json") {
            $selection = Show-CheckboxForm -Fields (Get-JsonFields $script:LastInputFile) -InitialSelected $script:SelectedFields
        }
        elseif ($ext -eq ".csv") {
            $selection = Show-CsvFieldSelector -FilePath $script:LastInputFile -InitialSelected $script:SelectedFields
        }

        if ($null -eq $selection -or -not $selection.Accepted) {
            return
        }

        $selected = @($selection.Fields)
        
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
        
        Write-StatusPanel -Mode "Ready" -Phase "Fields selected" -Current 0 -Total 0 -Detail "Selected $($script:SelectedFields.Count) fields" -Mask "" -Force
        
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
    $socrataFields = Get-SocrataJsonFields -FilePath $FilePath
    if ($null -ne $socrataFields) {
        return @($socrataFields | Sort-Object -Unique)
    }

    $json = $null
    try {
        $json = Get-Content $FilePath -Raw | ConvertFrom-Json
    }
    catch {
        $records = @(Read-LooseJsonRecords -FilePath $FilePath)
        if ($records.Count -gt 0) {
            $json = @($records)
        } else {
            throw
        }
    }

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
    
    if (Test-HeaderArrayJson $json) {
        $headers = @(@($json)[0] | ForEach-Object { "root.$([string]$_)" })
        return @($headers | Sort-Object -Unique)
    }

    $recordCollection = Get-JsonRecordCollectionInfo $json
    if ($null -ne $recordCollection -and @($recordCollection.Records).Count -gt 0) {
        BuildTree -Object @($recordCollection.Records)[0] -Prefix "root"
    }
    elseif ($json -is [System.Collections.IEnumerable] -and $json -isnot [string]) {
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
    param(
        [string[]]$Fields,
        [string[]]$InitialSelected = @()
    )
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Fields to Mask"
    $form.Size = New-Object System.Drawing.Size(500, 600)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    $searchLabel = New-Object System.Windows.Forms.Label
    $searchLabel.Text = "Search:"
    $searchLabel.AutoSize = $true
    $searchLabel.Left = 10
    $searchLabel.Top = 10

    $searchBox = New-Object System.Windows.Forms.TextBox
    $searchBox.Left = 65
    $searchBox.Top = 8
    $searchBox.Width = 405
    
    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Left = 10
    $list.Top = 40
    $list.Width = 460
    $list.Height = 490
    $list.Sorted = $true
    $fieldSelectorState = Add-SearchableFieldSelectorBehavior -List $list -SearchBox $searchBox -Fields $Fields -InitialSelected $InitialSelected -Owner $form
    
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
    $form.Controls.Add($searchLabel)
    $form.Controls.Add($searchBox)
    $form.Controls.Add($list)
    $form.Controls.Add($panel)
    
    $result = $form.ShowDialog()
    $selected = @()
    $accepted = $result -eq [System.Windows.Forms.DialogResult]::OK
    if ($accepted) {
        foreach ($field in $fieldSelectorState.Fields) {
            if ($fieldSelectorState.Checked.ContainsKey($field)) { $selected += $field }
        }
    }
    $form.Dispose()
    return [PSCustomObject]@{ Accepted = $accepted; Fields = @($selected) }
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
    
    Write-StatusPanel -Mode "Starting" -Phase "Validating" -Current 0 -Total 0 -Detail "Input and settings ready" -Mask "" -Force
    
    $statusLabel.Text = "Processing..."
    $runButton.Enabled = $false
    $mainForm.Refresh()
    
    try {
        # Create timestamped subfolder for GUI runs
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $guiOutputFolder = Join-Path $script:LastOutputFolder "Masked_Data_GUI_$timestamp"
        New-Item -ItemType Directory -Force -Path $guiOutputFolder | Out-Null
        
        $keyFile = Join-Path $guiOutputFolder "masking_key.csv"
        Invoke-Masking -InputFile $script:LastInputFile -OutputFolder $guiOutputFolder -KeyFile $keyFile -SecretKey $script:SecretKey -MaskFields $script:SelectedFields
        $statusLabel.Text = "Complete! Processed $($script:ProcessedLines) $($script:ProgressRecordLabel.ToLowerInvariant()) | Masked $($script:MaskedFieldsProcessed) fields | Generated $($script:TablesProduced) tables"
        Complete-GuiProgressStages
        [System.Windows.Forms.MessageBox]::Show("Masking completed successfully!`n`n$($script:ProgressRecordLabel) processed: $($script:ProcessedLines)`nFields masked: $($script:MaskedFieldsProcessed) (est ~$($script:EstimatedFieldsToMask))`nTables produced: $($script:TablesProduced) (est ~$($script:EstimatedTablesToProduce))`n`nOutput saved to: $guiOutputFolder", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
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
    Reset-GuiProgressStages
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
$mainForm.Controls.Add($loadProgressBar)
$mainForm.Controls.Add($progressBar)
$mainForm.Controls.Add($normalizeProgressBar)
$mainForm.Controls.Add($exportProgressBar)
$mainForm.Controls.Add($buttonPanel)
$mainForm.Controls.Add($statusLabel)
$mainForm.Controls.Add($guiLogBox)
$mainForm.Controls.Add($footerLabel)
$mainForm.Controls.Add($repoButton)
$mainForm.Controls.Add($updateButton)

$mainForm.ShowDialog() | Out-Null
