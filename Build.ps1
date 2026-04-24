
param(
    [switch]$BuildEXE = $true,
    [switch]$RunTests = $true,
    [string]$OutputPath = "$PSScriptRoot\build",
    [string]$Version = "1.0.1",
    [string]$IconPath = "$PSScriptRoot\icon.ico",
    [switch]$SkipIcon = $false,
    [switch]$SkipTests = $true
)

$projectRoot = $PSScriptRoot
$distDir = Join-Path $OutputPath "dist"
$exeDir = Join-Path $OutputPath "exe"
$logsDir = Join-Path $OutputPath "logs"
$testDataDir = Join-Path $OutputPath "test_data"
$testOutputDir = Join-Path $OutputPath "test_output"

# Create directories
foreach ($dir in @($OutputPath, $distDir, $exeDir, $logsDir, $testDataDir, $testOutputDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

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

# Check for test script
$testScript = Join-Path $projectRoot "test-masking-tool.ps1"
if (Test-Path $testScript) {
    Write-Host "Found: test-masking-tool.ps1" -ForegroundColor Green
} else {
    Write-Host "Warning: test-masking-tool.ps1 not found - tests will be skipped" -ForegroundColor Yellow
    $SkipTests = $true
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

# Run tests if not skipped
if (-not $SkipTests) {
    Write-Host "Running Test Suite" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Green
    
    $testParams = @{
        ToolPath = $requiredFile
        TestDataFolder = $testDataDir
        OutputFolder = $testOutputDir
    }
    
    & $testScript @testParams
    $testExitCode = $LASTEXITCODE
    
    if ($testExitCode -eq 0) {
        Write-Host ""
        Write-Host "Test suite passed!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Test suite failed with exit code $testExitCode" -ForegroundColor Red
        Write-Host "Build aborted due to test failures" -ForegroundColor Red
        exit $testExitCode
    }
    
    Write-Host ""
}

Write-Host "Copying Source File" -ForegroundColor Green
Copy-Item -Path $requiredFile -Destination $distDir -Force
Write-Host "Copied: DataMaskingTool.ps1" -ForegroundColor Green

# Create launch batch
Write-Host "Creating launch.bat" -ForegroundColor Green
$batch = "@echo off`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0DataMaskingTool.ps1`""
$batch | Out-File -FilePath (Join-Path $distDir "launch.bat") -Encoding ASCII -Force

# Create README
Write-Host "Creating README.md" -ForegroundColor Green
$readme = "# Data Masking Tool v$Version`n`n## Quick Start`nDouble-click launch.bat to launch the tool`n`n## Features`n- HMAC-SHA256 deterministic masking`n- CSV and JSON file support`n- Interactive field selection`n- JSON schema tree viewer`n- Masking key audit trail`n- Replication scripts`n- Table normalization with deterministic IDs"
$readme | Out-File -FilePath (Join-Path $distDir "README.md") -Encoding UTF8 -Force

# Create version file
Write-Host "Creating VERSION.json" -ForegroundColor Green
$versionInfo = @{ Version = $Version; BuildDate = Get-Date -Format "o"; Icon = $iconExists }
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
    $outputPath = Join-Path $exeDir "DataMaskingTool.exe"
    
    if (Test-Path $sourcePath) {
        Write-Host "Converting to EXE..." -ForegroundColor Cyan
        try {
            $ps2exeParams = @{
                InputFile  = $sourcePath
                OutputFile = $outputPath
                Title      = "Data Masking Tool"
                Version    = $Version
                NoConsole  = $false
            }
            
            # Add icon if it exists
            if ($iconExists -and -not $SkipIcon) {
                $ps2exeParams["Icon"] = $IconPath
                Write-Host "Including icon: $IconPath" -ForegroundColor Cyan
            } else {
                Write-Host "Building without icon" -ForegroundColor Cyan
            }
            
            Invoke-ps2exe @ps2exeParams
            Write-Host "Created: DataMaskingTool.exe" -ForegroundColor Green
            
            if ($iconExists) {
                Write-Host "EXE includes custom icon" -ForegroundColor Green
            } else {
                Write-Host "EXE uses default icon" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Error creating EXE: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Build Complete" -ForegroundColor Green
Write-Host "Portable (PS1): $distDir" -ForegroundColor Green
if ($BuildEXE) {
    Write-Host "Standalone (EXE): $exeDir" -ForegroundColor Green
}
Write-Host ""
Write-Host "Usage:"
Write-Host "  .\Build.ps1                      # Build with tests and icon (if icon.ico exists)"
Write-Host "  .\Build.ps1 -SkipIcon            # Build without icon"
Write-Host "  .\Build.ps1 -SkipTests           # Build without running tests"
Write-Host "  .\Build.ps1 -SkipIcon -SkipTests # Build without icon or tests"
