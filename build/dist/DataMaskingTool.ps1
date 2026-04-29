
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

$script:AppVersion = "1.2.2"
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
