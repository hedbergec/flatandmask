# Data Masking Tool

**Version 1.0.1**

## ⚠️ Disclaimer

This tool was developed through rapid prototyping and intuitive development (vibe coded). While functional and tested, it comes with **limited liability**. Users are responsible for:

- Testing the tool thoroughly with non-production data first
- Validating all masked outputs before use
- Maintaining secure backups of original data
- Storing masking keys securely
- Complying with applicable data protection regulations

**Use at your own risk.**

## Overview

Data Masking Tool is a self-contained PowerShell GUI application that deterministically masks sensitive fields in JSON and CSV files using HMAC-SHA256 hashing. The same input value always produces the same masked output, making it useful for creating consistent test datasets while protecting sensitive information.

### Key Features

- **Deterministic Masking**: Same input = same masked value (using HMAC-SHA256)
- **Multi-Format Support**: Process JSON and CSV files with identical interface
- **Interactive Field Selection**: Choose which columns/fields to mask via GUI
- **JSON Schema Tree Viewer**: Searchable tree browser for complex nested JSON structures
- **Complete Data Export**: All data exported; only selected fields are masked
- **Audit Trail**: Generate masking key files mapping original → masked values
- **Table Normalization**: Nested JSON automatically normalized into related CSV tables with foreign keys
- **Deterministic IDs**: Parent-child relationships maintained for manual merging/joining
- **Replication Scripts**: Auto-generated scripts to re-run masking on new data with consistent results
- **Portable Single EXE**: Fully self-contained executable with zero external dependencies

## System Requirements

- **Windows 7** or later
- **PowerShell 3.0+**
- **.NET Framework 4.5+**
- **ps2exe module** (for building EXE only)

## Installation & Deployment

### Option 1: PowerShell Script (Direct Execution)

1. Keep only these files:

   - `DataMaskingTool.ps1`
2. Run in PowerShell:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\DataMaskingTool.ps1
   ```

### Option 2: Batch File Launcher

1. Keep only:

   - `DataMaskingTool.ps1`
   - `launch.bat`
2. Double-click `launch.bat` to start the GUI

Avoids manual execution policy configuration.

### Option 3: Standalone EXE (Fully Portable)

1. Build the EXE:

   ```powershell
   .\Build.ps1 -BuildEXE
   ```
2. Copy only `DataMaskingTool.exe` from the `build/exe/` folder
3. Double-click `DataMaskingTool.exe` on any Windows machine

No PowerShell, installation, or configuration needed.

## Usage

### Basic Workflow

```
1. Launch Tool
   ↓
2. Select Input File (JSON or CSV)
   ↓
3. View Schema (Optional: for JSON files)
   ↓
4. Select Fields to Mask
   ↓
5. Enter Secret Key
   ↓
6. Run Masking
   ↓
7. Review Output Files
```

### Detailed Steps

#### 1. Launch the Application

**PowerShell:**

```powershell
.\DataMaskingTool.ps1
```

**Batch File:**

```batch
launch.bat
```

**EXE:**

```
Double-click DataMaskingTool.exe
```

#### 2. Select Input File

Click "Browse..." next to "Input File (JSON/CSV)" and choose your data file.

**Supported Formats:**

- `*.json` - JSON files with objects or arrays of objects
- `*.csv` - CSV files with headers

#### 3. View JSON Schema (Optional)

For JSON files only: Click "View Tree" to browse the schema structure with search functionality.

#### 4. Select Fields to Mask

Click "Select Fields to Mask" to open the field selection dialog.

**For JSON Files:**

- Shows all nested field paths (e.g., `root.user.email`, `root.address.city`)
- PowerShell internal properties are auto-filtered
- Check boxes for sensitive fields

**For CSV Files:**

- Shows all column names
- Check boxes for columns containing sensitive data

#### 5. Enter Secret Key

Enter a strong, memorable secret key. This key:

- Determines the masked output values
- Must remain consistent for replication and merging
- Should be stored securely

**Example keys:**

```
MyCompany_TestEnv_Q2024
SecretKey_PII_Masking_V1
```

#### 6. Run Masking

Click "Run Masking" to process the file.

#### 7. Review Output

Output files are saved to your chosen output folder.

## Output Files

### CSV Files (All Data)

**data.csv** - Complete dataset with selected fields masked and all others intact

```csv
id,name,email,phone,department
1,John Doe,ABC123XYZ,DEF456GHI,Sales
2,Jane Smith,JKL789MNO,PQR012STU,Marketing
```

**Additional normalized tables** (e.g., user.csv, address.csv, contact.csv)

- Generated from nested JSON structures
- Include foreign key relationships (root_id, user_id, address_id, etc.)
- Usable for manual SQL/Excel JOIN operations

### Masking Key

**masking_key.csv** - Complete mapping of original → masked values with field names

```csv
Original,Masked,Field
john.doe@company.com,ABC123XYZ,email
jane.smith@company.com,JKL789MNO,email
555-1234,DEF456GHI,phone
```

Uses for this file:

- Verify masking consistency
- Troubleshoot data issues
- Create reverse lookups (if needed)
- Audit trail of what was masked

### JSON Export (JSON Input Only)

**<filename>_masked.json** - Full JSON with original structure preserved, only selected fields masked

```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "ABC123XYZ",
    "phone": "DEF456GHI",
    "address": {
      "street": "123 Main St",
      "city": "Springfield"
    }
  }
]
```

### Replication Script

**replicate_masking.ps1** - Auto-generated script containing all masking logic and settings

Usage:

```powershell
.\replicate_masking.ps1 -InputFile "new_data.json"

# Or with custom parameters:
.\replicate_masking.ps1 -InputFile "data.csv" -OutputFolder "C:\output" -SecretKey "MyKey"
```

Ensures new data is masked with identical values and table structure.

## CSV-Specific Functionality

### Field Selection

Interactive dialog shows all CSV column names. Select any combination of columns to mask.

### Selective Masking

Only checked columns are masked. All other columns are exported unchanged.

### Complete Export

Entire dataset exported as CSV with all original rows. Masked columns contain hash values instead of original data.

### Deterministic Output

Same secret key + same CSV = identical masked values every time. Allows dataset replication and merging.

### Masking Key for CSV

Complete mapping of all masked values created, including field name for each masked value.

### Table Normalization

CSV data is processed through normalization logic:

- Flat CSV stays as single table: `data.csv`
- Generates `masking_key.csv` with all original→masked mappings
- Generates replication script with identical masking logic

### Replication for CSV

Auto-generated `replicate_masking.ps1` can re-run same masking on new CSV files:

- Uses same secret key for consistent values
- Applies same field selections
- Outputs same structure

### Merging Masked CSVs

When running replication:

- Secret key determines masked values (deterministic)
- Same input produces same output
- You can safely merge multiple masked datasets with consistent IDs
- Export all tables from replication for JOIN operations

## Examples

### Example 1: Mask Customer PII in CSV

**Input:** `customers.csv`

```csv
customer_id,name,email,phone,signup_date
101,Alice Johnson,alice@mail.com,555-0001,2024-01-15
102,Bob Smith,bob@mail.com,555-0002,2024-02-20
```

**Steps:**

1. Launch tool
2. Select `customers.csv`
3. Select fields: `email`, `phone`
4. Enter key: `TestMask_2024`
5. Click Run

**Output:** `data.csv`

```csv
customer_id,name,email,phone,signup_date
101,Alice Johnson,KmF7JxQpL2,NmPqRsTu,2024-01-15
102,Bob Smith,VwXyZaBcD,EfGhIjKl,2024-02-20
```

**Output:** `masking_key.csv`

```csv
Original,Masked,Field
alice@mail.com,KmF7JxQpL2,email
bob@mail.com,VwXyZaBcD,email
555-0001,NmPqRsTu,phone
555-0002,EfGhIjKl,phone
```

### Example 2: Mask Nested JSON with Tables

**Input:** `users.json`

```json
[
  {
    "id": 1,
    "profile": {
      "name": "Charlie Brown",
      "email": "charlie@example.com"
    },
    "contact": {
      "phone": "555-0003",
      "address": "456 Oak Ave"
    }
  }
]
```

**Selected fields:** `root.profile.email`, `root.contact.phone`

**Outputs:**

`data.csv` (normalized root table):

```csv
root_id,id,name,address
abc12345,1,Charlie Brown,456 Oak Ave
```

`profile.csv` (nested profile table):

```csv
root_id,profile_id,name,email
abc12345,prof1111,Charlie Brown,OpQrStUvWx
```

`contact.csv` (nested contact table):

```csv
root_id,contact_id,phone
abc12345,cont1111,YzAbCdEfGh
```

**Note:** `root_id` in child tables links back to parent for JOIN operations.

### Example 3: Replication with Consistent IDs

After initial masking with secret key `TestMask_2024`:

```powershell
# Run on new data with same key = same masked values
.\replicate_masking.ps1 -InputFile "new_customers.csv" -SecretKey "TestMask_2024"
```

Results:

- `alice@mail.com` always masks to `KmF7JxQpL2`
- Same deterministic IDs generated
- Safe to merge multiple masked datasets

## Merging Masked Data with IDs

The tool generates usable IDs for manual merging:

**Key Features:**

- Each table gets a unique ID column (`root_id`, `user_id`, `address_id`, etc.)
- Parent-child relationships maintained through foreign key IDs
- IDs are deterministic (same input + same key = same ID)
- IDs enable SQL or Excel JOIN operations
- Cross-reference child tables back to parent using ID columns

**Manual Merge Example:**

```sql
SELECT d.*, p.email, c.phone
FROM data d
LEFT JOIN profile p ON d.root_id = p.root_id
LEFT JOIN contact c ON d.root_id = c.root_id
```

## Security Considerations

⚠️ **Important:**

1. **Secret Keys**: Treat like passwords. Store securely (encrypted password manager, secure vault, etc.)
2. **Masking Keys**: The `masking_key.csv` file enables reverse-lookup. Store securely or delete after verification.
3. **Original Data**: Keep backups. Masking is irreversible without key mappings.
4. **Shared Environments**: Run on secure, isolated systems when processing real PII.
5. **Deterministic Nature**: Same values always produce same masks. Patterns may be identifiable.
6. **Compliance**: Ensure use complies with GDPR, CCPA, HIPAA, or other applicable regulations.

## Troubleshooting

### "PowerShell execution policy" Error

**Solution - Temporary:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\DataMaskingTool.ps1
```

**Solution - Persistent:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "No fields selected" But Tool Ran

**Cause:** Selection dialog was canceled

**Solution:** Click "Select Fields to Mask" again and check boxes.

### Output Files Are Empty

**Causes:**

- Input file format issue or invalid JSON/CSV
- No fields selected for masking
- Input file locked by another program

**Solutions:**

1. Verify input file is valid JSON/CSV
2. Ensure at least one field is selected
3. Close other programs using the file

### EXE Won't Launch

**Cause:** Missing dependencies (shouldn't happen with consolidated version)

**Solution:** Use the PowerShell script or batch file instead.

## Building the EXE

### Prerequisites

```powershell
Install-Module -Name ps2exe -Force
```

### Build Command

```powershell
.\Build.ps1 -BuildEXE
```

Outputs:

- `build/dist/` - PowerShell portable version
- `build/exe/` - Standalone EXE (fully portable)


## Files Structure

**Minimal deployment:**

```
DataMaskingTool.exe              # Portable, no dependencies
```

**Or with script:**

```
DataMaskingTool.ps1              # Main script
launch.bat                        # Batch launcher (optional)
```

## Version History

- **v1.0.1** - Consolidated single file, JSON tree viewer, complete CSV masking, table normalization, deterministic IDs for merging
- **v1.0.0** - Initial multi-file release

## Support & Feedback

This tool was developed as a rapid prototype. For issues:

1. Test with sample data first
2. Verify all input files are valid JSON/CSV
3. Check the Troubleshooting section above
4. Validate output against input before production use

## License & Liability

This software is provided "as-is" with no warranty. Use at your own risk. The authors are not liable for any data loss, corruption, or other issues arising from use of this tool.
