# JsonCSVMaskr

JsonCSVMaskr is an R package translation of the PowerShell `DataMaskingTool.ps1`.
It deterministically masks selected JSON and CSV fields with HMAC-SHA256,
exports a masking key, normalizes nested JSON into CSV tables, and includes a
Shiny GUI.

## Use

```r
library(JsonCSVMaskr)

datamaskr(
  input_file = "input.json",
  output_folder = "masked-output",
  secret_key = "shared secret",
  mask_fields = c("root.person.email", "root.person.name")
)

run_datamaskr()
```

The Shiny interface exposes the same basic workflow as the PowerShell GUI:
select an input file, select fields, enter a secret key, run masking, and watch
load/mask/normalize/export progress with mirrored console feedback.
