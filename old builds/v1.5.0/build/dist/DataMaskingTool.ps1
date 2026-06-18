
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

$script:AppVersion = "1.5.0"
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
        } else {
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
        $rows = Convert-RowsForCsvExport -Rows @($script:Tables[$tableName])
        $rowCount = $rows.Count
        Write-StatusPanel -Phase "Exporting CSV" -Detail "Writing $name.csv ($rowCount rows)" -Force
        Export-QuotedCsv -Rows $rows -Path $path
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
        Export-QuotedCsv -Rows @($script:MappingWithRows | Select-Object Original, Masked, Field, RowIndex) -Path $KeyFile -Columns @("Original", "Masked", "Field", "RowIndex")
    } elseif ($script:Mapping.Count -gt 0) {
        $rows = @($script:Mapping.GetEnumerator() | ForEach-Object {
            [PSCustomObject]@{
                Original = $_.Key
                Masked   = $_.Value.Masked
                Field    = $_.Value.Field
            }
        })
        Export-QuotedCsv -Rows $rows -Path $KeyFile -Columns @("Original", "Masked", "Field")
    } else {
        Export-QuotedCsv -Rows @() -Path $KeyFile -Columns @("Original", "Masked", "Field", "RowIndex")
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
