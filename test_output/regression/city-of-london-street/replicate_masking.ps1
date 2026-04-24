param(
    [string]$SecretKey = "testkey123",
    [string]$OutputRoot = "$PSScriptRoot",
    [int]$MaxCsvRows = 250
)

& "$PSScriptRoot\..\..\..\testing scripts\test-masking-tool.ps1" -SecretKey $SecretKey -OutputRoot $OutputRoot -MaxCsvRows $MaxCsvRows
