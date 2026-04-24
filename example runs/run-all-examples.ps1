[CmdletBinding()]
param(
    [string]$SecretKey = "examplekey123"
)

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

& (Join-Path $scriptRoot "run-sample-json.ps1") -SecretKey $SecretKey
& (Join-Path $scriptRoot "run-complex-json.ps1") -SecretKey $SecretKey
& (Join-Path $scriptRoot "run-city-of-london-street.ps1") -SecretKey $SecretKey
& (Join-Path $scriptRoot "run-city-of-london-outcomes.ps1") -SecretKey $SecretKey
