#!/usr/bin/env python3
"""
flatandmask.py - Processor used by the mac/bash wrapper.
Supports JSON and CSV input. XLSX supported if openpyxl is installed.
Produces per-table CSVs and a key mapping CSV matching the PowerShell outputs.
"""
import argparse
import csv
import json
import os
import sys
import uuid
import hmac
import hashlib
import base64
from collections import defaultdict

try:
    from typing import Any
except Exception:
    pass


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--input', '-i', required=True)
    p.add_argument('--output', '-o', dest='output', required=True)
    p.add_argument('--keyfile', '-k', required=True)
    p.add_argument('--secret', '-s', required=True)
    p.add_argument('--mask', '-m', default='')
    return p.parse_args()


MASK_FIELDS = []
MAPPING = {}
TABLES = defaultdict(list)


def ensure_out(path):
    os.makedirs(path, exist_ok=True)


def get_masked(value, key):
    if value is None:
        return value
    s = str(value)
    if s == '':
        return s
    if s in MAPPING:
        return MAPPING[s]
    hm = hmac.new(key.encode('utf-8'), s.encode('utf-8'), hashlib.sha256).digest()
    b = base64.b64encode(hm).decode('ascii')
    masked = b[:12]
    MAPPING[s] = masked
    return masked


def mask_if_needed(fieldname, value):
    if fieldname in MASK_FIELDS:
        return get_masked(value, SECRET)
    return value


def add_to_table(table_name, row):
    TABLES[table_name].append(row)


def process_object(obj, table_name='root', parent_id=None):
    current_id = str(uuid.uuid4())
    row = {}
    row['_id'] = current_id
    if parent_id:
        row['_parent_id'] = parent_id

    if not isinstance(obj, dict):
        # scalar treated as value
        row['value'] = mask_if_needed(f'{table_name}.value', obj)
        add_to_table(table_name, row)
        return

    for k, v in obj.items():
        if isinstance(v, dict):
            process_object(v, f'{table_name}_{k}', current_id)
        elif isinstance(v, list):
            for item in v:
                if isinstance(item, dict):
                    process_object(item, f'{table_name}_{k}', current_id)
                else:
                    child = {
                        '_id': str(uuid.uuid4()),
                        '_parent_id': current_id,
                        'value': mask_if_needed(f'{table_name}.{k}', item)
                    }
                    add_to_table(f'{table_name}_{k}', child)
        else:
            row[k] = mask_if_needed(f'{table_name}.{k}', v)

    add_to_table(table_name, row)


def process_flat_data(rows, table_name='root'):
    for r in rows:
        newrow = {}
        newrow['_id'] = str(uuid.uuid4())
        for k, v in r.items():
            newrow[k] = mask_if_needed(f'{table_name}.{k}', v)
        add_to_table(table_name, newrow)


def export_tables(outdir):
    ensure_out(outdir)
    for tname, rows in TABLES.items():
        # determine headers
        headers = set()
        for r in rows:
            headers.update(r.keys())
        headers = list(headers)
        path = os.path.join(outdir, f"{tname}.csv")
        with open(path, 'w', newline='', encoding='utf-8') as fh:
            writer = csv.DictWriter(fh, fieldnames=headers)
            writer.writeheader()
            for r in rows:
                writer.writerow(r)


def export_mapping(path):
    ensure_out(os.path.dirname(path) or '.')
    with open(path, 'w', newline='', encoding='utf-8') as fh:
        writer = csv.writer(fh)
        writer.writerow(['Original', 'Masked'])
        for orig, masked in MAPPING.items():
            writer.writerow([orig, masked])


def load_input(path):
    ext = os.path.splitext(path)[1].lower()
    if ext == '.json':
        with open(path, 'r', encoding='utf-8') as fh:
            data = json.load(fh)
        return data
    elif ext == '.csv':
        with open(path, 'r', encoding='utf-8') as fh:
            reader = csv.DictReader(fh)
            return list(reader)
    elif ext == '.xlsx':
        try:
            import openpyxl
        except ImportError:
            raise RuntimeError('XLSX support requires openpyxl (pip install openpyxl)')
        wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
        result = []
        for sheet in wb.sheetnames:
            ws = wb[sheet]
            rows = list(ws.values)
            if not rows:
                continue
            headers = [str(h) for h in rows[0]]
            for row in rows[1:]:
                d = {headers[i]: row[i] for i in range(len(headers))}
                d['_sheet'] = sheet
                result.append(d)
        return result
    else:
        raise RuntimeError(f'Unsupported input type: {ext}')


if __name__ == '__main__':
    args = parse_args()
    INPUT = args.input
    OUTPUT = args.output
    KEYFILE = args.keyfile
    SECRET = args.secret
    MASK = args.mask

    MASK_FIELDS = [m.strip() for m in MASK.split(',') if m.strip()]

    # expose SECRET + MASK_FIELDS to functions
    global SECRET
    SECRET = SECRET
    global MASK_FIELDS
    MASK_FIELDS = MASK_FIELDS

    ensure_out(OUTPUT)

    data = load_input(INPUT)

    # Determine flat vs json objects
    if isinstance(data, list) and data and isinstance(data[0], dict) and (INPUT.lower().endswith('.csv') or INPUT.lower().endswith('.xlsx')):
        process_flat_data(data, 'root')
    else:
        if not isinstance(data, list):
            data = [data]
        for obj in data:
            process_object(obj, 'root')

    export_tables(OUTPUT)
    export_mapping(KEYFILE)

    print('Done.')
