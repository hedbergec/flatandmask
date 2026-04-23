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
Unit tests
-
Install the test dependencies and run the unit tests included in `apple/tests`:

```bash
python3 -m pip install --user -r requirements.txt
python3 -m pytest -q
```

Example (complex public JSON)
-
This repo includes a pytest that downloads a publicly available, nested JSON (jsonplaceholder.typicode.com/users), runs the processor, and masks two fields (`root.name` and `root.email`). To run the same manual example:

```bash
mkdir -p examples
curl -s https://jsonplaceholder.typicode.com/users -o examples/jsonplaceholder_users.json
./flatandmask.sh \
	-i examples/jsonplaceholder_users.json \
	-o examples/out_jsonplaceholder \
	-k examples/key_jsonplaceholder.csv \
	-s 'my-secret-key' \
	-m 'root.name,root.email'
```

After running, inspect `examples/key_jsonplaceholder.csv` to see the Original→Masked mappings for the two masked fields.
```

3. (Optional) Create a virtual environment to isolate dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install openpyxl
```

Usage examples
-
- Example 1 — GitHub users (JSON):

```bash
./flatandmask.sh \
	-i ../examples/complex1.json \
	-o ../examples/out_mac \
	-k ../examples/key_mac.csv \
	-s 'my-secret-key' \
	-m 'root.login,root.avatar_url'
```

- Example 2 — CSV input:

```bash
./flatandmask.sh \
	-i ../examples/sample.csv \
	-o ../examples/out_csv_mac \
	-k ../examples/key_csv_mac.csv \
	-s 'my-secret-key' \
	-m 'root.Name,root.Email'
```

Notes on behavior and parity with PowerShell
- Masking: deterministic HMAC-SHA256 with Base64 and 12-character prefix — same as PowerShell.
- Output: one CSV per table (top-level `root.csv` plus nested child tables like `root_projects.csv`) and a mapping CSV with Original→Masked.
- XLSX: supported in `flatandmask.py` if `openpyxl` is installed. If not installed, the script will error with an instruction to install it.

Permissions and non-admin use
- The `pip3 --user` install and running the scripts do not require admin privileges.
- Use user-writable output locations (for example, under `~/Documents` or the project `examples` folder).

Troubleshooting
- "python3 not found": install Python 3 via Homebrew: `brew install python`
- "openpyxl required": run `python3 -m pip install --user openpyxl`
- If the shell script fails with permission errors, ensure `flatandmask.sh` is executable and output paths are writable.

Verifying outputs
- After a run, inspect the output folder you specified. Example:

```bash
ls -l ../examples/out_mac
head -n 5 ../examples/out_mac/root.csv
sed -n '1,20p' ../examples/key_mac.csv
```

Support
- If you want, I can add an automated dependency check to `flatandmask.sh` (auto-install `openpyxl --user` or print a one-line helper). Request that and I will add it.
