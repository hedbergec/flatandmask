[CmdletBinding()]
param(
    [string]$SecretKey = "examplekey123"
)

$scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $scriptRoot "Invoke-ExampleMasking.ps1")

Invoke-ExampleMasking `
    -InputFile (Join-Path $scriptRoot "..\example data\complex3.json") `
    -OutputFolder (Join-Path $scriptRoot "..\example output\complex-json-sensitive") `
    -SecretKey $SecretKey `
    -MaskFields @(
        "firstName",
        "lastName",
        "email",
        "phone",
        "contacts.name",
        "contacts.email",
        "contacts.phone",
        "company.headquarters.street",
        "company.headquarters.city",
        "addresses.street",
        "addresses.city",
        "paymentMethods.cardNumber",
        "paymentMethods.cardholderName",
        "paymentMethods.billingAddress",
        "paymentMethods.accountHolderName"
    )

