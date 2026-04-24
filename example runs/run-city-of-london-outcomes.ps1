[CmdletBinding()]
param(
    [string]$SecretKey = "examplekey123"
)

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $scriptRoot "Invoke-ExampleMasking.ps1")

Invoke-ExampleMasking `
    -InputFile (Join-Path $scriptRoot "..\example data\2026-02-city-of-london-outcomes.csv") `
    -OutputFolder (Join-Path $scriptRoot "..\example output\city-of-london-outcomes") `
    -SecretKey $SecretKey `
    -MaskFields @(
        "Reported by",
        "Falls within",
        "Location"
    )

