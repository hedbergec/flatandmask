# JsonCSVMaskr

JsonCSVMaskr is the R package version of the Flat & Mask data masking tool. It
deterministically masks selected JSON and CSV fields with HMAC-SHA256, exports a
masking key, normalizes nested JSON into related CSV tables, and includes a
Shiny GUI for point-and-click use.

## Install From GitHub

Install R first, then run one of these in R:

```r
install.packages("remotes")
remotes::install_github("hedbergec/flatandmask", subdir = "Rpackage", dependencies = TRUE)
```

If you prefer `devtools`:

```r
install.packages("devtools")
devtools::install_github("hedbergec/flatandmask", subdir = "Rpackage", dependencies = TRUE)
```

On Windows, install Rtools from <https://cran.r-project.org/bin/windows/Rtools/>
if R asks for build tools. The package is pure R, so most users will receive
binary dependencies and will not need a compiler.

## Install From A Local Checkout

From R, with the working directory set to the repository root:

```r
install.packages("Rpackage", repos = NULL, type = "source")
```

From a terminal:

```sh
R CMD INSTALL Rpackage
```

These commands work on Windows, macOS, and Linux as long as R is on `PATH`.

## Launch The GUI

```r
library(JsonCSVMaskr)
run_datamaskr()
```

When the package loads, it prints the same no-warranty, repository, and contact
notice shown in the GUI.

The GUI opens in a browser. The default output folder is `~/Documents/MASKED`,
which maps to the current user's Documents folder on Windows, macOS, and Linux.
The Browse buttons use local filesystem paths so generated replication scripts
remember real input and output paths, not Shiny upload temp files.

GUI workflow:

1. On `Setup`, browse to a JSON or CSV input file.
2. Leave the output folder as `~/Documents/MASKED` or choose another folder.
3. Enter a secret key.
4. Go to `Fields` and select fields to mask.
5. Go to `Run` and click `Run Masking`.
6. Review the status, console log, and output file list.

## Use From R Code

First, explore your data to see available fields:

```r
library(JsonCSVMaskr)

# For JSON files
get_json_fields("your-data.json")

# For CSV files
get_csv_fields("your-data.csv")
```

Then mask selected fields:

```r
# JSON example
datamaskr(
  input_file = "your-data.json",
  output_folder = "~/Documents/MASKED/json-results",
  secret_key = "your-secret-key",
  mask_fields = c("root.name", "root.email")
)

# CSV example
datamaskr(
  input_file = "your-data.csv",
  output_folder = "~/Documents/MASKED/csv-results",
  secret_key = "your-secret-key",
  mask_fields = c("Name", "Email")
)
```

For complex nested JSON, the package creates multiple related CSV files. Use the generated synthetic ID columns (like `root_id`, `projects_id`) to join tables manually.

## Examples with Package Data

The package includes sample files you can use for testing:

```r
# List available fields in sample data
get_json_fields(system.file("extdata", "sample.json", package = "JsonCSVMaskr"))
get_csv_fields(system.file("extdata", "sample.csv", package = "JsonCSVMaskr"))

# Run masking on sample data
datamaskr(
  input_file = system.file("extdata", "sample.json", package = "JsonCSVMaskr"),
  output_folder = "~/Documents/MASKED/sample-results",
  secret_key = "sample-key",
  mask_fields = c("root.name", "root.email")
)
```

`invoke_masking()` is also available as a PowerShell-style compatibility alias:

```r
invoke_masking(
  input_file = "your-data.csv",
  output_folder = "~/Documents/MASKED/invoke-results",
  secret_key = "your-secret-key",
  mask_fields = c("Name")
)
```

## Outputs

Each run writes output files to the selected folder:

- `data.csv` for flat CSV output or the root JSON table.
- Additional CSV tables for nested JSON arrays/objects.
- `<input>_masked.json` or `<input>_masked.ndjson` for JSON inputs.
- `masking_key.csv`, mapping original values to masked values.
- `replicate_masking.R`, a runnable R script with the original paths, secret
  key, and selected fields.
- `JsonCSVMaskr-replication.R`, a small helper copied beside the replication
  script.

Open `replicate_masking.R` in R and run it to repeat the same masking job. You
can also run it from a terminal:

```sh
Rscript path/to/replicate_masking.R
```

## Cross-Platform Notes

- Windows paths such as `C:/Users/Alice/Documents/data.csv` are supported.
- macOS and Linux paths such as `/Users/alice/data.csv` or `/home/alice/data.csv`
  are supported.
- The GUI Browse dialog exposes Home, Documents, Temp, and platform roots. On
  Windows it also exposes available drive letters.
- If you deploy through Shiny Server or another remote host, file browsing is on
  the server's filesystem. For desktop use, run `run_datamaskr()` locally.

## Vignette

The package includes a LaTeX/Sweave vignette rendered with the bundled sample
JSON data:

```r
vignette("jsoncsvmaskr-usage", package = "JsonCSVMaskr")
```

Repository files:

- `vignettes/jsoncsvmaskr-usage.Rnw` - LaTeX/Sweave source.
- `inst/doc/jsoncsvmaskr-usage.pdf` - Rendered PDF.
- `inst/extdata/sample.json` - Packaged copy of the sample data used by the
  vignette.
