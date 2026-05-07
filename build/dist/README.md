# Data Masking Tool v1.4.0

## Notice
NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: https://github.com/hedbergec/flatandmask. Contact: Eric Hedberg <hedbergec@outlook.com>.

## Quick Start
Double-click launch.bat to launch the tool

## Features
- HMAC-SHA256 deterministic masking
- CSV and JSON file support
- Interactive field selection
- JSON schema tree viewer
- Masking key audit trail
- Replication scripts
- Table normalization with deterministic IDs

## Replication Scripts
Each masking run writes replicate_masking.ps1 and DataMaskingTool.ps1 into the output folder. The replication script is a thin wrapper that loads the local DataMaskingTool.ps1 copy and calls Invoke-Masking with the same selected fields, secret key, and original input path. Run replicate_masking.ps1 with no arguments to replay against the original input, or pass -InputFile to use a moved or replacement file.
