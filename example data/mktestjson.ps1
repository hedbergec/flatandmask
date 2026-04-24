
param(
    [int]$FileSizeMB = 30,
    [string]$OutputPath = ".\test_data.json",
    [int]$RecordsPerBatch = 100
)

function Generate-RandomEmail {
    $firstNames = @("James", "Maria", "Robert", "Sarah", "Michael", "Jennifer", "David", "Emily", "John", "Lisa", "Daniel", "Mary", "William", "Patricia", "Richard", "Barbara")
    $lastNames = @("Anderson", "Garcia", "Chen", "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Rodriguez", "Martinez")
    $domains = @("example.com", "test.com", "mail.com", "company.com", "email.net")
    
    $first = $firstNames | Get-Random
    $last = $lastNames | Get-Random
    $domain = $domains | Get-Random
    
    return "$($first.ToLower()).$($last.ToLower())@$domain"
}

function Generate-RandomPhone {
    $areaCode = Get-Random -Minimum 200 -Maximum 999
    $exchange = Get-Random -Minimum 200 -Maximum 999
    $lineNumber = Get-Random -Minimum 1000 -Maximum 9999
    return "555-$($areaCode)-$exchange"
}

function Generate-RandomSSN {
    $part1 = (Get-Random -Minimum 100 -Maximum 900).ToString("D3")
    $part2 = (Get-Random -Minimum 10 -Maximum 99).ToString("D2")
    $part3 = (Get-Random -Minimum 1000 -Maximum 9999).ToString("D4")
    return "$part1-$part2-$part3"
}

function Generate-RandomCardNumber {
    $prefix = "4532"
    $remaining = ""
    for ($i = 0; $i -lt 12; $i++) {
        $remaining += Get-Random -Minimum 0 -Maximum 10
    }
    return $prefix + $remaining
}

function Generate-Address {
    param([int]$Index)
    
    $streets = @("Oak", "Maple", "Pine", "Elm", "Cedar", "Birch", "Walnut", "Ash", "Spruce", "Hickory")
    $cities = @("San Francisco", "New York", "Boston", "Chicago", "Seattle", "Austin", "Denver", "Portland", "Miami", "Los Angeles")
    $states = @("CA", "NY", "MA", "IL", "WA", "TX", "CO", "OR", "FL", "CA")
    
    $street = "{0} {1} Street" -f (Get-Random -Minimum 100 -Maximum 999), ($streets | Get-Random)
    $city = $cities | Get-Random
    $state = $states | Get-Random
    $zip = Get-Random -Minimum 10000 -Maximum 99999
    
    return @{
        address_id = "a$(Get-Random -Minimum 10000 -Maximum 99999)"
        street = $street
        city = $city
        state = $state
        zipCode = $zip.ToString()
        country = "USA"
        latitude = [Math]::Round((Get-Random -Minimum 25 -Maximum 48) + (Get-Random -Minimum 0 -Maximum 1000) / 1000, 4)
        longitude = [Math]::Round((-122 + (Get-Random -Minimum 0 -Maximum 60)) + (Get-Random -Minimum 0 -Maximum 1000) / 1000, 4)
    }
}

function Generate-Company {
    param([int]$Index)
    
    $companyNames = @("Tech Solutions Inc", "Global Finance Corp", "Innovation Labs", "Digital Dynamics", "Cloud Systems LLC", "Data Services Inc", "Network Solutions", "Enterprise Software Co", "Quantum Technologies", "Future Innovations")
    $industries = @("software", "finance", "research", "consulting", "healthcare", "retail", "manufacturing", "transportation", "energy", "telecom")
    
    return @{
        company_id = "c$(Get-Random -Minimum 1000 -Maximum 9999)"
        name = $companyNames | Get-Random
        companySize = @("small", "medium", "large") | Get-Random
        industryCode = $industries | Get-Random
        founded = Get-Random -Minimum 1995 -Maximum 2020
        headquarters = Generate-Address $Index
        employees = Get-Random -Minimum 50 -Maximum 5000
    }
}

function Generate-Contact {
    param([int]$Index)
    
    $relationships = @("spouse", "parent", "sibling", "child", "friend", "colleague", "emergency contact")
    $firstNames = @("Sarah", "Michael", "Jennifer", "David", "Emily", "John", "Mary", "Robert", "Patricia", "James")
    
    return @{
        contact_id = "ct$(Get-Random -Minimum 10000 -Maximum 99999)"
        name = "{0} {1}" -f ($firstNames | Get-Random), @("Anderson", "Garcia", "Chen", "Smith", "Johnson") | Get-Random
        relationship = $relationships | Get-Random
        phone = Generate-RandomPhone
        email = Generate-RandomEmail
    }
}

function Generate-PaymentMethod {
    param([int]$Index)
    
    $type = @("credit_card", "debit_card", "bank_account") | Get-Random
    
    $payment = @{
        payment_id = "pm$(Get-Random -Minimum 10000 -Maximum 99999)"
        type = $type
    }
    
    if ($type -eq "bank_account") {
        $payment.accountNumber = Get-Random -Minimum 100000000 -Maximum 999999999
        $payment.routingNumber = "121000248"
        $payment.accountHolderName = "{0} {1}" -f @("James", "Maria", "Robert") | Get-Random, @("Anderson", "Garcia", "Chen") | Get-Random
    }
    else {
        $payment.cardNumber = Generate-RandomCardNumber
        $payment.cardholderName = "CARDHOLDER NAME"
        $payment.expiryMonth = Get-Random -Minimum 1 -Maximum 12
        $payment.expiryYear = Get-Random -Minimum 2024 -Maximum 2027
        if ($type -eq "credit_card") {
            $payment.cvv = Get-Random -Minimum 100 -Maximum 999
        }
    }
    
    return $payment
}

function Generate-User {
    param([int]$Index)
    
    $firstNames = @("James", "Maria", "Robert", "Sarah", "Michael", "Jennifer", "David", "Emily", "John", "Lisa", "Daniel", "Mary")
    $lastNames = @("Anderson", "Garcia", "Chen", "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Rodriguez", "Martinez")
    
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    $dob = (Get-Date).AddYears(-(Get-Random -Minimum 25 -Maximum 70)).AddDays(-(Get-Random -Minimum 0 -Maximum 365))
    
    $user = @{
        root_id = "u$(Get-Random -Minimum 10000 -Maximum 99999)"
        firstName = $firstName
        lastName = $lastName
        email = Generate-RandomEmail
        phone = Generate-RandomPhone
        ssn = Generate-RandomSSN
        dateOfBirth = $dob.ToString("yyyy-MM-dd")
        isActive = @($true, $false) | Get-Random
        createdAt = ((Get-Date).AddDays(-(Get-Random -Minimum 100 -Maximum 1500))).ToString("o")
        metadata = @{
            lastLogin = ((Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 60))).ToString("o")
            loginCount = Get-Random -Minimum 50 -Maximum 500
            preferredLanguage = @("en", "es", "fr", "de", "zh", "ja") | Get-Random
        }
        company = Generate-Company $Index
        addresses = @(
            @{
                address_id = "ua$(Get-Random -Minimum 10000 -Maximum 99999)"
                type = "home"
                street = "$(Get-Random -Minimum 100 -Maximum 999) Main Street"
                city = @("San Francisco", "New York", "Boston") | Get-Random
                state = @("CA", "NY", "MA") | Get-Random
                zipCode = (Get-Random -Minimum 10000 -Maximum 99999).ToString()
                isPrimary = $true
                verified = @($true, $false) | Get-Random
            }
            @{
                address_id = "ua$(Get-Random -Minimum 10000 -Maximum 99999)"
                type = "work"
                street = "$(Get-Random -Minimum 100 -Maximum 999) Business Avenue"
                city = @("San Francisco", "New York", "Boston") | Get-Random
                state = @("CA", "NY", "MA") | Get-Random
                zipCode = (Get-Random -Minimum 10000 -Maximum 99999).ToString()
                isPrimary = $false
                verified = @($true, $false) | Get-Random
            }
        )
        contacts = @(
            Generate-Contact $Index
            Generate-Contact ($Index + 1)
        )
        paymentMethods = @(
            Generate-PaymentMethod $Index
        )
    }
    
    return $user
}

Write-Host "Generating $FileSizeMB MB JSON test data..."
Write-Host "Output file: $OutputPath"

$users = @()
$fileSize = 0
$recordCount = 0

# Generate users until we reach target file size
while ($fileSize -lt ($FileSizeMB * 1024 * 1024)) {
    $user = Generate-User $recordCount
    $users += $user
    $recordCount++
    
    # Convert to JSON to check size every 100 records
    if ($recordCount % $RecordsPerBatch -eq 0) {
        $tempJson = $users | ConvertTo-Json -Depth 10
        $fileSize = [System.Text.Encoding]::UTF8.GetByteCount($tempJson)
        Write-Progress -Activity "Generating data" -Status "Records: $recordCount, Size: $([Math]::Round($fileSize / 1MB, 2)) MB" -PercentComplete ([Math]::Min(($fileSize / ($FileSizeMB * 1024 * 1024) * 100), 100))
    }
}

Write-Host "Writing to file..."
$users | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
$finalSize = (Get-Item $OutputPath).Length / 1MB

Write-Host "Complete!" -ForegroundColor Green
Write-Host "Generated $recordCount user records"
Write-Host "File size: $([Math]::Round($finalSize, 2)) MB"
Write-Host "File location: $(Resolve-Path $OutputPath)"
