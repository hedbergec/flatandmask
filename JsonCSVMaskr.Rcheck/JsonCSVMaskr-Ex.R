pkgname <- "JsonCSVMaskr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('JsonCSVMaskr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("csv_helpers")
### * csv_helpers

flush(stderr()); flush(stdout())

### Name: csv_helpers
### Title: CSV helpers
### Aliases: csv_helpers set_csv_job_estimate get_csv_fields
###   convert_to_csv_line

### ** Examples

input <- tempfile(fileext = ".csv")
writeLines(c("a,b", "1,2"), input)
get_csv_fields(input)




cleanEx()
nameEx("datamaskr")
### * datamaskr

flush(stderr()); flush(stdout())

### Name: datamaskr
### Title: Run a complete masking job
### Aliases: datamaskr invoke_masking

### ** Examples

input <- tempfile(fileext = ".csv")
writeLines(c("name,email", "Alice,alice@example.com"), input)
out <- tempfile()
datamaskr(input, out, secret_key = "demo", mask_fields = "email")
list.files(out)




cleanEx()
nameEx("json_helpers")
### * json_helpers

flush(stderr()); flush(stdout())

### Name: json_helpers
### Title: JSON parsing, discovery, and shape detection helpers
### Aliases: json_helpers read_text_file_with_load_progress
###   read_json_file_with_load_progress count_maskable_fields_in_object
###   add_estimated_table_names_from_object set_json_record_job_estimate
###   add_json_object_array_counts get_json_progress_target
###   set_json_object_job_estimate test_socrata_json get_socrata_columns
###   get_socrata_json_fields get_visible_json_properties
###   get_json_record_collection_info test_header_array_json
###   convert_header_array_rows_to_objects read_loose_json_records
###   get_json_fields

### ** Examples

input <- tempfile(fileext = ".json")
writeLines('{"person":{"email":"a@example.com"}}', input)
get_json_fields(input)




cleanEx()
nameEx("masking_helpers")
### * masking_helpers

flush(stderr()); flush(stdout())

### Name: masking_helpers
### Title: Deterministic masking primitives
### Aliases: masking_helpers get_selected_field_set
###   test_estimate_field_match normalize_field_name should_mask_field
###   get_masked_value add_mapping_row mask_if_needed
###   apply_masking_to_object get_table_name_from_path new_table_row_id
###   process_masked_object convert_rows_for_csv_export

### ** Examples

get_masked_value("alice@example.com", "secret")
normalize_field_name("root.person.email")




cleanEx()
nameEx("shiny_app")
### * shiny_app

flush(stderr()); flush(stdout())

### Name: shiny_app
### Title: Shiny application
### Aliases: shiny_app jsoncsvmaskr_app run_datamaskr run_app

### ** Examples

app <- jsoncsvmaskr_app()
## Not run: run_datamaskr(port = 3847)




### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
