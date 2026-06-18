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

is_missing_value_keyword <- function(value, keywords = .state()$missing_value_keywords) {
  if (is.null(value) || length(value) == 0L) return(FALSE)
  value <- trimws(as.character(value[[1L]]))
  if (is.na(value)) return(FALSE)
  if (!nzchar(value)) return(FALSE)
  any(toupper(value) == toupper(trimws(as.character(keywords))))
}

add_missing_value_keyword_hit <- function(hits, field, value) {
  keyword <- toupper(trimws(as.character(value[[1L]])))
  key <- paste(field, keyword, sep = "|")
  if (is.null(hits[[key]])) {
    hits[[key]] <- list(Field = field, Keyword = keyword, Count = 1L)
  } else {
    hits[[key]]$Count <- hits[[key]]$Count + 1L
  }
  hits
}

find_missing_value_keywords_in_object <- function(object, prefix = "root", selected_field_set,
                                                  hits = list(),
                                                  keywords = .state()$missing_value_keywords) {
  if (is.null(object)) return(hits)
  if (is_object_record(object)) {
    for (name in visible_names(object)) {
      hits <- find_missing_value_keywords_in_object(object[[name]], paste(prefix, name, sep = "."),
                                                    selected_field_set, hits, keywords)
    }
    return(hits)
  }
  if (is_list_array(object)) {
    for (item in object) {
      hits <- find_missing_value_keywords_in_object(item, prefix, selected_field_set, hits, keywords)
    }
    return(hits)
  }
  field <- normalize_field_name(prefix)
  if (field %in% selected_field_set && is_missing_value_keyword(object, keywords)) {
    hits <- add_missing_value_keyword_hit(hits, field, object)
  }
  hits
}

find_missing_value_keywords_in_input <- function(input_file, mask_fields,
                                                 keywords = .state()$missing_value_keywords) {
  selected <- get_selected_field_set(mask_fields)
  hits <- list()
  ext <- tolower(tools::file_ext(input_file))
  if (identical(ext, "csv")) {
    csv <- utils::read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE,
                           fileEncoding = "UTF-8-BOM", colClasses = "character",
                           na.strings = character())
    for (name in names(csv)) {
      field <- normalize_field_name(paste0("root.", name))
      if (!(field %in% selected)) next
      for (value in csv[[name]]) {
        if (is_missing_value_keyword(value, keywords)) {
          hits <- add_missing_value_keyword_hit(hits, field, value)
        }
      }
    }
  } else if (identical(ext, "json")) {
    json <- tryCatch(jsonlite::fromJSON(input_file, simplifyVector = FALSE), error = function(e) NULL)
    if (is.null(json)) {
      for (record in read_loose_json_records(input_file)) {
        hits <- find_missing_value_keywords_in_object(record, "root", selected, hits, keywords)
      }
      hits <- unname(hits)
      if (!length(hits)) return(data.frame(Field = character(), Keyword = character(), Count = integer()))
      out <- do.call(rbind, lapply(hits, as.data.frame, stringsAsFactors = FALSE))
      return(out[order(out$Field, out$Keyword), , drop = FALSE])
    }
    if (test_socrata_json(json)) {
      columns <- get_socrata_columns(json)
      for (row in json$data) {
        for (i in seq_along(columns)) {
          field <- normalize_field_name(paste0("root.", columns[[i]]$Name))
          if (field %in% selected && i <= length(row) && is_missing_value_keyword(row[[i]], keywords)) {
            hits <- add_missing_value_keyword_hit(hits, field, row[[i]])
          }
        }
      }
    } else if (test_header_array_json(json)) {
      for (record in convert_header_array_rows_to_objects(json)) {
        hits <- find_missing_value_keywords_in_object(record, "root", selected, hits, keywords)
      }
    } else {
      collection <- get_json_record_collection_info(json)
      if (!is.null(collection)) {
        for (record in collection$records) {
          hits <- find_missing_value_keywords_in_object(record, "root", selected, hits, keywords)
        }
      } else {
        hits <- find_missing_value_keywords_in_object(json, "root", selected, hits, keywords)
      }
    }
  }
  hits <- unname(hits)
  if (!length(hits)) return(data.frame(Field = character(), Keyword = character(), Count = integer()))
  out <- do.call(rbind, lapply(hits, as.data.frame, stringsAsFactors = FALSE))
  out[order(out$Field, out$Keyword), , drop = FALSE]
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
  excel_safe_masked_value(substr(jsonlite::base64_enc(raw_hash), 1L, 12L))
}

excel_safe_masked_value <- function(value) {
  if (is.null(value) || length(value) == 0L) return(value)
  paste0("x", as.character(value))
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
  if (identical(state$missing_value_keyword_action, "blank") &&
      is_missing_value_keyword(str_val, state$missing_value_keywords)) {
    .set_state(state)
    write_mask_log(normalized_field, str_val, "")
    return("")
  }
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
  excel_safe_masked_value(substr(digest::digest(paste(table_name, next_id, sep = "|"), algo = "sha256", serialize = FALSE), 1L, 8L))
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
