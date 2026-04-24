[CmdletBinding()]
param(
    [string]$SecretKey = "testkey123",
    [string]$OutputRoot,
    [int]$MaxCsvRows = 250,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path -Parent $scriptRoot
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $repoRoot "test_output\regression"
}

& (Join-Path $scriptRoot "test-masking-tool.ps1") -SecretKey $SecretKey -OutputRoot $OutputRoot -MaxCsvRows $MaxCsvRows -Clean:$Clean
