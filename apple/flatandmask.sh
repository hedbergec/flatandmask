#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") -i INPUT -o OUTPUT_FOLDER -k KEYFILE -s SECRET [-m "field1,field2"]

A macOS-friendly wrapper for the flatandmask processor.
Requires: python3 (and optionally openpyxl for .xlsx support).

Options:
  -i|--input      Input file (JSON or CSV, .xlsx optional)
  -o|--out        Output folder
  -k|--keyfile    Key file (CSV) to write mapping
  -s|--secret     Secret key used for deterministic masking
  -m|--mask       Comma-separated mask fields (like 'root.name,root.email')
  -h|--help       Show this help

Example:
  ./flatandmask.sh -i examples/complex1.json -o examples/out_mac -k examples/key_mac.csv -s "s3cr3t" -m "root.name,root.email"
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

INPUT=""
OUT=""
KEYFILE=""
SECRET=""
MASK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input) INPUT="$2"; shift 2;;
    -o|--out) OUT="$2"; shift 2;;
    -k|--keyfile) KEYFILE="$2"; shift 2;;
    -s|--secret) SECRET="$2"; shift 2;;
    -m|--mask) MASK="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 1;;
  esac
done

if [[ -z "$INPUT" || -z "$OUT" || -z "$KEYFILE" || -z "$SECRET" ]]; then
  echo "Missing required args."
  usage
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. Please install Python 3.x." >&2
  exit 2
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
python3 "$SCRIPT_DIR/flatandmask.py" --input "$INPUT" --output "$OUT" --keyfile "$KEYFILE" --secret "$SECRET" --mask "$MASK"

exit 0
