
param(
    [switch]$BuildEXE = $true,
    [string]$OutputPath = "$PSScriptRoot\build",
    [string]$Version = "1.2.0",
    [string]$IconPath = "$PSScriptRoot\icon.ico",
    [switch]$SkipIcon = $false
)

$ErrorActionPreference = "Stop"

$appName = "Data Masking Tool"
$exeName = "DataMaskingTool.exe"
$projectRoot = $PSScriptRoot
$distDir = Join-Path $OutputPath "dist"
$exeDir = Join-Path $OutputPath "exe"
$logsDir = Join-Path $OutputPath "logs"
$authorName = "Eric Hedberg"
$authorEmail = "hedbergec@gmail.com"
$repoUrl = "https://github.com/hedbergec/flatandmask"
$warrantyDisclaimer = "NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: $repoUrl. Contact: $authorName <$authorEmail>."

if ($Version -notmatch '^\d+\.\d+\.\d+(\.\d+)?$') {
    throw "Version must be a numeric build version like 1.2.0 or 1.2.0.0. Current value: $Version"
}

# Create directories
foreach ($dir in @($OutputPath, $distDir, $exeDir, $logsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host $warrantyDisclaimer -ForegroundColor Yellow
Write-Host ""
Write-Host "Build Environment initialized" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host ""

# Check for required file
Write-Host "Checking Prerequisites" -ForegroundColor Green
$requiredFile = Join-Path $projectRoot "DataMaskingTool.ps1"

if (Test-Path $requiredFile) {
    Write-Host "Found: DataMaskingTool.ps1" -ForegroundColor Green
} else {
    Write-Host "Missing: DataMaskingTool.ps1" -ForegroundColor Red
    exit 1
}

# Check for icon file
$iconExists = $false
if (-not $SkipIcon) {
    if (Test-Path $IconPath) {
        Write-Host "Found: icon.ico" -ForegroundColor Green
        $iconExists = $true
    } else {
        Write-Host "Icon not found: $IconPath" -ForegroundColor Yellow
        Write-Host "To add an icon, save a .ico file as 'icon.ico' in the project root" -ForegroundColor Yellow
        Write-Host "Or use: .\Build.ps1 -SkipIcon" -ForegroundColor Yellow
    }
}

Write-Host ""

Write-Host "Refreshing build artifacts" -ForegroundColor Green
foreach ($path in @(
    (Join-Path $distDir "DataMaskingTool.ps1"),
    (Join-Path $distDir "launch.bat"),
    (Join-Path $distDir "README.md"),
    (Join-Path $distDir "VERSION.json"),
    (Join-Path $exeDir $exeName),
    (Join-Path $exeDir "DataMaskingTool.tmp.exe")
)) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Force
    }
}

Write-Host "Copying Source File" -ForegroundColor Green
$distScriptPath = Join-Path $distDir "DataMaskingTool.ps1"
Copy-Item -Path $requiredFile -Destination $distScriptPath -Force
Write-Host "Copied: DataMaskingTool.ps1" -ForegroundColor Green

$scriptLines = Get-Content -Path $distScriptPath
$appVersionLine = '$script:AppVersion = "' + $Version + '"'
$appVersionStamped = $false
for ($i = 0; $i -lt $scriptLines.Count; $i++) {
    if ($scriptLines[$i] -match '^\$script:AppVersion\s*=') {
        $scriptLines[$i] = $appVersionLine
        $appVersionStamped = $true
        break
    }
}

if ($appVersionStamped) {
    $scriptLines | Set-Content -Path $distScriptPath -Encoding UTF8
    Write-Host "Stamped app version: $Version" -ForegroundColor Green
} else {
    throw "Could not find script AppVersion to stamp in $distScriptPath"
}

# Create launch batch
Write-Host "Creating launch.bat" -ForegroundColor Green
$batch = "@echo off`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0DataMaskingTool.ps1`""
$batch | Out-File -FilePath (Join-Path $distDir "launch.bat") -Encoding ASCII -Force

# Create README
Write-Host "Creating README.md" -ForegroundColor Green
$readme = "# Data Masking Tool v$Version`n`n## Notice`n$warrantyDisclaimer`n`n## Quick Start`nDouble-click launch.bat to launch the tool`n`n## Features`n- HMAC-SHA256 deterministic masking`n- CSV and JSON file support`n- Interactive field selection`n- JSON schema tree viewer`n- Masking key audit trail`n- Replication scripts`n- Table normalization with deterministic IDs"
$readme | Out-File -FilePath (Join-Path $distDir "README.md") -Encoding UTF8 -Force

# Create version file
Write-Host "Creating VERSION.json" -ForegroundColor Green
$versionInfo = @{ Version = $Version; BuildDate = Get-Date -Format "o"; Icon = $iconExists; Repository = $repoUrl; Author = $authorName; Email = $authorEmail; Warranty = "No warranty; provided as-is." }
$versionInfo | ConvertTo-Json | Out-File -FilePath (Join-Path $distDir "VERSION.json") -Encoding UTF8 -Force

# Build single EXE (default behavior)
if ($BuildEXE) {
    Write-Host ""
    Write-Host "Building standalone EXE" -ForegroundColor Green
    
    try {
        Import-Module ps2exe -ErrorAction Stop
        Write-Host "ps2exe module loaded" -ForegroundColor Green
    }
    catch {
        Write-Host "Installing ps2exe module..." -ForegroundColor Yellow
        Install-Module -Name ps2exe -Force -ErrorAction Stop
        Import-Module ps2exe -ErrorAction Stop
        Write-Host "ps2exe module installed" -ForegroundColor Green
    }
    
    $sourcePath = Join-Path $distDir "DataMaskingTool.ps1"
    $outputPath = Join-Path $exeDir $exeName
    $tempOutputPath = Join-Path $exeDir "DataMaskingTool.tmp.exe"
    
    if (Test-Path $sourcePath) {
        if (Test-Path $outputPath) {
            Write-Host "Removing existing EXE before rebuild..." -ForegroundColor Cyan
            Remove-Item -Path $outputPath -Force -ErrorAction Stop
        }
        if (Test-Path $tempOutputPath) {
            Remove-Item -Path $tempOutputPath -Force -ErrorAction Stop
        }

        Write-Host "Converting to EXE..." -ForegroundColor Cyan
        try {
            $ps2exeParams = @{
                InputFile  = $sourcePath
                OutputFile = $tempOutputPath
                Title      = $appName
                Description = $appName
                Product    = $appName
                Version    = $Version
                NoConsole  = $false
            }
            
            # Add icon if it exists
            if ($iconExists -and -not $SkipIcon) {
                $ps2exeParams["IconFile"] = $IconPath
                Write-Host "Including icon: $IconPath" -ForegroundColor Cyan
            } else {
                Write-Host "Building without icon" -ForegroundColor Cyan
            }
            
            Invoke-ps2exe @ps2exeParams
            if (-not (Test-Path $tempOutputPath)) {
                throw "ps2exe completed but did not create $tempOutputPath"
            }

            Move-Item -Path $tempOutputPath -Destination $outputPath -Force
            Write-Host "Created: DataMaskingTool.exe" -ForegroundColor Green
            
            if ($iconExists) {
                Write-Host "EXE includes custom icon" -ForegroundColor Green
            } else {
                Write-Host "EXE uses default icon" -ForegroundColor Yellow
            }
        }
        catch {
            if (Test-Path $tempOutputPath) {
                Remove-Item -Path $tempOutputPath -Force -ErrorAction SilentlyContinue
            }
            throw "Error creating EXE: $($_.Exception.Message)"
        }
    } else {
        throw "Missing build source script: $sourcePath"
    }
}

$builtScriptVersion = Select-String -Path $distScriptPath -Pattern '^\$script:AppVersion\s*=\s*"([^"]+)"' | Select-Object -First 1
if (-not $builtScriptVersion -or $builtScriptVersion.Matches[0].Groups[1].Value -ne $Version) {
    throw "Built script version does not match Build.ps1 version $Version"
}

if ($BuildEXE) {
    $exePath = Join-Path $exeDir $exeName
    if (-not (Test-Path $exePath)) {
        throw "Expected EXE was not created: $exePath"
    }

    $exeVersionInfo = (Get-Item $exePath).VersionInfo
    if ($exeVersionInfo.FileVersion -ne $Version -or $exeVersionInfo.ProductVersion -ne $Version) {
        throw "EXE version mismatch. Expected $Version, got FileVersion=$($exeVersionInfo.FileVersion), ProductVersion=$($exeVersionInfo.ProductVersion)"
    }

    Write-Host "Verified EXE version: $($exeVersionInfo.FileVersion)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Build Complete" -ForegroundColor Green
Write-Host "Portable (PS1): $distDir" -ForegroundColor Green
if ($BuildEXE) {
    Write-Host "Standalone (EXE): $exeDir" -ForegroundColor Green
}
Write-Host ""
Write-Host "Usage:"
Write-Host "  .\Build.ps1           # Build with icon (if icon.ico exists)"
Write-Host "  .\Build.ps1 -SkipIcon # Build without icon"
