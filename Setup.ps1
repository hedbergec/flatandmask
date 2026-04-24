
<#
.SYNOPSIS
    Prepares the Data Masking Tool for distribution as a portable application

.DESCRIPTION
    Creates the directory structure and packages all files needed for standalone execution
    
.PARAMETER OutputPath
    Where to create the portable package (default: ./DataMaskingTool_Portable)
#>

param(
    [string]$OutputPath = "$PSScriptRoot\DataMaskingTool_Portable"
)

Write-Host "================================================" -ForegroundColor Green
Write-Host "Data Masking Tool - Portable Package Setup" -ForegroundColor Green
Write-Host "================================================`n" -ForegroundColor Green

# Create output directory
if (Test-Path $OutputPath) {
    Write-Host "Removing existing package directory..." -ForegroundColor Yellow
    Remove-Item -Path $OutputPath -Recurse -Force
}

Write-Host "Creating package directory: $OutputPath" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Copy PowerShell scripts
$scripts = @("DataMaskingTool.ps1", "DataMasking.ps1", "TreeViewer.ps1")

foreach ($script in $scripts) {
    $sourcePath = Join-Path $PSScriptRoot $script
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $OutputPath -Force
        Write-Host "✓ Copied $script" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Warning: $script not found" -ForegroundColor Yellow
    }
}

# Create launch batch file
$batchContent = @'
@echo off
REM Data Masking Tool Launcher
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%DataMaskingTool.ps1

if not exist "%PS_SCRIPT%" (
    echo Error: DataMaskingTool.ps1 not found!
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "%PS_SCRIPT%"
endlocal
'@

$batchPath = Join-Path $OutputPath "launch.bat"
$batchContent | Out-File -FilePath $batchPath -Encoding ASCII -Force
Write-Host "✓ Created launch.bat" -ForegroundColor Green

# Create TreeViewer batch file
$treeViewerBatch = @'
@echo off
REM JSON Schema Tree Viewer Launcher
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%TreeViewer.ps1

if not exist "%PS_SCRIPT%" (
    echo Error: TreeViewer.ps1 not found!
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "%PS_SCRIPT%"
endlocal
'@

$treeViewerBatchPath = Join-Path $OutputPath "tree-viewer.bat"
$treeViewerBatch | Out-File -FilePath $treeViewerBatchPath -Encoding ASCII -Force
Write-Host "✓ Created tree-viewer.bat" -ForegroundColor Green

# Create README
$readmeContent = @'
# Data Masking Tool - Portable Version

## Quick Start
1. Double-click **launch.bat** to start the main application
2. Or double-click **tree-viewer.bat** to view JSON schema structure
3. No installation required
4. No administrator privileges needed

## System Requirements
- Windows 7 or later
- PowerShell 3.0 or later (included with Windows)
- .NET Framework 4.5+ (usually pre-installed)

## Applications Included

### Data Masking Tool (launch.bat)
Main application for masking sensitive data fields

1. Select an input file (JSON, CSV, or Excel)
2. Choose an output folder for masked data
3. Click "Select Fields to Mask" to choose which data to mask
4. Enter a secret key (used for deterministic masking)
5. Click "Run Masking" to process

**Field Selection:**
- All available data fields are displayed in a tree view
- PowerShell internal properties (SyncRoot, PS*, etc.) are automatically filtered out
- Only your actual data fields will appear for selection

### JSON Tree Viewer (tree-viewer.bat)
Preview JSON file structure before masking

1. Click "Select JSON File"
2. View the complete schema tree
3. Generates tree.txt file for reference
4. Internal properties automatically filtered for clarity

## Output Files
- `data.csv` - Main masked data
- `masking_key.csv` - Maps original values to masked values
- `*_masked.json` - Masked JSON (if input was JSON)
- `tree.txt` - JSON schema structure (from Tree Viewer)

## Security Notes
- Keep your secret key secure
- The masking key file maps original to masked values
- Store these files safely
- Deterministic masking uses HMAC-SHA256 for consistent hashing

## Field Selection Guide

When you click "Select Fields to Mask", you'll see all available fields from your data. Fields are displayed as paths:
- `root.email` - Direct field at root level
- `root.person.phone` - Nested field within an object
- `root.addresses` - Array field

The tool automatically filters out:
- SyncRoot
- PS* (PowerShell internal)
- PSBase, PSStandardMembers, etc.

Only select the fields containing sensitive data you want to mask.

## Troubleshooting
If you get "PowerShell script execution" errors:
1. Right-click launch.bat or tree-viewer.bat
2. Select "Run as administrator"
3. If prompted, type "A" and press Enter to allow scripts

If fields don't appear in the field selector:
1. Verify the JSON is valid
2. Check that the file path is correct
3. Look at the console output for parsing errors

## Examples

### Masking Email and Phone
1. Load `customers.json`
2. Select: `root.email`, `root.phone`
3. Enter secret key
4. Run masking

### Nested Data
1. Load `users.json` with nested structure
2. Select: `root.profile.ssn`, `root.profile.dob`
3. Run masking
'@

$readmePath = Join-Path $OutputPath "README.md"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8 -Force
Write-Host "✓ Created README.md" -ForegroundColor Green

# Create a shortcut (optional)
Write-Host "`nCreating desktop shortcuts..." -ForegroundColor Cyan

try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Desktop = [Environment]::GetFolderPath("Desktop")
    
    # Main application shortcut
    $Shortcut = $WshShell.CreateShortcut((Join-Path $Desktop "Data Masking Tool.lnk"))
    $Shortcut.TargetPath = Join-Path $OutputPath "launch.bat"
    $Shortcut.WorkingDirectory = $OutputPath
    $Shortcut.Description = "Data Masking Tool - Portable"
    $Shortcut.Save()
    Write-Host "✓ Created 'Data Masking Tool' shortcut" -ForegroundColor Green
    
    # Tree Viewer shortcut
    $TreeShortcut = $WshShell.CreateShortcut((Join-Path $Desktop "JSON Tree Viewer.lnk"))
    $TreeShortcut.TargetPath = Join-Path $OutputPath "tree-viewer.bat"
    $TreeShortcut.WorkingDirectory = $OutputPath
    $TreeShortcut.Description = "JSON Schema Tree Viewer - Portable"
    $TreeShortcut.Save()
    Write-Host "✓ Created 'JSON Tree Viewer' shortcut" -ForegroundColor Green
}
catch {
    Write-Host "⚠ Could not create desktop shortcuts (non-critical)" -ForegroundColor Yellow
}

# Summary
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "================================================`n" -ForegroundColor Green

Write-Host "Portable package created at:" -ForegroundColor White
Write-Host "$OutputPath`n" -ForegroundColor Cyan

Write-Host "To run the application:" -ForegroundColor White
Write-Host "1. Navigate to: $OutputPath" -ForegroundColor White
Write-Host "2. Double-click: launch.bat`n" -ForegroundColor White

Write-Host "To view JSON schema:" -ForegroundColor White
Write-Host "1. Navigate to: $OutputPath" -ForegroundColor White
Write-Host "2. Double-click: tree-viewer.bat`n" -ForegroundColor White

Write-Host "To distribute:" -ForegroundColor White
Write-Host "- ZIP the entire folder: $OutputPath" -ForegroundColor White
Write-Host "- Share the ZIP file" -ForegroundColor White
Write-Host "- Recipients just extract and run launch.bat`n" -ForegroundColor White

# Offer to open the folder
$open = Read-Host "Open folder now? (Y/N)"
if ($open -eq "Y" -or $open -eq "y") {
    Invoke-Item $OutputPath
}
