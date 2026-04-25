[CmdletBinding()]
param(
    [string]$Version,
    [int]$MaxCsvRows = 250,
    [string]$CompareToRoot,
    [switch]$Clean,
    [switch]$SkipTests,
    [switch]$SkipBuild,
    [switch]$SkipExe,
    [switch]$SkipUpdateSmoke,
    [switch]$SkipGitStatus
)

$ErrorActionPreference = "Stop"
$repoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Cyan
}

function Get-BuildVersion {
    $buildPath = Join-Path $repoRoot "Build.ps1"
    $match = Select-String -Path $buildPath -Pattern '^\s*\[string\]\$Version\s*=\s*"([^"]+)"' | Select-Object -First 1
    if (-not $match) {
        throw "Could not read default build version from $buildPath"
    }
    return $match.Matches[0].Groups[1].Value
}

function Test-PowerShellSyntax {
    param([string]$Path)

    $tokens = $null
    $errors = $null
    $code = Get-Content -Path $Path -Raw
    [System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        $details = $errors | ForEach-Object { "$($_.Extent.StartLineNumber):$($_.Extent.StartColumnNumber) $($_.Message)" }
        throw "PowerShell syntax check failed for ${Path}:`n$($details -join "`n")"
    }

    Write-Host "OK: $Path" -ForegroundColor Green
}

function Invoke-UpdateSmokeTest {
    $scriptPath = Join-Path $repoRoot "build\dist\DataMaskingTool.ps1"
    if (-not (Test-Path $scriptPath)) {
        $scriptPath = Join-Path $repoRoot "DataMaskingTool.ps1"
    }

    $script:AppVersion = $Version
    $script:RepoUrl = "https://github.com/hedbergec/flatandmask"
    $code = Get-Content -Path $scriptPath -Raw
    $start = $code.IndexOf("function ConvertTo-AppVersion")
    $end = $code.IndexOf("function Write-MaskLog")

    if ($start -lt 0 -or $end -le $start) {
        throw "Could not isolate update-check functions in $scriptPath"
    }

    Invoke-Expression $code.Substring($start, $end - $start)
    $status = Get-ToolUpdateStatus
    if ($status.Status -notin @("Current", "UpdateAvailable", "Unknown")) {
        throw "Update smoke test returned unexpected status: $($status.Status) - $($status.Message)"
    }

    Write-Host "Update smoke status: $($status.Status)" -ForegroundColor Green
    Write-Host ($status.Message -replace "`r", "") -ForegroundColor DarkGray
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    $Version = Get-BuildVersion
}

Write-Step "Context"
Write-Host "Repo: $repoRoot"
Write-Host "Version: $Version"
Write-Host "Max CSV rows in regression tests: $MaxCsvRows"

if (-not $SkipGitStatus) {
    Write-Step "Git Status"
    git -C $repoRoot status --short
}

Write-Step "PowerShell Syntax"
$syntaxFiles = @(
    "DataMaskingTool.ps1",
    "Build.ps1",
    "testing scripts\run-all-tests.ps1",
    "testing scripts\run-test-masking.ps1",
    "testing scripts\test-masking-tool.ps1"
)

foreach ($relativePath in $syntaxFiles) {
    Test-PowerShellSyntax -Path (Join-Path $repoRoot $relativePath)
}

if (-not $SkipTests) {
    Write-Step "Regression Tests"
    $testScript = Join-Path $repoRoot "testing scripts\run-all-tests.ps1"
    $testArgs = @("-Version", $Version, "-MaxCsvRows", $MaxCsvRows)
    if ($Clean) { $testArgs += "-Clean" }
    if (-not [string]::IsNullOrWhiteSpace($CompareToRoot)) {
        $testArgs += @("-CompareToRoot", $CompareToRoot)
    }

    & $testScript @testArgs
}

if (-not $SkipBuild) {
    Write-Step "Build"
    $buildScript = Join-Path $repoRoot "Build.ps1"
    if ($SkipExe) {
        & $buildScript -Version $Version -BuildEXE:$false
    }
    else {
        & $buildScript -Version $Version -BuildEXE
    }
}

Write-Step "Build Verification"
$distScript = Join-Path $repoRoot "build\dist\DataMaskingTool.ps1"
$versionJson = Join-Path $repoRoot "build\dist\VERSION.json"
if (-not (Test-Path $distScript)) { throw "Missing dist script: $distScript" }
if (-not (Test-Path $versionJson)) { throw "Missing version metadata: $versionJson" }

Test-PowerShellSyntax -Path $distScript

$distVersionMatch = Select-String -Path $distScript -Pattern '^\$script:AppVersion\s*=\s*"([^"]+)"' | Select-Object -First 1
if (-not $distVersionMatch -or $distVersionMatch.Matches[0].Groups[1].Value -ne $Version) {
    throw "Dist script version does not match $Version"
}

$versionInfo = Get-Content -Path $versionJson -Raw | ConvertFrom-Json
if ($versionInfo.Version -ne $Version) {
    throw "VERSION.json version does not match $Version"
}

if (-not $SkipExe) {
    $exePath = Join-Path $repoRoot "build\exe\DataMaskingTool.exe"
    if (-not (Test-Path $exePath)) {
        throw "Missing EXE: $exePath"
    }

    $exeVersion = (Get-Item $exePath).VersionInfo
    if ($exeVersion.FileVersion -ne $Version -or $exeVersion.ProductVersion -ne $Version) {
        throw "EXE version mismatch. Expected $Version, got FileVersion=$($exeVersion.FileVersion), ProductVersion=$($exeVersion.ProductVersion)"
    }

    Write-Host "EXE version OK: $($exeVersion.FileVersion)" -ForegroundColor Green
}

if (-not $SkipUpdateSmoke) {
    Write-Step "Update Checker Smoke Test"
    Invoke-UpdateSmokeTest
}

Write-Step "Done"
Write-Host "Build and test routine completed successfully." -ForegroundColor Green
