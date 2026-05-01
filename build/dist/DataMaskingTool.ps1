
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

$script:AppVersion = "1.2.3"
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
