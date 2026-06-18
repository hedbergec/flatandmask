invoke_json_records_masking <- function(records, input_file, output_folder, key_file, mode_name,
                                        mask_fields, output_format = "JsonArray") {
  write_status_panel(mode = mode_name, phase = "Preparing", current = 0L, total = length(records),
                     detail = "Detected record collection", mask = "", force = TRUE)
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  state <- .state()
  state$total_lines <- length(records)
  state$processed_lines <- 0L
  state$input_was_json <- TRUE
  .set_state(state)
  set_json_record_job_estimate(records, mask_fields, mode_name)
  write_job_estimate_status(mode_name)

  masked_items <- lapply(records, apply_masking_to_object)
  state <- .state()
  state$masked_data <- masked_items
  state$tables <- new.env(parent = emptyenv())
  state$tables_produced <- 0L
  .set_state(state)
  .invoke_progress_callback("normalize", 1L, 100L, "Generating CSV tables from masked JSON")
  for (item in masked_items) process_masked_object(item, "root", list())
  .invoke_progress_callback("normalize", 100L, 100L, "Normalization complete")

  base <- tools::file_path_sans_ext(basename(input_file))
  if (identical(output_format, "Ndjson")) {
    path <- file.path(output_folder, paste0(base, "_masked.ndjson"))
    lines <- vapply(masked_items, function(item) as.character(jsonlite::toJSON(item, auto_unbox = TRUE, null = "null")), character(1))
    writeLines(lines, path, useBytes = TRUE)
  } else {
    path <- file.path(output_folder, paste0(base, "_masked.json"))
    writeLines(as.character(jsonlite::toJSON(masked_items, auto_unbox = TRUE, pretty = TRUE, null = "null")), path, useBytes = TRUE)
  }
  invisible(path)
}

invoke_header_array_json_masking <- function(json, input_file, output_folder, key_file, mask_fields) {
  invoke_json_records_masking(convert_header_array_rows_to_objects(json), input_file, output_folder,
                              key_file, "Header Array JSON", mask_fields)
}

invoke_socrata_json_masking <- function(json, input_file, output_folder, key_file, mask_fields) {
  write_status_panel(mode = "Socrata JSON", phase = "Preparing", current = 0L, total = 0L,
                     detail = "Detected indexed row-array JSON", mask = "", force = TRUE)
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  columns <- get_socrata_columns(json)
  mask_indexes <- integer()
  mask_paths <- character()
  for (i in seq_along(columns)) {
    name_path <- paste0("root.", columns[[i]]$Name)
    field_path <- paste0("root.", columns[[i]]$FieldName)
    selected <- normalize_field_name(mask_fields)
    if (normalize_field_name(name_path) %in% selected || normalize_field_name(field_path) %in% selected) {
      mask_indexes <- c(mask_indexes, i)
      mask_paths <- c(mask_paths, name_path)
    }
  }
  state <- .state()
  state$total_lines <- length(json$data)
  state$processed_lines <- 0L
  state$tables_produced <- 1L
  state$input_was_json <- TRUE
  state$masked_data <- NULL
  state$original_data <- NULL
  .set_state(state)
  set_job_estimate(length(json$data), length(json$data) * length(mask_indexes), 1L, "Socrata exact column preflight")
  write_job_estimate_status("Socrata JSON")

  rows <- json$data
  csv_rows <- vector("list", length(rows))
  for (row_index in seq_along(rows)) {
    row <- rows[[row_index]]
    for (j in seq_along(mask_indexes)) {
      idx <- mask_indexes[[j]]
      if (idx <= length(row)) row[[idx]] <- mask_if_needed(mask_paths[[j]], row[[idx]], row_index - 1L)
    }
    rows[[row_index]] <- row
    row <- lapply(row, function(value) if (is.null(value) || length(value) == 0L) NA else value)
    names(row) <- vapply(columns, `[[`, character(1), "Name")
    csv_rows[[row_index]] <- as.data.frame(row, stringsAsFactors = FALSE, check.names = FALSE)
    state <- .state()
    state$processed_lines <- row_index
    .set_state(state)
    update_processing_progress(row_index, length(rows), phase = "Masking Socrata JSON", detail = "Writing data.csv and masked JSON")
  }
  json$data <- rows
  base <- tools::file_path_sans_ext(basename(input_file))
  writeLines(as.character(jsonlite::toJSON(json, auto_unbox = TRUE, pretty = TRUE, null = "null")),
             file.path(output_folder, paste0(base, "_masked.json")), useBytes = TRUE)
  write_quoted_csv(do.call(rbind, csv_rows), file.path(output_folder, "data.csv"))
  export_masking_key(key_file)
  .invoke_progress_callback("normalize", 100L, 100L, "Socrata rows are already tabular")
  .invoke_progress_callback("export", 100L, 100L, "Wrote data.csv, masked JSON, and masking key")
  write_status_panel(phase = "Complete", current = length(rows), total = length(rows),
                     detail = "Wrote data.csv, masked JSON, and masking key", force = TRUE)
  invisible(output_folder)
}

invoke_csv_masking_fast <- function(input_file, output_folder, key_file, secret_key, mask_fields) {
  write_status_panel(mode = "CSV", phase = "Loading", current = 0L, total = 0L, detail = "Counting rows", mask = "", force = TRUE)
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  line_count <- length(readLines(input_file, warn = FALSE))
  row_count <- max(0L, line_count - 1L)
  state <- .state()
  state$total_lines <- row_count
  state$processed_lines <- 0L
  state$tables_produced <- 1L
  state$masked_data <- NULL
  state$original_data <- NULL
  state$tables <- new.env(parent = emptyenv())
  .set_state(state)
  set_csv_job_estimate(input_file, mask_fields, row_count)
  write_job_estimate_status("CSV")

  csv <- utils::read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE,
                         fileEncoding = "UTF-8-BOM", colClasses = "character",
                         na.strings = character())
  headers <- names(csv)
  for (i in seq_len(nrow(csv))) {
    for (name in headers) csv[i, name] <- mask_if_needed(paste0("root.", name), csv[i, name], i - 1L)
    state <- .state()
    state$processed_lines <- i
    .set_state(state)
    update_processing_progress(i, nrow(csv), phase = "Masking CSV", detail = "Writing data.csv")
  }
  write_quoted_csv(csv, file.path(output_folder, "data.csv"))
  write_status_panel(phase = "Finalizing", detail = "Writing masking key", force = TRUE)
  .invoke_progress_callback("normalize", 100L, 100L, "CSV normalization not required")
  .invoke_progress_callback("export", 1L, 2L, "Writing masking key")
  export_masking_key(key_file)
  generate_replication_script(output_folder, input_file, secret_key, mask_fields)
  .invoke_progress_callback("export", 2L, 2L, "Wrote replication script")
  sync_table_estimate_with_produced()
  state <- .state()
  write_status_panel(phase = "Complete", current = state$processed_lines, total = state$total_lines,
                     detail = sprintf("Wrote data.csv and masking key; fields masked: %d (est ~%d)",
                                      state$masked_fields_processed, state$estimated_fields_to_mask),
                     force = TRUE)
  invisible(output_folder)
}

datamaskr <- function(input_file, output_folder, key_file = file.path(output_folder, "masking_key.csv"),
                      secret_key, mask_fields, progress_callback = NULL,
                      missing_value_keyword_action = c("mask", "blank"),
                      missing_value_keywords = c("NULL", "NA", "N/A", "NAN", "#N/A", "#NULL!", "NONE", "NIL", "MISSING", "UNKNOWN", "UNSPECIFIED", "UNDEFINED", "NOT APPLICABLE", "NOT AVAILABLE", "NO DATA", "NO VALUE")) {
  missing_value_keyword_action <- match.arg(missing_value_keyword_action)
  state <- .new_state()
  state$selected_fields <- mask_fields
  state$secret_key <- secret_key
  state$missing_value_keyword_action <- missing_value_keyword_action
  state$missing_value_keywords <- missing_value_keywords
  state$progress_callback <- progress_callback
  .set_state(state)
  reset_job_estimate()
  .invoke_progress_callback("load", 0L, 100L, "Starting")
  .invoke_progress_callback("mask", 0L, 100L, "Waiting")
  .invoke_progress_callback("normalize", 0L, 100L, "Waiting")
  .invoke_progress_callback("export", 0L, 100L, "Waiting")

  ext <- tolower(tools::file_ext(input_file))
  if (identical(ext, "json")) {
    write_status_panel(mode = "JSON", phase = "Loading", current = 0L, total = 0L, detail = "Reading input file", mask = "", force = TRUE)
    json <- tryCatch(read_json_file_with_load_progress(input_file), error = function(e) {
      write_status_panel(mode = "Loose JSON", phase = "Parsing", current = 0L, total = 0L,
                         detail = "Trying NDJSON / loose object records", mask = "", force = TRUE)
      records <- read_loose_json_records(input_file)
      invoke_json_records_masking(records, input_file, output_folder, key_file, "Loose JSON", mask_fields, "Ndjson")
      complete_masking_outputs(output_folder, key_file, input_file, secret_key, mask_fields)
      structure(list(), class = "jcm_already_done")
    })
    if (inherits(json, "jcm_already_done")) return(invisible(output_folder))
    state <- .state()
    state$input_was_json <- TRUE
    state$original_data <- json
    .set_state(state)
    if (test_socrata_json(json)) {
      invoke_socrata_json_masking(json, input_file, output_folder, key_file, mask_fields)
      generate_replication_script(output_folder, input_file, secret_key, mask_fields)
      return(invisible(output_folder))
    }
    if (test_header_array_json(json)) {
      invoke_header_array_json_masking(json, input_file, output_folder, key_file, mask_fields)
      complete_masking_outputs(output_folder, key_file, input_file, secret_key, mask_fields)
      return(invisible(output_folder))
    }
    record_collection <- get_json_record_collection_info(json)
    if (!is.null(record_collection)) {
      invoke_json_records_masking(record_collection$records, input_file, output_folder, key_file,
                                  record_collection$format, mask_fields)
      complete_masking_outputs(output_folder, key_file, input_file, secret_key, mask_fields)
      return(invisible(output_folder))
    }
    is_array <- is_list_array(json)
    total <- if (is_array) length(json) else 1L
    write_status_panel(phase = "Loaded JSON", current = 0L, total = total,
                       detail = if (is_array) sprintf("Array with %d elements", total) else "Single object",
                       force = TRUE)
    set_json_object_job_estimate(json, mask_fields, "JSON")
    write_job_estimate_status("JSON")
    masked <- if (is_array) lapply(json, apply_masking_to_object) else list(apply_masking_to_object(json))
    state <- .state()
    state$masked_data <- masked
    state$tables <- new.env(parent = emptyenv())
    state$tables_produced <- 0L
    .set_state(state)
    write_status_panel(phase = "Normalizing", detail = "Generating CSV tables from masked JSON", force = TRUE)
    .invoke_progress_callback("normalize", 1L, 100L, "Generating CSV tables from masked JSON")
    for (item in masked) process_masked_object(item, "root", list())
    .invoke_progress_callback("normalize", 100L, 100L, "Normalization complete")
    dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
    base <- tools::file_path_sans_ext(basename(input_file))
    writeLines(as.character(jsonlite::toJSON(masked, auto_unbox = TRUE, pretty = TRUE, null = "null")),
               file.path(output_folder, paste0(base, "_masked.json")), useBytes = TRUE)
  } else if (identical(ext, "csv")) {
    invoke_csv_masking_fast(input_file, output_folder, key_file, secret_key, mask_fields)
    return(invisible(output_folder))
  } else {
    stop("Unsupported input file extension: .", ext, call. = FALSE)
  }
  complete_masking_outputs(output_folder, key_file, input_file, secret_key, mask_fields)
  invisible(output_folder)
}

invoke_masking <- function(input_file, output_folder, key_file = file.path(output_folder, "masking_key.csv"),
                           secret_key, mask_fields, progress_callback = NULL,
                           missing_value_keyword_action = c("mask", "blank"),
                           missing_value_keywords = c("NULL", "NA", "N/A", "NAN", "#N/A", "#NULL!", "NONE", "NIL", "MISSING", "UNKNOWN", "UNSPECIFIED", "UNDEFINED", "NOT APPLICABLE", "NOT AVAILABLE", "NO DATA", "NO VALUE")) {
  datamaskr(
    input_file = input_file,
    output_folder = output_folder,
    key_file = key_file,
    secret_key = secret_key,
    mask_fields = mask_fields,
    progress_callback = progress_callback,
    missing_value_keyword_action = missing_value_keyword_action,
    missing_value_keywords = missing_value_keywords
  )
}
