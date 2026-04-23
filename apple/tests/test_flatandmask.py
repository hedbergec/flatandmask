import subprocess
import sys
import urllib.request
import csv
from pathlib import Path


def test_flatandmask_jsonplaceholder_masks_name_and_email(tmp_path):
    """Download a complex public JSON and run the processor, masking two fields."""
    url = 'https://jsonplaceholder.typicode.com/users'

    inp = tmp_path / 'users.json'
    with urllib.request.urlopen(url) as r:
        data = r.read()
    inp.write_bytes(data)

    outdir = tmp_path / 'out'
    keyfile = tmp_path / 'key.csv'

    # path to the processor (apple folder)
    proc = Path(__file__).resolve().parents[1] / 'flatandmask.py'

    cmd = [sys.executable, str(proc), '--input', str(inp), '--output', str(outdir), '--keyfile', str(keyfile), '--secret', 'unittest-secret', '--mask', 'root.name,root.email']

    subprocess.run(cmd, check=True)

    assert outdir.exists()
    root_csv = outdir / 'root.csv'
    assert root_csv.exists()

    # Check that mapping file exists and contains Original->Masked rows
    assert keyfile.exists()
    originals = []
    masked_lengths = []
    with open(keyfile, newline='', encoding='utf-8') as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            originals.append(row['Original'])
            masked_lengths.append(len(row['Masked']))

    # Expect at least one original value (names/emails present)
    assert len(originals) > 0
    # All masked values should be 12 characters (12-char prefix of base64 hash)
    assert all(l == 12 for l in masked_lengths)
