
function Validate-JsonStructure {
    param(
        [string]$OriginalPath,
        [string]$MaskedPath,
        [string[]]$MaskedFields
    )
    
    $results = @()
    
    # Load both files
    $original = Get-Content $OriginalPath -Raw | ConvertFrom-Json
    $masked = Get-Content $MaskedPath -Raw | ConvertFrom-Json
    
    Write-Host "JSON Structure Validation" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    
    # Test 1: Root element count
    $origCount = if ($original -is [System.Collections.IEnumerable]) { @($original).Count } else { 1 }
    $maskedCount = if ($masked -is [System.Collections.IEnumerable]) { @($masked).Count } else { 1 }
    $test1 = $origCount -eq $maskedCount
    $results += [PSCustomObject]@{
        Test = "Root element count"
        Original = $origCount
        Masked = $maskedCount
        Pass = $test1
    }
    
    Write-Host "Test 1 - Original count: $origCount, Masked count: $maskedCount" -ForegroundColor Yellow
    
    # Get first object for property comparison
    $origFirst = if ($original -is [System.Collections.IEnumerable]) { @($original)[0] } else { $original }
    $maskedFirst = if ($masked -is [System.Collections.IEnumerable]) { @($masked)[0] } else { $masked }
    
    # Test 2: Property count per object
    $originalProps = $origFirst.PSObject.Properties.Name.Count
    $maskedProps = $maskedFirst.PSObject.Properties.Name.Count
    
    $test2 = $originalProps -eq $maskedProps
    $results += [PSCustomObject]@{
        Test = "Properties per object"
        Original = $originalProps
        Masked = $maskedProps
        Pass = $test2
    }
    
    # Test 3: Nesting levels
    function Get-NestingLevel {
        param($Object, [int]$Level = 0)
        $maxLevel = $Level
        
        if ($Object -is [PSCustomObject]) {
            $properties = $Object.PSObject.Properties
            foreach ($prop in $properties) {
                if ($prop.Value -is [PSCustomObject]) {
                    $nestedLevel = Get-NestingLevel $prop.Value ($Level + 1)
                    if ($nestedLevel -gt $maxLevel) { $maxLevel = $nestedLevel }
                }
                elseif ($prop.Value -is [System.Collections.IEnumerable] -and $prop.Value -isnot [string]) {
                    $first = @($prop.Value)[0]
                    if ($null -ne $first -and $first -is [PSCustomObject]) {
                        $nestedLevel = Get-NestingLevel $first ($Level + 1)
                        if ($nestedLevel -gt $maxLevel) { $maxLevel = $nestedLevel }
                    }
                }
            }
        }
        
        return $maxLevel
    }
    
    $origLevel = Get-NestingLevel $origFirst
    $maskedLevel = Get-NestingLevel $maskedFirst
    $test3 = $origLevel -eq $maskedLevel
    $results += [PSCustomObject]@{
        Test = "Maximum nesting level"
        Original = $origLevel
        Masked = $maskedLevel
        Pass = $test3
    }
    
    # Test 4: Array element counts
    function Get-ArrayCounts {
        param($Object)
        $counts = @()
        
        if ($Object -is [PSCustomObject]) {
            $properties = $Object.PSObject.Properties
            foreach ($prop in $properties) {
                if ($prop.Value -is [System.Collections.IEnumerable] -and $prop.Value -isnot [string]) {
                    $count = @($prop.Value).Count
                    $counts += $count
                }
            }
        }
        return $counts
    }
    
    $origArrays = Get-ArrayCounts $origFirst
    $maskedArrays = Get-ArrayCounts $maskedFirst
    
    $arrayMatch = $true
    if ($origArrays.Count -ne $maskedArrays.Count) {
        $arrayMatch = $false
    } else {
        for ($i = 0; $i -lt $origArrays.Count; $i++) {
            if ($origArrays[$i] -ne $maskedArrays[$i]) {
                $arrayMatch = $false
            }
        }
    }
    
    $origArraySum = if ($origArrays.Count -gt 0) { ($origArrays | Measure-Object -Sum).Sum } else { 0 }
    $maskedArraySum = if ($maskedArrays.Count -gt 0) { ($maskedArrays | Measure-Object -Sum).Sum } else { 0 }
    
    $results += [PSCustomObject]@{
        Test = "Array element counts"
        Original = $origArraySum
        Masked = $maskedArraySum
        Pass = $arrayMatch
    }
    
    # Display results
    $results | Format-Table -AutoSize
    
    $passCount = ($results | Where-Object { $_.Pass -eq $true }).Count
    $totalTests = $results.Count
    
    Write-Host ""
    Write-Host "JSON Summary: $passCount/$totalTests tests passed" -ForegroundColor $(if ($passCount -eq $totalTests) { "Green" } else { "Yellow" })
    
    return $results
}

function Validate-CsvStructure {
    param(
        [string]$OriginalPath,
        [string]$MaskedPath,
        [string[]]$MaskedFields
    )
    
    $results = @()
    
    # Load both files
    $original = Import-Csv $OriginalPath
    $masked = Import-Csv $MaskedPath
    
    Write-Host ""
    Write-Host "CSV Structure Validation" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    
    # Test 1: Row count
    $origRowCount = @($original).Count
    $maskedRowCount = @($masked).Count
    $test1 = $origRowCount -eq $maskedRowCount
    $results += [PSCustomObject]@{
        Test = "Row count"
        Original = $origRowCount
        Masked = $maskedRowCount
        Pass = $test1
    }
    
    # Test 2: Column count
    $origColCount = @($original)[0].PSObject.Properties.Name.Count
    $maskedColCount = @($masked)[0].PSObject.Properties.Name.Count
    $test2 = $origColCount -eq $maskedColCount
    $results += [PSCustomObject]@{
        Test = "Column count"
        Original = $origColCount
        Masked = $maskedColCount
        Pass = $test2
    }
    
    # Test 3: Column names match
    $origColumns = @($original)[0].PSObject.Properties.Name | Sort-Object
    $maskedColumns = @($masked)[0].PSObject.Properties.Name | Sort-Object
    $colMatch = @(Compare-Object $origColumns $maskedColumns).Count -eq 0
    $results += [PSCustomObject]@{
        Test = "Column names match"
        Original = $origColumns.Count
        Masked = $maskedColumns.Count
        Pass = $colMatch
    }
    
    # Test 4: Empty cell preservation
    function Count-EmptyCells {
        param($Data)
        $count = 0
        foreach ($row in $Data) {
            foreach ($col in $row.PSObject.Properties) {
                if ([string]::IsNullOrWhiteSpace($col.Value)) {
                    $count++
                }
            }
        }
        return $count
    }
    
    $origEmpty = Count-EmptyCells $original
    $maskedEmpty = Count-EmptyCells $masked
    $emptyMatch = $origEmpty -eq $maskedEmpty
    $results += [PSCustomObject]@{
        Test = "Empty cells preserved"
        Original = $origEmpty
        Masked = $maskedEmpty
        Pass = $emptyMatch
    }
    
    # Test 5: Masked fields changed
    $maskedChangedCount = 0
    foreach ($maskedField in $MaskedFields) {
        for ($i = 0; $i -lt @($original).Count; $i++) {
            foreach ($col in @($original)[$i].PSObject.Properties.Name) {
                if ($col -like "*$maskedField*") {
                    $origVal = @($original)[$i].$col
                    $maskedVal = @($masked)[$i].$col
                    if (-not [string]::IsNullOrEmpty($origVal) -and $origVal -ne $maskedVal) {
                        $maskedChangedCount++
                    }
                }
            }
        }
    }
    
    $results += [PSCustomObject]@{
        Test = "Masked fields changed"
        Original = "N/A"
        Masked = $maskedChangedCount
        Pass = $maskedChangedCount -gt 0
    }
    
    # Display results
    $results | Format-Table -AutoSize
    
    $passCount = ($results | Where-Object { $_.Pass -eq $true }).Count
    $totalTests = $results.Count
    
    Write-Host ""
    Write-Host "CSV Summary: $passCount/$totalTests tests passed" -ForegroundColor $(if ($passCount -eq $totalTests) { "Green" } else { "Yellow" })
    
    return $results
}

# ==================== Masking Functions ====================
function Normalize-FieldName {
    param([string]$FieldPath)
    if ($FieldPath.StartsWith("root.")) {
        return $FieldPath.Substring(5)
    }
    return $FieldPath
}

function Should-MaskField {
    param([string]$FieldPath, [string[]]$MaskFields)
    $normalized = Normalize-FieldName $FieldPath
    foreach ($maskField in $MaskFields) {
        $normalizedMask = Normalize-FieldName $maskField
        if ($normalized -eq $normalizedMask) {
            return $true
        }
    }
    return $false
}

function Get-MaskedValue {
    param($Value, $Key)
    if ([string]::IsNullOrEmpty($Value)) { return $Value }
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($Key)
    $bytes = [Text.Encoding]::UTF8.GetBytes([string]$Value)
    $hash = $hmac.ComputeHash($bytes)
    return ([Convert]::ToBase64String($hash).Substring(0, 12))
}

function Invoke-TestMasking {
    param(
        [string]$InputFile,
        [string]$OutputFolder,
        [string]$KeyFile,
        [string]$SecretKey,
        [string[]]$MaskFields
    )
    
    $Mapping = @{}
    $MappingWithRows = @{}
    $Tables = @{}
    
    function Mask-IfNeeded {
        param($FieldName, $Value, $RowIndex = $null)
        if (Should-MaskField $FieldName $MaskFields) {
            $strVal = [string]$Value
            $normalizedField = Normalize-FieldName $FieldName
            if (-not $Mapping.ContainsKey($strVal)) {
                $Mapping[$strVal] = @{
                    Masked = Get-MaskedValue $strVal $SecretKey
                    Field = $normalizedField
                }
            }
            
            $MappingWithRows[$strVal] = [PSCustomObject]@{
                Original = $strVal
                Masked   = $Mapping[$strVal].Masked
                Field    = $normalizedField
                RowIndex = $RowIndex
            }
            
            return $Mapping[$strVal].Masked
        }
        return $Value
    }
    
    $ext = [System.IO.Path]::GetExtension($InputFile).ToLower()
    
    if ($ext -eq ".csv") {
        $data = Import-Csv $InputFile -ErrorAction Stop
        $dataArray = @($data)
        
        $maskedData = @($dataArray | ForEach-Object -Begin { $rowIdx = 0 } -Process {
            $maskedRow = [PSCustomObject]@{}
            $_.PSObject.Properties | ForEach-Object {
                if (-not ($_.Name -like "PS*") -and $_.Name -ne "SyncRoot") {
                    $name = $_.Name
                    $value = $_.Value
                    $fieldPath = "root.$name"
                    $maskedValue = Mask-IfNeeded $fieldPath $value $rowIdx
                    $maskedRow | Add-Member -NotePropertyName $name -NotePropertyValue $maskedValue
                }
            }
            $rowIdx++
            $maskedRow
        })
        
        if (-not (Test-Path $OutputFolder)) {
            New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
        }
        
        $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
        $csvOutputPath = Join-Path $OutputFolder "$inputFileName.csv"
        $maskedData | Export-Csv -NoTypeInformation -Path $csvOutputPath -Force -Encoding UTF8
        
        $keyFilePath = Join-Path $OutputFolder "masking_key.csv"
        if ($MappingWithRows.Count -gt 0) {
            $MappingWithRows.Values | Select-Object Original, Masked, Field, RowIndex | Export-Csv -NoTypeInformation -Path $keyFilePath -Force -Encoding UTF8
        }
        
        Write-Host "Masked: $InputFile -> $csvOutputPath" -ForegroundColor Green
    }
}

# ==================== Run Masking Procedures ====================
Write-Host "Running Masking Procedures..." -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$secretKey = "testkey123"

# Test data files to mask
$testFiles = @(
    @{Input = ".\test_data\test_data.json"; Output = ".\test_output"; Fields = @("email", "phone", "ssn", "firstName", "lastName")},
    @{Input = ".\example data\2026-02-city-of-london-outcomes.csv"; Output = ".\test_output"; Fields = @("Reported by")}
)

foreach ($testFile in $testFiles) {
    if (Test-Path $testFile.Input) {
        Write-Host "Processing: $($testFile.Input)" -ForegroundColor Yellow
        $keyFile = Join-Path $testFile.Output "masking_key.csv"
        Invoke-TestMasking -InputFile $testFile.Input -OutputFolder $testFile.Output -KeyFile $keyFile -SecretKey $secretKey -MaskFields $testFile.Fields
    } else {
        Write-Host "Skipping (not found): $($testFile.Input)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Masking Complete!" -ForegroundColor Green
Write-Host ""

# ==================== Run Validations ====================
$maskedFields = @("email", "phone", "ssn", "name")

if ((Test-Path ".\test_data\test_data.json") -and (Test-Path ".\test_output\test_data_masked.json")) {
    Validate-JsonStructure -OriginalPath ".\test_data\test_data.json" -MaskedPath ".\test_output\test_data_masked.json" -MaskedFields $maskedFields
}

# Also test London data if it exists
$londonMaskedFields = @("Reported by")
if ((Test-Path ".\example data\2026-02-city-of-london-outcomes.csv") -and (Test-Path ".\test_output\2026-02-city-of-london-outcomes.csv")) {
    Validate-CsvStructure -OriginalPath ".\example data\2026-02-city-of-london-outcomes.csv" -MaskedPath ".\test_output\2026-02-city-of-london-outcomes.csv" -MaskedFields $londonMaskedFields
}
