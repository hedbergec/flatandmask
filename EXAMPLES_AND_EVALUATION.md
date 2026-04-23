# PowerShell Flatten & Mask Script - Evaluation & Examples

## Script Evaluation

### Overview
The `flatandmask.ps1` script processes JSON, CSV, and Excel files by:
1. **Flattening** nested structures into normalized relational tables
2. **Masking** sensitive fields using deterministic HMAC-SHA256 hashing
3. **Creating audit trails** with original-to-masked value mappings
4. **Exporting** to CSV with parent-child relationship tracking via GUIDs

### Strengths
✅ Handles multiple input formats (JSON, CSV, Excel)
✅ Deterministic masking (same input = same masked output for audit trails)
✅ Recursive processing of deeply nested structures
✅ Generates relationship IDs (_id, _parent_id) for denormalized to normalized conversion
✅ Creates mapping file for compliance/audit purposes
✅ Configurable field masking list
✅ No data loss - all fields preserved, only visibly masked

### Areas for Improvement

| Issue | Impact | Recommendation |
|-------|--------|-----------------|
| Secret key passed as plaintext CLI parameter | Security risk in command history | Use System.Vault or environment variables |
| No validation of mask field existence | Silent failures if typos in field names | Add pre-flight field validation |
| Limited error handling | Cryptic failures on bad input | Add try-catch with descriptive messages |
| Excel support requires ImportExcel module | Extra dependency needed | Document as optional feature |
| No logging/reporting of what was masked | Limited visibility | Add -Verbose logging of mask operations |
| Masking detection uses partial path matching | Could be ambiguous | Consider exact match or regex patterns |

### Use Cases
- **PII Redaction**: Mask names, emails, SSNs before sharing test data
- **Data Normalization**: Convert denormalized multi-level JSON to SQL-loadable CSVs
- **HIPAA/GDPR Compliance**: Create demo datasets from production data
- **API Response Flattening**: Convert REST API nested responses to tabular format
- **Audit Trails**: Map original values to masked values for compliance documentation

---

## Practical Examples Using Public Data

### Example 1: GitHub Users Data (JSON)

**Description**: Flatten and mask GitHub public users data

**Input Data URL**: `https://api.github.com/users?since=0&per_page=5`

**PowerShell Script**:
```powershell
# Step 1: Download public GitHub users data
$githubUsers = 'C:\Data\github-users.json'
$headers = @{ 'Accept' = 'application/vnd.github.v3+json' }
Invoke-RestMethod -Uri "https://api.github.com/users?since=0&per_page=5" `
    -Headers $headers -OutFile $githubUsers

# Step 2: Run flatten & mask
$params = @{
    InputFile  = $githubUsers
    OutputFolder = 'C:\Output\GitHub'
    KeyFile    = 'C:\Output\GitHub\github-mapping.csv'
    SecretKey  = 'my-secure-secret-key-12345'
    MaskFields = @(
        'root.login',      # GitHub usernames
        'root.avatar_url'  # Profile picture URLs
    )
}

.\flatandmask.ps1 @params

# Output: CSV files with flattened structure
# - root.csv (users)
# - github-mapping.csv (original→masked mappings)
```

**Expected Output Files**:
- `root.csv`: Normalized user records with _id (GUID), login (masked), avatar_url (masked), etc.
- `github-mapping.csv`: Maps original logins/URLs to masked values

**Before/After**:
```
Input JSON (partial):
{
  "login": "octocat",
  "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
  "public_repos": 42
}

Output CSV (root.csv):
_id,login,avatar_url,public_repos
550e8400-e29b-41d4-a716-446655440000,m6lw5VhJ7sTw==,d7Ej8mPl3q4+==,42

Mapping file (github-mapping.csv):
Original,Masked
octocat,m6lw5VhJ7sTw==
https://avatars.githubusercontent.com/u/1?v=4,d7Ej8mPl3q4+==
```

---

### Example 2: CSV Dataset with Nested Masking (Customer Data)

**Description**: Mask PII in customer transaction records

**Input Data URL**: `https://raw.githubusercontent.com/mledoze/countries/master/dist/countries.csv`
(simplified example - in practice, use customer data)

**PowerShell Script**:
```powershell
# Step 1: Create sample CSV data
$csv = @"
CustomerID,Name,Email,Phone,City
1001,John Smith,john@example.com,555-1234,New York
1002,Jane Doe,jane@example.com,555-5678,Los Angeles
1003,Bob Johnson,bob@example.com,555-9012,Chicago
"@ | Out-File -Path 'C:\Data\customers.csv' -Encoding UTF8

# Step 2: Run flatten & mask
$params = @{
    InputFile  = 'C:\Data\customers.csv'
    OutputFolder = 'C:\Output\Customers'
    KeyFile    = 'C:\Output\Customers\customer-mapping.csv'
    SecretKey  = 'prod-secret-key-xyz789'
    MaskFields = @(
        'root.Name',     # Names
        'root.Email',    # Emails
        'root.Phone',    # Phone numbers
        'root.City'      # Cities (optional)
    )
}

.\flatandmask.ps1 @params

# Output: 
# - root.csv (customers with PII masked)
# - customer-mapping.csv (audit trail)
```

**Output**:
```
File: root.csv
_id,CustomerID,Name,Email,Phone,City
550e8400-e29b-41d4-a716-446655440001,1001,aBcD3eF5g7h9==,zX9mK2lPq4rS==,nO7tU1vWxYz5==,aBcD3eF5g7==
550e8400-e29b-41d4-a716-446655440002,1002,lMnOpQrStUvW==,xWxVuUtStS2==,qPoPmNoL9876==,bBcD3eF5g8==

File: customer-mapping.csv
Original,Masked
John Smith,aBcD3eF5g7h9==
jane@example.com,zX9mK2lPq4rS==
555-1234,nO7tU1vWxYz5==
... (complete mapping for audit)
```

---

### Example 3: Complex Nested JSON (API Response)

**Description**: Flatten deeply nested API response and mask sensitive fields

**Input Data URL**: `https://jsonplaceholder.typicode.com/users` (simulated user data with nested posts)

**PowerShell Script**:
```powershell
# Step 1: Download nested JSON
$jsonData = Invoke-RestMethod -Uri "https://jsonplaceholder.typicode.com/users" -OutFile 'C:\Data\api-users.json'

# Step 2: Run flatten & mask
$params = @{
    InputFile  = 'C:\Data\api-users.json'
    OutputFolder = 'C:\Output\APIUsers'
    KeyFile    = 'C:\Output\APIUsers\api-mapping.csv'
    SecretKey  = 'api-secret-987654'
    MaskFields = @(
        'root.name',             # User names
        'root.email',            # Emails
        'root.phone',            # Phone numbers
        'root.website',          # Websites/URLs
        'root.company.name',     # Company names
        'root.address.city'      # Cities
    )
}

.\flatandmask.ps1 @params

# Output generates multiple CSV files due to nesting:
# - root.csv (users)
# - root_address.csv (addresses, linked via _parent_id)
# - root_geo.csv (coordinates)
# - root_company.csv (companies)
# - root_company_catchPhrases.csv (if array values exist)
```

**Output Structure**:
```
root.csv:
_id,name,email,phone,website,username,postId
550e8400-e29b-41d4-a716-446655440001,X7tKmL9pQ2rS==,aB3cDeF5g7hI==,jK1lMnO2p3qR==,sT5uVwX6y7zA==,Bret,1

root_address.csv:
_id,_parent_id,street,suite,city,zipcode
650e8400-e29b-41d4-a716-446655440011,550e8400-e29b-41d4-a716-446655440001,1230 High Street,Suite 500,bCdEfG5h8ij==,92556

root_company.csv:
_id,_parent_id,name,catchPhrase,bs
750e8400-e29b-41d4-a716-446655440021,550e8400-e29b-41d4-a716-446655440001,Acme Corp Masked...,engagement...,...
```

---

### Example 4: Excel Multi-Sheet Data

**Description**: Process Excel workbook with multiple sheets

**PowerShell Script**:
```powershell
# Prerequisites: Install-Module ImportExcel

$params = @{
    InputFile  = 'C:\Data\company-records.xlsx'  # Multiple sheets
    OutputFolder = 'C:\Output\CompanyData'
    KeyFile    = 'C:\Output\CompanyData\excel-mapping.csv'
    SecretKey  = 'excel-secret-key'
    MaskFields = @(
        'root.EmployeeName',
        'root.EmployeeID',
        'root.Email',
        'root.Salary'
    )
}

.\flatandmask.ps1 @params

# Each sheet becomes its own table with _sheet tag
# All PII masked per the SecretKey (deterministic)
# Mapping file allows reversal if needed
```

---

## Security Considerations

### Current Implementation
- **Masking Method**: HMAC-SHA256 with Base64 encoding (12-char prefix)
- **Advantage**: Deterministic (same input always produces same masked output)
- **Limitation**: Not cryptographically reversible without secret key (intentional)

### Recommendations for Production Use

1. **Secret Key Management**
   ```powershell
   # ❌ DON'T: Pass key as CLI parameter
   .\flatandmask.ps1 -SecretKey "my-password"
   
   # ✅ DO: Store in environment variable
   $env:FLATTEN_SECRET = 'secure-key-from-vault'
   .\flatandmask.ps1 -SecretKey $env:FLATTEN_SECRET
   
   # ✅ DO: Use Azure Key Vault or similar
   $secret = Get-AzKeyVaultSecret -VaultName MyVault -Name FlattenKey
   .\flatandmask.ps1 -SecretKey $secret.SecretValueText
   ```

2. **Audit Logging**
   Add to script before line 170:
   ```powershell
   Add-Content -Path "C:\Logs\flatten-audit.log" `
       -Value "$(Get-Date): Processed $($InputFile) - Masked $($MaskFields.Count) fields"
   ```

3. **Access Control**
   - Store mapping file in restricted location (admin-only access)
   - Log all access to mapping files
   - Separate mapping files from sanitized output

4. **Data Retention**
   - Delete mapping files after compliance period (e.g., 90 days)
   - Set retention policies on output CSVs

---

## Performance Notes

| Input Type | Size | Est. Time | Notes |
|-----------|------|-----------|-------|
| JSON | 10MB | 2-5 sec | Nested depth affects performance |
| CSV | 10MB (100k rows) | 5-10 sec | Linear with row count |
| Excel | 10MB (multiple sheets) | 10-20 sec | ImportExcel module slower |

**Optimization Tips**:
- For large files (>100MB), consider CSV over JSON
- Pre-filter unnecessary columns before processing
- Run with `-Verbose` to identify bottlenecks

---

## Troubleshooting

### Issue: "Excel input requires ImportExcel module"
```powershell
# Solution:
Install-Module -Name ImportExcel -Scope CurrentUser -Force
```

### Issue: MaskFields not applying
```powershell
# Check field names match exactly (case-sensitive):
# Incorrect: 'root.customername' 
# Correct:   'root.CustomerName'

# Use $Verbose to see actual field paths
```

### Issue: Output CSVs have thousands of rows from nested arrays
```powershell
# This is normal - each array item becomes a row
# Use _parent_id to reconstruct hierarchies
# Example: JOIN root_orders ON root._id = root_orders._parent_id
```

---

## Quick Reference

### Basic Syntax
```powershell
.\flatandmask.ps1 `
    -InputFile "C:\data\input.json" `
    -OutputFolder "C:\data\output" `
    -KeyFile "C:\data\mapping.csv" `
    -SecretKey "your-secret-key-here" `
    -MaskFields @('root.name', 'root.email', 'root.ssn')
```

### Field Path Naming Convention
```
JSON root level:       'root.fieldname'
Nested object:         'root.parent.child'
Array items:           'root.arrayname.value' (for scalar arrays)
Nested object in array: Creates separate tables: root_arrayname
```

### Output File Summary
| File | Contains | Use Case |
|------|----------|----------|
| root.csv | Flattened root objects | Primary data table |
| root_*.csv | Child tables from nesting | Denormalized relationships |
| *-mapping.csv | Original→masked mappings | Audit trail, compliance |

---

## Complete End-to-End Example

```powershell
# 1. Create test data
$testJson = @"
[
  {
    "id": 1,
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "department": "Engineering",
    "projects": [
      { "name": "ProjectA", "budget": 50000 },
      { "name": "ProjectB", "budget": 75000 }
    ]
  }
]
"@ | Out-File -Path 'C:\test-data.json'

# 2. Run flatten & mask
$params = @{
    InputFile  = 'C:\test-data.json'
    OutputFolder = 'C:\output'
    KeyFile    = 'C:\output\mapping.csv'
    SecretKey  = 'my-secure-key'
    MaskFields = @('root.name', 'root.email')
}

.\flatandmask.ps1 @params

Write-Host "✓ Processing complete!"
Write-Host "Output files in: C:\output\"
Get-ChildItem C:\output\ -Filter *.csv | ForEach-Object { Write-Host "  - $($_.Name)" }

# 3. View results
Import-Csv 'C:\output\root.csv'
Import-Csv 'C:\output\mapping.csv'
```

## Local Test (examples)

- **Example files**: a small JSON and CSV are included in the `examples` subfolder:
    - `examples/sample.json`
    - `examples/sample.csv`

- **Run using GUI (double-click)**: run the launcher `flatandmask_run.bat` in the script folder to open the GUI and choose files.

- **Run a non-interactive test** (PowerShell):
```powershell
$script = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\flatandmask_gui.ps1'
$input  = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\sample.json'
$out    = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\out'
$key    = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\key.csv'
$mask   = @('root.name','root.email')
& $script -InputFile $input -OutputFolder $out -KeyFile $key -SecretKey 's3cr3t' -MaskFields $mask
```

After running, check the `examples/out` folder for generated CSV tables and `examples/key.csv` for the mapping file.

