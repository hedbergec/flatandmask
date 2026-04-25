[CmdletBinding()]
param(
    [string]$SecretKey = "examplekey123"
)

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $scriptRoot "Invoke-ExampleMasking.ps1")

# NYPD Officer Profile - Title Shield History
# This is a non-array JSON (starts with { not [)
# Structure: { "meta": {...}, "data": [[...], [...], ...] }
# Data fields: PROFILE_ID, EFFECTIVE_DATE, TITLE, SHIELD_NO, EXPORT_DATE

Write-Host "==============================================" -ForegroundColor Green
Write-Host "NYPD Officer Profile - Title Shield History" -ForegroundColor Green
Write-Host "Testing non-array JSON handling" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

Invoke-ExampleMasking `
    -InputFile (Join-Path $scriptRoot "..\example data\NYPD Officer Profile - Title Shield History.json") `
    -OutputFolder (Join-Path $scriptRoot "..\example output\nypd-officer-profile") `
    -SecretKey $SecretKey `
    -MaskFields @(
        "profile_id",
        "title",
        "shield_no"
    )