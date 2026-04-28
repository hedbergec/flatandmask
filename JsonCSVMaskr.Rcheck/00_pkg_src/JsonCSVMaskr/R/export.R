complete_masking_outputs <- function(output_folder, key_file, input_file, secret_key, mask_fields,
                                     skip_replication_script = FALSE) {
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  .invoke_progress_callback("normalize", 100L, 100L, "Normalization complete")
  state <- .state()
  table_names <- ls(state$tables)
  export_total <- max(1L, length(table_names) + 2L)
  export_step <- 0L

  for (table_name in table_names) {
    name <- if (identical(table_name, "root")) "data" else sub("^root_", "", table_name)
    rows <- get(table_name, envir = state$tables, inherits = FALSE)
    data <- convert_rows_for_csv_export(rows)
    path <- file.path(output_folder, paste0(name, ".csv"))
    write_status_panel(phase = "Exporting CSV", detail = sprintf("Writing %s.csv (%d rows)", name, nrow(data)), force = TRUE)
    utils::write.csv(data, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    export_step <- export_step + 1L
    .invoke_progress_callback("export", export_step, export_total, sprintf("Wrote %s.csv", name))
  }

  write_status_panel(phase = "Finalizing", detail = "Writing masking key", force = TRUE)
  export_masking_key(key_file)
  export_step <- export_step + 1L
  .invoke_progress_callback("export", export_step, export_total, "Wrote masking key")

  if (!isTRUE(skip_replication_script)) {
    generate_replication_script(output_folder, input_file, secret_key, mask_fields)
  }
  export_step <- export_step + 1L
  .invoke_progress_callback("export", export_step, export_total, "Wrote replication script")
  sync_table_estimate_with_produced()
  state <- .state()
  write_status_panel(
    phase = "Complete",
    current = state$processed_lines,
    total = state$total_lines,
    detail = sprintf("Tables: %d; unique masked values: %d; fields masked: %d (est ~%d)",
                     length(ls(state$tables)), length(ls(state$mapping)),
                     state$masked_fields_processed, state$estimated_fields_to_mask),
    force = TRUE
  )
  invisible(output_folder)
}

export_masking_key <- function(key_file) {
  state <- .state()
  if (length(state$mapping_rows) > 0L) {
    data <- do.call(rbind, state$mapping_rows)
  } else if (length(ls(state$mapping)) > 0L) {
    data <- do.call(rbind, lapply(ls(state$mapping), function(original) {
      entry <- get(original, envir = state$mapping, inherits = FALSE)
      data.frame(Original = original, Masked = entry$masked, Field = entry$field,
                 stringsAsFactors = FALSE)
    }))
  } else {
    data <- data.frame(Original = character(), Masked = character(),
                       Field = character(), RowIndex = integer())
  }
  dir.create(dirname(key_file), recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(data, key_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  invisible(key_file)
}

get_replication_tool_source_text <- function() {
  source_file <- system.file("JsonCSVMaskr-replication.R", package = "JsonCSVMaskr")
  if (nzchar(source_file) && file.exists(source_file)) {
    return(paste(readLines(source_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  }
  paste(
    "# JsonCSVMaskr replication helper",
    "library(JsonCSVMaskr)",
    sep = "\n"
  )
}

export_replication_tool_source <- function(output_folder) {
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(output_folder, "JsonCSVMaskr-replication.R")
  writeLines(get_replication_tool_source_text(), path, useBytes = TRUE)
  invisible(path)
}

generate_replication_script <- function(output_folder, input_file, secret_key, mask_fields) {
  export_replication_tool_source(output_folder)
  mask_fields_text <- paste(sprintf("%s", deparse(mask_fields)), collapse = "\n")
  content <- c(
    "# Replicate a JsonCSVMaskr masking run.",
    "# Requires the JsonCSVMaskr package to be installed or loaded from this Rpackage directory.",
    "",
    "args <- commandArgs(trailingOnly = TRUE)",
    sprintf("input_file <- if (length(args) >= 1) args[[1]] else %s", deparse(input_file)),
    sprintf("output_folder <- if (length(args) >= 2) args[[2]] else %s", deparse(output_folder)),
    sprintf("secret_key <- if (length(args) >= 3) args[[3]] else %s", deparse(secret_key)),
    paste0("mask_fields <- ", mask_fields_text),
    "",
    "library(JsonCSVMaskr)",
    "key_file <- file.path(output_folder, 'masking_key.csv')",
    "invoke_masking(input_file, output_folder, key_file, secret_key, mask_fields)",
    "message('Replication complete: ', output_folder)"
  )
  path <- file.path(output_folder, "replicate_masking.R")
  writeLines(content, path, useBytes = TRUE)
  invisible(path)
}

convert_to_app_version <- function(version_text) {
  if (is.null(version_text) || !nzchar(trimws(version_text))) return(NULL)
  clean <- sub("^[vV]", "", trimws(version_text))
  match <- regmatches(clean, regexpr("\\d+(\\.\\d+){0,3}", clean))
  if (!length(match) || identical(match, "")) return(NULL)
  package_version(match)
}

get_tool_update_status <- function() {
  list(
    Status = "Unknown",
    Message = "Update checks are not implemented in the R package GUI. Check the repo manually: https://github.com/hedbergec/flatandmask",
    Url = "https://github.com/hedbergec/flatandmask"
  )
}
