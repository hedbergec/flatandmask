
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

$script:AppVersion = "1.2.1"
$script:AppTitle = "Data Masking Tool"
$script:AuthorName = "Eric Hedberg"
$script:AuthorEmail = "hedbergec@outlook.com"
$script:RepoUrl = "https://github.com/hedbergec/flatandmask"
$script:WarrantyDisclaimer = "NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: $($script:RepoUrl). Contact: $($script:AuthorName) <$($script:AuthorEmail)>."
$script:BundledSourceGzipBase64 = "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"
$script:LastInputFile = $null
$script:LastOutputFolder = $null
$script:SelectedFields = @()
$script:SecretKey = ""
$script:Mapping = @{}
$script:MappingWithRows = New-Object System.Collections.ArrayList
$script:Tables = @{}
$script:TableIdCounters = @{}
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

    $set = @{}
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
    $script:Tables = @{}
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
    $script:Tables = @{}

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
    $script:Mapping = @{}
    $script:MappingWithRows = New-Object System.Collections.ArrayList
    $script:Tables = @{}
    $script:TableIdCounters = @{}
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
            $script:Tables = @{}  # Reset tables
            $script:TablesProduced = 0  # Reset counter BEFORE processing
            foreach ($item in $maskedArray) {
                Process-MaskedObject -Object $item -TableName "root" -IdMap @{}
            }
            Set-GuiProgressStage -Bar $normalizeProgressBar -Current 100 -Total 100 -Force
        } else {
            $script:Tables = @{}  # Reset tables
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
    
    Write-StatusPanel -Mode "Starting" -Phase "Validating" -Current 0 -Total 0 -Detail "Input and settings ready" -Mask "" -Force
    
    $statusLabel.Text = "Processing..."
    $runButton.Enabled = $false
    $mainForm.Refresh()
    
    try {
        $keyFile = Join-Path $script:LastOutputFolder "masking_key.csv"
        Invoke-Masking -InputFile $script:LastInputFile -OutputFolder $script:LastOutputFolder -KeyFile $keyFile -SecretKey $script:SecretKey -MaskFields $script:SelectedFields
        $statusLabel.Text = "Complete! Processed $($script:ProcessedLines) $($script:ProgressRecordLabel.ToLowerInvariant()) | Masked $($script:MaskedFieldsProcessed) fields | Generated $($script:TablesProduced) tables"
        Complete-GuiProgressStages
        [System.Windows.Forms.MessageBox]::Show("Masking completed successfully!`n`n$($script:ProgressRecordLabel) processed: $($script:ProcessedLines)`nFields masked: $($script:MaskedFieldsProcessed) (est ~$($script:EstimatedFieldsToMask))`nTables produced: $($script:TablesProduced) (est ~$($script:EstimatedTablesToProduce))", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
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
