macOS Bash + Python implementation for flatandmask

Purpose
-
Provides a small macOS-friendly wrapper and a Python processor that reproduce the same outputs as the PowerShell implementation: one CSV per table (e.g., `root.csv`, `root_projects.csv`) plus a key mapping CSV.

Files
-
- `flatandmask.sh` — Bash wrapper (CLI entrypoint).
- `flatandmask.py` — Python processor implementing the flatten + mask logic.

Prerequisites
-
- macOS with Terminal and Python 3.x installed (3.8+ recommended).
- Optional (for `.xlsx` inputs): `openpyxl` Python package.

Quick setup
-
1. Make the wrapper executable:

```bash
cd apple
chmod +x flatandmask.sh
```

2. Install `openpyxl` if you need Excel support (per-user install, no admin required):

```bash
python3 -m pip install --user openpyxl
```

3. (Optional) Create a virtual environment to isolate dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install openpyxl
```

Usage examples
-
- Process a JSON example (writes outputs to `examples/out_mac` and mapping to `examples/key_mac.csv`):

```bash
./flatandmask.sh \
	-i ../examples/complex1.json \
	-o ../examples/out_mac \
	-k ../examples/key_mac.csv \
	-s 's3cr3t' \
	-m 'root.name,root.email'
```

- Process a CSV input (same flags apply):

```bash
./flatandmask.sh -i ../examples/sample.csv -o ../examples/out_csv_mac -k ../examples/key_csv_mac.csv -s 's3cr3t' -m 'root.name,root.email'
```

Notes on behavior and parity with PowerShell
-
- Masking: deterministic HMAC-SHA256 with Base64 and 12-character prefix — same as PowerShell.
- Output: one CSV per table (top-level `root.csv` plus nested child tables like `root_projects.csv`) and a mapping CSV with Original→Masked.
- XLSX: supported in `flatandmask.py` if `openpyxl` is installed. If not installed, the script will error with an instruction to install it.

Permissions and non-admin use
-
- The `pip3 --user` install and running the scripts do not require admin privileges.
- Use user-writable output locations (for example, under `~/Documents` or the project `examples` folder).

Troubleshooting
-
- "python3 not found": install Python 3 via Homebrew: `brew install python`
- "openpyxl required": run `python3 -m pip install --user openpyxl`
- If the shell script fails with permission errors, ensure `flatandmask.sh` is executable and output paths are writable.

Verifying outputs
-
After a run, inspect the output folder you specified. Example:

```bash
ls -l ../examples/out_mac
head -n 5 ../examples/out_mac/root.csv
cat ../examples/key_mac.csv | sed -n '1,20p'
```

Support
-
If you want, I can add an automated dependency check to `flatandmask.sh` (auto-install `openpyxl --user` or print a one-line helper). Request that and I will add it.
