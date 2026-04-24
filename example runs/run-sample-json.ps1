[CmdletBinding()]
param(
    [string]$SecretKey = "examplekey123"
)

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $scriptRoot "Invoke-ExampleMasking.ps1")

Invoke-ExampleMasking `
    -InputFile (Join-Path $scriptRoot "..\example data\sample.json") `
    -OutputFolder (Join-Path $scriptRoot "..\example output\sample-json-basic") `
    -SecretKey $SecretKey `
    -MaskFields @(
        "name",
        "email"
    )

