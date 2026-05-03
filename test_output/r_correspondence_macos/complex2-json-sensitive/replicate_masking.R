# Replicate a JsonCSVMaskr masking run.
# Open this file in R and run it to repeat the same masking operation.

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile, winslash = '/', mustWork = FALSE), error = function(e) NULL)
script_dir <- if (!is.null(script_path) && nzchar(script_path)) dirname(script_path) else getwd()
if (!requireNamespace('JsonCSVMaskr', quietly = TRUE)) {
  helper <- file.path(script_dir, 'JsonCSVMaskr-replication.R')
  if (file.exists(helper)) source(helper) else stop('Install the JsonCSVMaskr package before running this replication script.', call. = FALSE)
} else {
  library(JsonCSVMaskr)
}

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args) >= 1) args[[1]] else "/Users/hedbergec/Dropbox/Work/Consult/Consult.Katz/ppd/flatandmask/example data/complex2.json"
output_folder <- if (length(args) >= 2) args[[2]] else "/Users/hedbergec/Dropbox/Work/Consult/Consult.Katz/ppd/flatandmask/test_output/r_correspondence_macos/complex2-json-sensitive"
secret_key <- if (length(args) >= 3) args[[3]] else "testkey123"
mask_fields <- c("name", "email", "address.street", "address.city", "contacts.number", 
"contacts.value")

input_file <- normalizePath(input_file, winslash = '/', mustWork = TRUE)
dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
output_folder <- normalizePath(output_folder, winslash = '/', mustWork = FALSE)
key_file <- file.path(output_folder, 'masking_key.csv')
invoke_masking(input_file, output_folder, key_file, secret_key, mask_fields)
message('Replication complete: ', output_folder)
