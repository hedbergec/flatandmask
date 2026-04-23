# Complex Example Test

This file describes the complex example inputs and how to run tests.

Files:

- `complex1.json` — deeply nested, five records, arrays and nested objects.
- `complex2.json` — ~80% same as `complex1.json`, with one new record, several changed values, and some fields intentionally missing to test resilience.

Run commands (PowerShell):

```powershell
# Process complex1.json
$script = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\flatandmask_gui.ps1'
$in1 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\complex1.json'
$out1 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\out_complex1'
$key1 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\key_complex1.csv'
& $script -InputFile $in1 -OutputFolder $out1 -KeyFile $key1 -SecretKey 's3cr3t' -MaskFields @('root.name','root.email')

# Process complex2.json
$in2 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\complex2.json'
$out2 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\out_complex2'
$key2 = 'y:\Dropbox\Work\Consult\Consult.Katz\ppd\flatandmask\examples\key_complex2.csv'
& $script -InputFile $in2 -OutputFolder $out2 -KeyFile $key2 -SecretKey 's3cr3t' -MaskFields @('root.name','root.email')

# Quick peek at mapping outputs
Import-Csv $key1 | Select-Object -First 10
Import-Csv $key2 | Select-Object -First 10
```

After running, inspect `out_complex1` and `out_complex2` for generated CSVs and the mapping files for masked/original pairs.
