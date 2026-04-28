[CmdletBinding()]
param(
    [string]$SecretKey = "flatandmask-regression-key-v1",
    [string]$Version,
    [string]$OutputRoot,
    [string]$CompareToRoot,
    [int]$MaxCsvRows = 250,
    [string[]]$ScenarioName,
    [switch]$ListScenarios,
    [switch]$SkipReplicationTests,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path -Parent $scriptRoot

function Get-BuildScriptVersion {
    $buildPath = Join-Path $repoRoot "Build.ps1"
    $match = Select-String -Path $buildPath -Pattern '^\s*\[string\]\$Version\s*=\s*"([^"]+)"' | Select-Object -First 1
    if (-not $match) {
        throw "Could not read default build version from $buildPath"
    }
    return $match.Matches[0].Groups[1].Value
}

function New-ArtifactManifest {
    param(
        [string]$Root,
        [string]$Version,
        [string]$SecretKey,
        [string]$ManifestPath
    )

    $logsRoot = Join-Path $Root "logs"
    $files = @(
        Get-ChildItem -Path $Root -Recurse -File |
            Where-Object {
                $_.FullName -ne $ManifestPath -and
                -not $_.FullName.StartsWith($logsRoot, [System.StringComparison]::OrdinalIgnoreCase)
            } |
            Sort-Object FullName |
            ForEach-Object {
                $relative = $_.FullName.Substring($Root.Length).TrimStart('\', '/')
                $hash = Get-FileHash -Path $_.FullName -Algorithm SHA256
                [PSCustomObject]@{
                    Path   = $relative.Replace('\', '/')
                    Length = $_.Length
                    SHA256 = $hash.Hash
                }
            }
    )

    [PSCustomObject]@{
        Version     = $Version
        GeneratedAt = (Get-Date).ToString("o")
        SecretKeyId = [Convert]::ToBase64String(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($SecretKey))
        ).Substring(0, 16)
        Root        = $Root
        Files       = $files
    } | ConvertTo-Json -Depth 6 | Out-File -FilePath $ManifestPath -Encoding UTF8 -Force
}

function Compare-ArtifactManifests {
    param(
        [string]$CurrentManifestPath,
        [string]$BaselineManifestPath,
        [string]$OutputPath
    )

    if (-not (Test-Path $BaselineManifestPath)) {
        throw "Baseline manifest not found: $BaselineManifestPath"
    }

    $current = Get-Content -Path $CurrentManifestPath -Raw | ConvertFrom-Json
    $baseline = Get-Content -Path $BaselineManifestPath -Raw | ConvertFrom-Json
    $currentByPath = @{}
    $baselineByPath = @{}

    foreach ($file in @($current.Files)) { $currentByPath[$file.Path] = $file }
    foreach ($file in @($baseline.Files)) { $baselineByPath[$file.Path] = $file }

    $allPaths = @($currentByPath.Keys + $baselineByPath.Keys | Sort-Object -Unique)
    $diffs = foreach ($path in $allPaths) {
        if (-not $currentByPath.ContainsKey($path)) {
            [PSCustomObject]@{ Status = "Removed"; Path = $path; CurrentSHA256 = ""; BaselineSHA256 = $baselineByPath[$path].SHA256 }
        }
        elseif (-not $baselineByPath.ContainsKey($path)) {
            [PSCustomObject]@{ Status = "Added"; Path = $path; CurrentSHA256 = $currentByPath[$path].SHA256; BaselineSHA256 = "" }
        }
        elseif ($currentByPath[$path].SHA256 -ne $baselineByPath[$path].SHA256) {
            [PSCustomObject]@{ Status = "Changed"; Path = $path; CurrentSHA256 = $currentByPath[$path].SHA256; BaselineSHA256 = $baselineByPath[$path].SHA256 }
        }
    }

    $diffs | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputPath -Encoding UTF8 -Force
    return @($diffs)
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = Get-BuildScriptVersion
}

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $repoRoot "test_output\regression\$Version"
}

if ($Clean -and (Test-Path -LiteralPath $OutputRoot)) {
    Remove-Item -LiteralPath $OutputRoot -Recurse -Force
}

$runStart = Get-Date
$logsDir = Join-Path $OutputRoot "logs"
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
$timestamp = $runStart.ToString("yyyyMMdd-HHmmss")
$transcriptPath = Join-Path $logsDir "test-run-$timestamp.log"
$receiptPath = Join-Path $logsDir "test-run-$timestamp.receipt.json"
$latestReceiptPath = Join-Path $logsDir "latest-test-run.receipt.json"
$manifestPath = Join-Path $OutputRoot "artifact-manifest.json"
$comparisonPath = Join-Path $OutputRoot "artifact-comparison.json"
$testResultsPath = Join-Path $OutputRoot "test-results.json"
$transcriptStarted = $false
$runStatus = "Failed"
$runError = $null
$diffCount = $null

try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
    $transcriptStarted = $true

    Write-Host "Running all masking tests" -ForegroundColor Cyan
    Write-Host "Version: $Version" -ForegroundColor Cyan
    Write-Host "Output: $OutputRoot" -ForegroundColor Cyan
    Write-Host "Secret key: fixed regression key" -ForegroundColor Cyan
    Write-Host "Transcript: $transcriptPath" -ForegroundColor Cyan
    if ($ScenarioName -and $ScenarioName.Count -gt 0) {
        Write-Host "Scenario filter: $($ScenarioName -join ', ')" -ForegroundColor Cyan
    }

    & (Join-Path $scriptRoot "test-masking-tool.ps1") -SecretKey $SecretKey -OutputRoot $OutputRoot -MaxCsvRows $MaxCsvRows -ScenarioName $ScenarioName -ListScenarios:$ListScenarios -SkipReplicationTests:$SkipReplicationTests

    if (-not $ListScenarios) {
        New-ArtifactManifest -Root $OutputRoot -Version $Version -SecretKey $SecretKey -ManifestPath $manifestPath
        Write-Host "Wrote artifact manifest: $manifestPath" -ForegroundColor Green
    }

    if ((-not $ListScenarios) -and (-not [string]::IsNullOrWhiteSpace($CompareToRoot))) {
        $baselineManifest = Join-Path $CompareToRoot "artifact-manifest.json"
        $diffs = Compare-ArtifactManifests -CurrentManifestPath $manifestPath -BaselineManifestPath $baselineManifest -OutputPath $comparisonPath
        $diffCount = $diffs.Count
        Write-Host "Wrote artifact comparison: $comparisonPath" -ForegroundColor Green
        if ($diffs.Count -gt 0) {
            Write-Host "Artifact differences found: $($diffs.Count)" -ForegroundColor Yellow
            $diffs | Select-Object Status, Path | Format-Table -AutoSize
        }
        else {
            Write-Host "No artifact differences found." -ForegroundColor Green
        }
    }

    $runStatus = "Passed"
}
catch {
    $runError = "{0}`n{1}`n{2}" -f $_.Exception.Message, $_.InvocationInfo.PositionMessage, $_.ScriptStackTrace
    Write-Host "Test run failed: $($_.Exception.Message)" -ForegroundColor Red
    throw
}
finally {
    $runEnd = Get-Date
    $testResults = $null
    $comparisonPathForReceipt = $null
    if (Test-Path -LiteralPath $comparisonPath) {
        $comparisonPathForReceipt = $comparisonPath
    }
    if (Test-Path -LiteralPath $testResultsPath) {
        try {
            $testResults = Get-Content -LiteralPath $testResultsPath -Raw | ConvertFrom-Json
        }
        catch {
            $testResults = [PSCustomObject]@{
                Status = "Unreadable"
                Error  = $_.Exception.Message
            }
        }
    }

    $receipt = [PSCustomObject]@{
        Status               = $runStatus
        Version              = $Version
        StartedAt            = $runStart.ToString("o")
        FinishedAt           = $runEnd.ToString("o")
        DurationSeconds      = [Math]::Round(($runEnd - $runStart).TotalSeconds, 3)
        RepoRoot             = $repoRoot
        OutputRoot           = $OutputRoot
        MaxCsvRows           = $MaxCsvRows
        Clean                = [bool]$Clean
        ScenarioName         = @($ScenarioName)
        ListScenarios        = [bool]$ListScenarios
        SkipReplicationTests = [bool]$SkipReplicationTests
        CompareToRoot        = $CompareToRoot
        ArtifactDiffCount    = $diffCount
        TranscriptPath       = $transcriptPath
        TestResultsPath      = $testResultsPath
        ManifestPath         = $manifestPath
        ComparisonPath       = $comparisonPathForReceipt
        Error                = $runError
        TestResults          = $testResults
    }

    $receipt | ConvertTo-Json -Depth 8 | Out-File -FilePath $receiptPath -Encoding UTF8 -Force
    $receipt | ConvertTo-Json -Depth 8 | Out-File -FilePath $latestReceiptPath -Encoding UTF8 -Force
    Write-Host "Wrote test run receipt: $receiptPath" -ForegroundColor Green
    Write-Host "Updated latest test run receipt: $latestReceiptPath" -ForegroundColor Green

    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}
