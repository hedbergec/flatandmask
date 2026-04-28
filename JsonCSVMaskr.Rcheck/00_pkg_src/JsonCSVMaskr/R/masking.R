get_selected_field_set <- function(mask_fields) {
  unique(normalize_field_name(mask_fields[!is.na(mask_fields) & nzchar(trimws(mask_fields))]))
}

test_estimate_field_match <- function(field_name, selected_field_set) {
  normalize_field_name(field_name) %in% selected_field_set
}

normalize_field_name <- function(field_path) {
  field_path <- as.character(field_path)
  sub("^root\\.", "", field_path)
}

should_mask_field <- function(field_path) {
  state <- .state()
  normalize_field_name(field_path) %in% normalize_field_name(state$selected_fields)
}

get_masked_value <- function(value, key) {
  if (is.null(value) || length(value) == 0L) return("")
  if (length(value) > 1L) value <- value[[1L]]
  if (is.na(value) || identical(value, "")) return("")
  raw_hash <- digest::hmac(key = enc2utf8(as.character(key)),
                           object = enc2utf8(as.character(value)),
                           algo = "sha256",
                           serialize = FALSE,
                           raw = TRUE)
  substr(jsonlite::base64_enc(raw_hash), 1L, 12L)
}

add_mapping_row <- function(original, masked, field, row_index = NULL) {
  state <- .state()
  row <- data.frame(
    Original = as.character(original),
    Masked = as.character(masked),
    Field = as.character(field),
    RowIndex = if (is.null(row_index)) NA_integer_ else as.integer(row_index),
    stringsAsFactors = FALSE
  )
  state$mapping_rows[[length(state$mapping_rows) + 1L]] <- row
  .set_state(state)
  invisible(row)
}

mask_if_needed <- function(field_name, value, row_index = NULL) {
  if (!should_mask_field(field_name)) return(value)
  state <- .state()
  state$masked_fields_processed <- state$masked_fields_processed + 1L
  if (!is.null(value) && length(value) > 1L) value <- value[[1L]]
  str_val <- if (is.null(value) || length(value) == 0L || is.na(value)) "" else as.character(value)
  normalized_field <- normalize_field_name(field_name)
  key <- paste0("value:", str_val)
  if (!exists(key, envir = state$mapping, inherits = FALSE)) {
    masked <- get_masked_value(str_val, state$secret_key)
    assign(key, list(masked = masked, field = normalized_field), envir = state$mapping)
    .set_state(state)
    write_mask_log(normalized_field, str_val, masked)
    state <- .state()
  }
  entry <- get(key, envir = state$mapping, inherits = FALSE)
  .set_state(state)
  add_mapping_row(str_val, entry$masked, normalized_field, row_index)
  entry$masked
}

apply_masking_to_object <- function(object, prefix = "root") {
  state <- .state()
  if (is_object_record(object)) {
    if (identical(prefix, state$progress_record_path)) {
      state$processed_lines <- state$processed_lines + 1L
      current <- state$processed_lines
      total <- state$total_lines
      label <- state$progress_record_label
      .set_state(state)
      update_processing_progress(current, total, phase = "Masking JSON",
                                 detail = sprintf("%s %d of %d", label, current, total))
    }
    out <- list()
    for (name in names(object)) {
      value <- object[[name]]
      field_path <- paste(prefix, name, sep = ".")
      if (is_object_record(value)) {
        out[[name]] <- apply_masking_to_object(value, field_path)
      } else if (is_list_array(value)) {
        out[[name]] <- lapply(value, function(item) {
          if (is_object_record(item)) apply_masking_to_object(item, field_path) else mask_if_needed(field_path, item)
        })
      } else {
        out[[name]] <- mask_if_needed(field_path, value)
      }
    }
    out
  } else if (is_list_array(object)) {
    lapply(object, apply_masking_to_object, prefix = prefix)
  } else {
    mask_if_needed(prefix, object)
  }
}

get_table_name_from_path <- function(path) {
  parts <- strsplit(path, "_", fixed = TRUE)[[1]]
  tail(parts, 1L)
}

new_table_row_id <- function(table_name) {
  state <- .state()
  if (!exists(table_name, envir = state$table_id_counters, inherits = FALSE)) {
    assign(table_name, 0L, envir = state$table_id_counters)
  }
  next_id <- get(table_name, envir = state$table_id_counters, inherits = FALSE) + 1L
  assign(table_name, next_id, envir = state$table_id_counters)
  .set_state(state)
  substr(digest::digest(paste(table_name, next_id, sep = "|"), algo = "sha256", serialize = FALSE), 1L, 8L)
}

process_masked_object <- function(object, table_name = "root", id_map = list()) {
  if (is.null(object) || !is_object_record(object)) return(invisible(NULL))
  table_suffix <- get_table_name_from_path(table_name)
  current_id_key <- paste0(table_suffix, "_id")
  current_id <- new_table_row_id(table_name)
  write_verbose_log(sprintf("Processing table: %s (ID: %s)", table_name, current_id))

  row <- id_map[sort(names(id_map))]
  row[[current_id_key]] <- current_id

  for (name in names(object)) {
    value <- object[[name]]
    if (is_object_record(value)) {
      new_id_map <- id_map
      new_id_map[[current_id_key]] <- current_id
      process_masked_object(value, paste(table_name, name, sep = "_"), new_id_map)
    } else if (is_list_array(value)) {
      item_count <- 0L
      for (item in value) {
        if (is_object_record(item)) {
          item_count <- item_count + 1L
          new_id_map <- id_map
          new_id_map[[current_id_key]] <- current_id
          process_masked_object(item, paste(table_name, name, sep = "_"), new_id_map)
        }
      }
      if (item_count > 0L) write_verbose_log(sprintf("  Found %d nested objects in field: %s", item_count, name))
    } else {
      row[[name]] <- value
    }
  }

  if (length(row) > 0L) {
    state <- .state()
    if (!exists(table_name, envir = state$tables, inherits = FALSE)) {
      assign(table_name, list(), envir = state$tables)
      state$tables_produced <- state$tables_produced + 1L
      .set_state(state)
      write_verbose_log(sprintf("  Created new table: %s with %d fields", table_name, length(row)))
      state <- .state()
    }
    rows <- get(table_name, envir = state$tables, inherits = FALSE)
    rows[[length(rows) + 1L]] <- row
    assign(table_name, rows, envir = state$tables)
    .set_state(state)
  }
  invisible(NULL)
}

convert_rows_for_csv_export <- function(rows) {
  if (length(rows) == 0L) return(data.frame())
  cols <- sort(unique(unlist(lapply(rows, names), use.names = FALSE)))
  normalized <- lapply(rows, function(row) {
    values <- lapply(cols, function(col) if (col %in% names(row)) row[[col]] else NA)
    names(values) <- cols
    as.data.frame(values, stringsAsFactors = FALSE, check.names = FALSE)
  })
  do.call(rbind, normalized)
}
