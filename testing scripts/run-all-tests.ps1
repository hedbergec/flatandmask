[CmdletBinding()]
param(
    [string]$SecretKey = "flatandmask-regression-key-v1",
    [string]$Version,
    [string]$OutputRoot,
    [string]$CompareToRoot,
    [int]$MaxCsvRows = 250,
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

    $files = @(
        Get-ChildItem -Path $Root -Recurse -File |
            Where-Object { $_.FullName -ne $ManifestPath } |
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

Write-Host "Running all masking tests" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Output: $OutputRoot" -ForegroundColor Cyan
Write-Host "Secret key: fixed regression key" -ForegroundColor Cyan

& (Join-Path $scriptRoot "test-masking-tool.ps1") -SecretKey $SecretKey -OutputRoot $OutputRoot -MaxCsvRows $MaxCsvRows -Clean:$Clean

$manifestPath = Join-Path $OutputRoot "artifact-manifest.json"
New-ArtifactManifest -Root $OutputRoot -Version $Version -SecretKey $SecretKey -ManifestPath $manifestPath
Write-Host "Wrote artifact manifest: $manifestPath" -ForegroundColor Green

if (-not [string]::IsNullOrWhiteSpace($CompareToRoot)) {
    $baselineManifest = Join-Path $CompareToRoot "artifact-manifest.json"
    $comparisonPath = Join-Path $OutputRoot "artifact-comparison.json"
    $diffs = Compare-ArtifactManifests -CurrentManifestPath $manifestPath -BaselineManifestPath $baselineManifest -OutputPath $comparisonPath
    Write-Host "Wrote artifact comparison: $comparisonPath" -ForegroundColor Green
    if ($diffs.Count -gt 0) {
        Write-Host "Artifact differences found: $($diffs.Count)" -ForegroundColor Yellow
        $diffs | Select-Object Status, Path | Format-Table -AutoSize
    }
    else {
        Write-Host "No artifact differences found." -ForegroundColor Green
    }
}
