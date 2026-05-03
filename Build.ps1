
param(
    [switch]$BuildEXE = $true,
    [switch]$BuildRPackage = $false,
    [string]$OutputPath = "$PSScriptRoot\build",
    [string]$Version = "1.3.0",
    [string]$RPackagePath = "$PSScriptRoot\Rpackage",
    [string]$IconPath = "$PSScriptRoot\icon.ico",
    [switch]$SkipIcon = $false,
    [switch]$SignEXE = $false,
    [string]$SignToolPath = "",
    [string]$SigningDlibPath = "",
    [string]$SigningMetadataPath = "",
    [string]$SigningEndpoint = "https://wus2.codesigning.azure.net",
    [string]$CodeSigningAccountName = "hedbergec",
    [string]$CertificateProfileName = "DesignEffectsLLCPub",
    [string]$SigningCorrelationId = "",
    [switch]$SkipSignatureVerify = $false
)

$ErrorActionPreference = "Stop"

$appName = "Data Masking Tool"
$exeName = "DataMaskingTool.exe"
$projectRoot = $PSScriptRoot
$distDir = Join-Path $OutputPath "dist"
$exeDir = Join-Path $OutputPath "exe"
$rPackageBuildDir = Join-Path $OutputPath "Rpackage"
$logsDir = Join-Path $OutputPath "logs"
$authorName = "Eric Hedberg"
$authorEmail = "hedbergec@outlook.com"
$repoUrl = "https://github.com/hedbergec/flatandmask"
$warrantyDisclaimer = "NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: $repoUrl. Contact: $authorName <$authorEmail>."

if ($Version -notmatch '^\d+\.\d+\.\d+(\.\d+)?$') {
    throw "Version must be a numeric build version like 1.2.0 or 1.2.0.0. Current value: $Version"
}

function Resolve-RequiredPath {
    param(
        [string]$Path,
        [string]$Description
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Description path was not provided."
    }
    if (-not (Test-Path $Path)) {
        throw "$Description not found: $Path"
    }
    return (Resolve-Path $Path).Path
}

function Resolve-SigningToolPath {
    param(
        [string]$ConfiguredPath,
        [string[]]$CandidatePaths,
        [string]$Description
    )

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredPath)) {
        return Resolve-RequiredPath -Path $ConfiguredPath -Description $Description
    }

    foreach ($candidate in $CandidatePaths) {
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw "$Description was not found. Install signing tools under tools\signing or pass the path explicitly."
}

function New-SigningMetadataFile {
    param(
        [string]$Path,
        [string]$Endpoint,
        [string]$AccountName,
        [string]$ProfileName,
        [string]$CorrelationId
    )

    $metadata = [ordered]@{
        Endpoint = $Endpoint
        CodeSigningAccountName = $AccountName
        CertificateProfileName = $ProfileName
        CorrelationId = $CorrelationId
    } | ConvertTo-Json

    $metadataDirectory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($metadataDirectory) -and -not (Test-Path $metadataDirectory)) {
        New-Item -ItemType Directory -Force -Path $metadataDirectory | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $metadata, $utf8NoBom)
    return (Resolve-Path $Path).Path
}

function ConvertTo-GzipBase64 {
    param([string]$Text)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $outputStream = New-Object System.IO.MemoryStream
    $gzipStream = $null
    try {
        $gzipStream = New-Object System.IO.Compression.GZipStream($outputStream, [System.IO.Compression.CompressionMode]::Compress)
        $gzipStream.Write($bytes, 0, $bytes.Length)
    }
    finally {
        if ($gzipStream) { $gzipStream.Dispose() }
    }

    return [Convert]::ToBase64String($outputStream.ToArray())
}

function ConvertTo-VersionParts {
    param([string]$VersionText)

    if ($VersionText -notmatch '^\d+\.\d+\.\d+(\.\d+)?$') {
        throw "Invalid version value: $VersionText"
    }

    $parts = @($VersionText.Split('.') | ForEach-Object { [int]$_ })
    while ($parts.Count -lt 4) {
        $parts += 0
    }

    return $parts
}

function Compare-BuildVersion {
    param(
        [string]$Left,
        [string]$Right
    )

    $leftParts = @(ConvertTo-VersionParts -VersionText $Left)
    $rightParts = @(ConvertTo-VersionParts -VersionText $Right)

    for ($i = 0; $i -lt 4; $i++) {
        if ($leftParts[$i] -gt $rightParts[$i]) { return 1 }
        if ($leftParts[$i] -lt $rightParts[$i]) { return -1 }
    }

    return 0
}

function Get-RDescriptionValue {
    param(
        [string]$DescriptionPath,
        [string]$Field
    )

    $match = Get-Content -Path $DescriptionPath | Where-Object { $_ -match "^$([regex]::Escape($Field)):\s*(.+)$" } | Select-Object -First 1
    if (-not $match) {
        throw "Could not find '$Field' in $DescriptionPath"
    }

    return ([regex]::Match($match, "^$([regex]::Escape($Field)):\s*(.+)$")).Groups[1].Value.Trim()
}

function Invoke-CheckedCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$Description
    )

    Write-Host $Description -ForegroundColor Cyan
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE"
    }
}

# Create directories
foreach ($dir in @($OutputPath, $distDir, $exeDir, $rPackageBuildDir, $logsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$previousVersion = $null
$previousVersionPath = Join-Path $distDir "VERSION.json"
if (Test-Path $previousVersionPath) {
    try {
        $previousVersion = (Get-Content -Path $previousVersionPath -Raw | ConvertFrom-Json).Version
    }
    catch {
        Write-Host "Could not read previous build version from $previousVersionPath; signing will be allowed if requested." -ForegroundColor Yellow
    }
}

$versionIncreased = $true
if (-not [string]::IsNullOrWhiteSpace($previousVersion)) {
    $versionComparison = Compare-BuildVersion -Left $Version -Right $previousVersion
    $versionIncreased = ($versionComparison -gt 0)
}

Write-Host $warrantyDisclaimer -ForegroundColor Yellow
Write-Host ""
Write-Host "Build Environment initialized" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Green
if (-not [string]::IsNullOrWhiteSpace($previousVersion)) {
    Write-Host "Previous build version: $previousVersion" -ForegroundColor Green
    if ($versionIncreased) {
        Write-Host "Version increased; signing is allowed when -SignEXE is used." -ForegroundColor Green
    } else {
        Write-Host "Version did not increase; signing will be skipped even if -SignEXE is used." -ForegroundColor Yellow
    }
}
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
    (Join-Path $distDir "VERSION.json")
)) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Force
    }
}

if ($BuildEXE) {
    foreach ($path in @(
        (Join-Path $exeDir $exeName),
        (Join-Path $exeDir "DataMaskingTool.tmp.exe")
    )) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Force
        }
    }
}

if ($BuildRPackage) {
    foreach ($path in @(
        (Join-Path $rPackageBuildDir "JsonCSVMaskr_*.tar.gz"),
        (Join-Path $rPackageBuildDir "JsonCSVMaskr_*.zip")
    )) {
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Remove-Item -Force
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

$distScriptTextForBundle = Get-Content -Path $distScriptPath -Raw
$bundledSource = ConvertTo-GzipBase64 -Text $distScriptTextForBundle
$distScriptTextForExe = $distScriptTextForBundle -replace '(?m)^\$script:BundledSourceGzipBase64\s*=.*$', ('$script:BundledSourceGzipBase64 = "' + $bundledSource + '"')
if ($distScriptTextForExe -eq $distScriptTextForBundle) {
    throw "Could not find BundledSourceGzipBase64 placeholder to stamp in $distScriptPath"
}
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($distScriptPath, $distScriptTextForExe, $utf8NoBom)
Write-Host "Embedded matching DataMaskingTool.ps1 source for EXE replication outputs" -ForegroundColor Green

# Create launch batch
Write-Host "Creating launch.bat" -ForegroundColor Green
$batch = "@echo off`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0DataMaskingTool.ps1`""
$batch | Out-File -FilePath (Join-Path $distDir "launch.bat") -Encoding ASCII -Force

# Create README
Write-Host "Creating README.md" -ForegroundColor Green
$readme = "# Data Masking Tool v$Version`n`n## Notice`n$warrantyDisclaimer`n`n## Quick Start`nDouble-click launch.bat to launch the tool`n`n## Features`n- HMAC-SHA256 deterministic masking`n- CSV and JSON file support`n- Interactive field selection`n- JSON schema tree viewer`n- Masking key audit trail`n- Replication scripts`n- Table normalization with deterministic IDs`n`n## Replication Scripts`nEach masking run writes replicate_masking.ps1 and DataMaskingTool.ps1 into the output folder. The replication script is a thin wrapper that loads the local DataMaskingTool.ps1 copy and calls Invoke-Masking with the same selected fields, secret key, and original input path. Run replicate_masking.ps1 with no arguments to replay against the original input, or pass -InputFile to use a moved or replacement file."
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

    if ($SignEXE -and -not $versionIncreased) {
        Write-Host ""
        Write-Host "Skipping EXE signing because version $Version is not greater than previous build version $previousVersion." -ForegroundColor Yellow
    }
    elseif ($SignEXE) {
        Write-Host ""
        Write-Host "Signing standalone EXE" -ForegroundColor Green

        if ([string]::IsNullOrWhiteSpace($SigningCorrelationId)) {
            $SigningCorrelationId = "flatandmask-$Version"
        }

        $defaultSignTool = Join-Path $projectRoot "tools\signing\Microsoft.Windows.SDK.BuildTools\bin\10.0.28000.0\x64\signtool.exe"
        $defaultDlib = Join-Path $projectRoot "tools\signing\Microsoft.ArtifactSigning.Client\bin\x64\Azure.CodeSigning.Dlib.dll"
        $resolvedSignTool = Resolve-SigningToolPath -ConfiguredPath $SignToolPath -CandidatePaths @($defaultSignTool) -Description "SignTool"
        $resolvedDlib = Resolve-SigningToolPath -ConfiguredPath $SigningDlibPath -CandidatePaths @($defaultDlib) -Description "Azure Artifact Signing dlib"

        if ([string]::IsNullOrWhiteSpace($SigningMetadataPath)) {
            $SigningMetadataPath = Join-Path $logsDir "artifact-signing-metadata.json"
        }

        $resolvedMetadataPath = New-SigningMetadataFile -Path $SigningMetadataPath -Endpoint $SigningEndpoint -AccountName $CodeSigningAccountName -ProfileName $CertificateProfileName -CorrelationId $SigningCorrelationId

        $env:PATH = "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin;C:\Program Files\dotnet;C:\Program Files\dotnet\x64;$($env:PATH)"
        $signArgs = @(
            "sign",
            "/v",
            "/debug",
            "/fd", "SHA256",
            "/tr", "http://timestamp.acs.microsoft.com",
            "/td", "SHA256",
            "/d", $appName,
            "/du", $repoUrl,
            "/dlib", $resolvedDlib,
            "/dmdf", $resolvedMetadataPath,
            $exePath
        )

        & $resolvedSignTool @signArgs
        if ($LASTEXITCODE -ne 0) {
            throw "SignTool signing failed with exit code $LASTEXITCODE"
        }

        if (-not $SkipSignatureVerify) {
            Write-Host "Verifying EXE signature..." -ForegroundColor Cyan
            & $resolvedSignTool verify /pa /v $exePath
            if ($LASTEXITCODE -ne 0) {
                throw "SignTool verification failed with exit code $LASTEXITCODE"
            }

            $signature = Get-AuthenticodeSignature -FilePath $exePath
            if ($signature.Status -ne "Valid") {
                throw "Authenticode signature status is $($signature.Status): $($signature.StatusMessage)"
            }

            Write-Host "Signature valid: $($signature.SignerCertificate.Subject)" -ForegroundColor Green
        }
    }
}

if ($BuildRPackage) {
    Write-Host ""
    Write-Host "Building R package" -ForegroundColor Green

    if (-not (Test-Path $RPackagePath)) {
        throw "R package directory not found: $RPackagePath"
    }

    $descriptionPath = Join-Path $RPackagePath "DESCRIPTION"
    if (-not (Test-Path $descriptionPath)) {
        throw "R package DESCRIPTION file not found: $descriptionPath"
    }

    $rCommand = Get-Command R.exe -ErrorAction SilentlyContinue
    if (-not $rCommand) {
        throw "R was not found on PATH. Install R for Windows and make sure R.exe is available on PATH, or run from an R-enabled shell."
    }
    $rExePath = if ($rCommand.Path) { $rCommand.Path } else { $rCommand.Source }
    if ([string]::IsNullOrWhiteSpace($rExePath)) {
        throw "R.exe was found but its executable path could not be resolved."
    }

    $rPackageName = Get-RDescriptionValue -DescriptionPath $descriptionPath -Field "Package"
    $rPackageVersion = Get-RDescriptionValue -DescriptionPath $descriptionPath -Field "Version"
    $sourceArchiveName = "${rPackageName}_${rPackageVersion}.tar.gz"
    $windowsArchiveName = "${rPackageName}_${rPackageVersion}.zip"
    $sourceArchiveRoot = Join-Path $projectRoot $sourceArchiveName
    $windowsArchiveRoot = Join-Path $projectRoot $windowsArchiveName
    $sourceArchiveOut = Join-Path $rPackageBuildDir $sourceArchiveName
    $windowsArchiveOut = Join-Path $rPackageBuildDir $windowsArchiveName

    foreach ($path in @($sourceArchiveRoot, $windowsArchiveRoot, $sourceArchiveOut, $windowsArchiveOut)) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Force
        }
    }

    Push-Location $projectRoot
    try {
        Invoke-CheckedCommand -FilePath $rExePath -Arguments @("CMD", "build", $RPackagePath) -Description "Running R CMD build for $rPackageName"
        if (-not (Test-Path $sourceArchiveRoot)) {
            throw "R CMD build completed but did not create $sourceArchiveRoot"
        }
        Move-Item -Path $sourceArchiveRoot -Destination $sourceArchiveOut -Force
        Write-Host "Created: $sourceArchiveOut" -ForegroundColor Green

        Invoke-CheckedCommand -FilePath $rExePath -Arguments @("CMD", "INSTALL", "--build", $RPackagePath) -Description "Running R CMD INSTALL --build for Windows package zip"
        if (Test-Path $windowsArchiveRoot) {
            Move-Item -Path $windowsArchiveRoot -Destination $windowsArchiveOut -Force
            Write-Host "Created: $windowsArchiveOut" -ForegroundColor Green
        }
        else {
            Write-Host "R CMD INSTALL --build did not create $windowsArchiveName in $projectRoot." -ForegroundColor Yellow
            Write-Host "On non-Windows platforms this may produce a platform-specific tarball instead of a Windows binary zip. Run this step on Windows to create the .zip artifact." -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "Build Complete" -ForegroundColor Green
Write-Host "Portable (PS1): $distDir" -ForegroundColor Green
if ($BuildEXE) {
    Write-Host "Standalone (EXE): $exeDir" -ForegroundColor Green
}
if ($BuildRPackage) {
    Write-Host "R package artifacts: $rPackageBuildDir" -ForegroundColor Green
}
Write-Host ""
Write-Host "Usage:"
Write-Host "  .\Build.ps1           # Build with icon (if icon.ico exists)"
Write-Host "  .\Build.ps1 -SkipIcon # Build without icon"
Write-Host "  .\Build.ps1 -BuildEXE -SignEXE # Build and sign only when -Version is greater than the previous build"
Write-Host "  .\Build.ps1 -BuildRPackage # Build JsonCSVMaskr source tar.gz and Windows zip package artifacts"
