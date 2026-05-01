### R code from vignette source 'jsoncsvmaskr-usage.Rnw'

###################################################
### code chunk number 1: setup
###################################################
options(width = 76)
library(JsonCSVMaskr)
setwd(system.file("extdata", package = "JsonCSVMaskr"))

snippet <- function(data, rows = 3, cols = 5) {
  data <- as.data.frame(data)
  data[seq_len(min(rows, nrow(data))), seq_len(min(cols, ncol(data))), drop = FALSE]
}


###################################################
### code chunk number 2: csv-fields
###################################################
get_csv_fields("sample.csv")


###################################################
### code chunk number 3: csv-run
###################################################
output_folder <- "~/Documents/MASKED/csv-example"
unlink(output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample.csv",
  output_folder = output_folder,
  secret_key = "your-secret-key",
  mask_fields = c("root.Name", "root.Email")
)
list.files(output_folder)


###################################################
### code chunk number 4: csv-data-snippet
###################################################
csv_data <- read.csv(
  file.path(output_folder, "data.csv"),
  check.names = FALSE
)
snippet(csv_data)


###################################################
### code chunk number 5: csv-key-snippet
###################################################
csv_key <- read.csv(
  file.path(output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(csv_key, rows = 6, cols = 4)


###################################################
### code chunk number 6: json-fields
###################################################
head(get_json_fields("sample.json"), 10)


###################################################
### code chunk number 7: json-run
###################################################
json_output_folder <- "~/Documents/MASKED/json-example"
unlink(json_output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample.json",
  output_folder = json_output_folder,
  secret_key = "your-secret-key",
  mask_fields = c("root.name", "root.email")
)
list.files(json_output_folder)


###################################################
### code chunk number 8: json-snippets
###################################################
json_data <- read.csv(
  file.path(json_output_folder, "data.csv"),
  check.names = FALSE
)
snippet(json_data)
json_key <- read.csv(
  file.path(json_output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(json_key, rows = 4, cols = 4)


###################################################
### code chunk number 9: ndjson-example
###################################################
head(get_json_fields("sample_ndjson.json"), 10)
ndjson_output_folder <- "~/Documents/MASKED/ndjson-example"
unlink(ndjson_output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample_ndjson.json",
  output_folder = ndjson_output_folder,
  secret_key = "your-secret-key",
  mask_fields = c("root.email", "root.name")
)
list.files(ndjson_output_folder)
ndjson_key <- read.csv(
  file.path(ndjson_output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(ndjson_key, rows = 4, cols = 4)


###################################################
### code chunk number 10: envelope-example
###################################################
head(get_json_fields("sample_envelope.json"), 10)
envelope_output_folder <- "~/Documents/MASKED/envelope-example"
unlink(envelope_output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample_envelope.json",
  output_folder = envelope_output_folder,
  secret_key = "your-secret-key",
  mask_fields = c("root.email")
)
list.files(envelope_output_folder)
envelope_key <- read.csv(
  file.path(envelope_output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(envelope_key, rows = 4, cols = 4)


###################################################
### code chunk number 11: header-array-example
###################################################
get_json_fields("sample_header_array.json")
header_output_folder <- "~/Documents/MASKED/header-array-example"
unlink(header_output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample_header_array.json",
  output_folder = header_output_folder,
  secret_key = "your-secret-key",
  mask_fields = c("root.email")
)
list.files(header_output_folder)
header_key <- read.csv(
  file.path(header_output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(header_key, rows = 4, cols = 4)


###################################################
### code chunk number 12: complex-fields
###################################################
head(get_json_fields("sample_complex.json"), 15)


###################################################
### code chunk number 13: complex-run
###################################################
complex_output_folder <- "~/Documents/MASKED/complex-example"
unlink(complex_output_folder, recursive = TRUE, force = TRUE)
datamaskr(
  input_file = "sample_complex.json",
  output_folder = complex_output_folder,
  secret_key = "your-secret-key",
  mask_fields = c(
    "root.org_name",
    "root.owner.email",
    "root.projects.tasks.assignee_email"
  )
)
list.files(complex_output_folder)


###################################################
### code chunk number 14: complex-read-tables
###################################################
orgs <- readr::read_csv(
  file.path(complex_output_folder, "data.csv"),
  show_col_types = FALSE
)
owners <- readr::read_csv(
  file.path(complex_output_folder, "owner.csv"),
  show_col_types = FALSE
)
projects <- readr::read_csv(
  file.path(complex_output_folder, "projects.csv"),
  show_col_types = FALSE
)
tasks <- readr::read_csv(
  file.path(complex_output_folder, "projects_tasks.csv"),
  show_col_types = FALSE
)

list(
  orgs = names(orgs),
  owners = names(owners),
  projects = names(projects),
  tasks = names(tasks)
)


###################################################
### code chunk number 15: complex-join
###################################################
joined <- orgs |>
  dplyr::select(root_id, org_id, org_name) |>
  dplyr::left_join(
    owners |> dplyr::select(root_id, owner_email = email),
    by = "root_id"
  ) |>
  dplyr::left_join(
    projects |> dplyr::select(root_id, projects_id, project_code, project_name),
    by = "root_id"
  ) |>
  dplyr::left_join(
    tasks |> dplyr::select(projects_id, task_id, assignee_email, status),
    by = "projects_id"
  )

snippet(joined, rows = 6, cols = 8)


###################################################
### code chunk number 16: complex-key-snippet
###################################################
complex_key <- read.csv(
  file.path(complex_output_folder, "masking_key.csv"),
  check.names = FALSE
)
snippet(complex_key, rows = 8, cols = 4)


###################################################
### code chunk number 17: replication-snippet
###################################################
replication <- readLines(
  file.path(output_folder, "replicate_masking.R"),
  warn = FALSE
)
cat(
  "First few lines of replicate_masking.R:\n\n",
  paste(head(replication, 5), collapse = "\n"),
  "\n"
)


