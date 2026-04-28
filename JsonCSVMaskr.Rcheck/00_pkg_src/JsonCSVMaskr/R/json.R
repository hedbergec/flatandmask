is_object_record <- function(x) {
  is.list(x) && !is.data.frame(x) && !is.null(names(x)) && length(names(x)) > 0L
}

is_list_array <- function(x) {
  is.list(x) && !is.data.frame(x) && (is.null(names(x)) || all(names(x) == ""))
}

visible_names <- function(object) {
  names(object)[!startsWith(names(object), "PS") & names(object) != "SyncRoot"]
}

read_text_file_with_load_progress <- function(path, start_percent = 0L, end_percent = 70L) {
  .invoke_progress_callback("load", start_percent, 100L, "Reading input file")
  text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  .invoke_progress_callback("load", end_percent, 100L, "Reading input file")
  text
}

read_json_file_with_load_progress <- function(path) {
  write_status_panel(phase = "Loading", current = 0L, total = 100L, detail = "Reading input file", force = TRUE)
  raw_json <- read_text_file_with_load_progress(path, 0L, 70L)
  if (!nzchar(trimws(raw_json))) stop("Input file is empty or could not be read: ", path, call. = FALSE)
  write_status_panel(phase = "Parsing JSON", current = 70L, total = 100L, detail = "Converting JSON text", force = TRUE)
  .invoke_progress_callback("load", 80L, 100L, "Converting JSON text")
  parsed <- jsonlite::fromJSON(raw_json, simplifyVector = FALSE)
  .invoke_progress_callback("load", 90L, 100L, "JSON parsed")
  parsed
}

count_maskable_fields_in_object <- function(object, prefix = "root", selected_field_set) {
  if (is.null(object)) return(as.integer(test_estimate_field_match(prefix, selected_field_set)))
  if (is_object_record(object)) {
    return(sum(vapply(visible_names(object), function(name) {
      count_maskable_fields_in_object(object[[name]], paste(prefix, name, sep = "."), selected_field_set)
    }, integer(1))))
  }
  if (is_list_array(object)) {
    return(sum(vapply(object, count_maskable_fields_in_object, integer(1),
                      prefix = prefix, selected_field_set = selected_field_set)))
  }
  as.integer(test_estimate_field_match(prefix, selected_field_set))
}

add_estimated_table_names_from_object <- function(object, table_name = "root", table_names = new.env(parent = emptyenv())) {
  if (is.null(object) || !is_object_record(object)) return(table_names)
  assign(table_name, TRUE, envir = table_names)
  for (name in visible_names(object)) {
    value <- object[[name]]
    if (is_object_record(value)) {
      add_estimated_table_names_from_object(value, paste(table_name, name, sep = "_"), table_names)
    } else if (is_list_array(value)) {
      for (item in value) if (is_object_record(item)) {
        add_estimated_table_names_from_object(item, paste(table_name, name, sep = "_"), table_names)
      }
    }
  }
  table_names
}

set_json_record_job_estimate <- function(records, mask_fields, mode_name) {
  rows <- length(records)
  selected_field_set <- get_selected_field_set(mask_fields)
  sample_size <- if (rows <= 1000L) rows else min(rows, max(1000L, ceiling(rows * 0.10)))
  field_count <- 0L
  table_names <- new.env(parent = emptyenv())
  if (sample_size > 0L) {
    for (i in seq_len(sample_size)) {
      field_count <- field_count + count_maskable_fields_in_object(records[[i]], "root", selected_field_set)
      add_estimated_table_names_from_object(records[[i]], "root", table_names)
    }
  }
  estimated_fields <- if (sample_size > 0L && sample_size < rows) ceiling((field_count / sample_size) * rows) else field_count
  method <- if (sample_size < rows) sprintf("%s estimate from %d/%d records", mode_name, sample_size, rows) else paste(mode_name, "exact preflight")
  set_job_estimate(rows, estimated_fields, length(ls(table_names)), method)
  set_progress_record_target("root", "Records")
}

add_json_object_array_counts <- function(object, prefix = "root", counts = new.env(parent = emptyenv())) {
  if (is.null(object)) return(counts)
  if (is_object_record(object)) {
    for (name in visible_names(object)) add_json_object_array_counts(object[[name]], paste(prefix, name, sep = "."), counts)
  } else if (is_list_array(object)) {
    for (item in object) {
      if (is_object_record(item)) {
        current <- if (exists(prefix, envir = counts, inherits = FALSE)) get(prefix, counts) else 0L
        assign(prefix, current + 1L, envir = counts)
        add_json_object_array_counts(item, prefix, counts)
      }
    }
  }
  counts
}

get_json_progress_target <- function(json, mask_fields) {
  counts <- add_json_object_array_counts(json)
  keys <- ls(counts)
  if (length(keys) == 0L) return(list(path = "root", count = 1L, label = "Objects"))
  selected <- get_selected_field_set(mask_fields)
  candidates <- lapply(keys, function(path) {
    normalized <- normalize_field_name(path)
    matches <- any(selected == normalized | startsWith(selected, paste0(normalized, ".")))
    list(path = path, count = as.integer(get(path, counts)), matches = matches)
  })
  matching <- Filter(function(x) isTRUE(x$matches), candidates)
  target <- if (length(matching)) matching[[which.max(vapply(matching, `[[`, integer(1), "count"))]]
            else candidates[[which.max(vapply(candidates, `[[`, integer(1), "count"))]]
  list(path = target$path, count = max(1L, target$count),
       label = tail(strsplit(target$path, ".", fixed = TRUE)[[1]], 1L))
}

set_json_object_job_estimate <- function(json, mask_fields, mode_name) {
  selected_field_set <- get_selected_field_set(mask_fields)
  field_count <- count_maskable_fields_in_object(json, "root", selected_field_set)
  table_names <- add_estimated_table_names_from_object(json)
  target <- get_json_progress_target(json, mask_fields)
  set_job_estimate(target$count, field_count, length(ls(table_names)),
                   sprintf("%s exact preflight; progress by %s", mode_name, target$path))
  set_progress_record_target(target$path, target$label)
}

test_socrata_json <- function(json) {
  is_object_record(json) && is_object_record(json$meta) && is_object_record(json$meta$view) &&
    is.list(json$meta$view$columns) && is.list(json$data)
}

get_socrata_columns <- function(json) {
  columns <- json$meta$view$columns
  out <- lapply(columns, function(column) {
    name <- column$name %||% NULL
    if (is.null(name) || !nzchar(trimws(name))) return(NULL)
    list(Name = as.character(name), FieldName = as.character(column$fieldName %||% name))
  })
  Filter(Negate(is.null), out)
}

get_socrata_json_fields <- function(file_path) {
  json <- tryCatch(jsonlite::fromJSON(file_path, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(json) || !test_socrata_json(json)) return(NULL)
  sort(unique(paste0("root.", vapply(get_socrata_columns(json), `[[`, character(1), "Name"))))
}

get_visible_json_properties <- function(object) {
  object[visible_names(object)]
}

get_json_record_collection_info <- function(json) {
  if (!is_object_record(json)) return(NULL)
  if (identical(json$type, "FeatureCollection") && is.list(json$features)) {
    return(list(format = "GeoJSON", path = "features", records = json$features))
  }
  for (property_name in c("data", "results", "items", "records")) {
    value <- json[[property_name]]
    if (is.list(value) && length(value) > 0L && is_object_record(value[[1L]])) {
      return(list(format = "Envelope JSON", path = property_name, records = value))
    }
  }
  NULL
}

test_header_array_json <- function(json) {
  if (!is_list_array(json) || length(json) < 2L) return(FALSE)
  header <- json[[1L]]
  if (is_object_record(header) || (!is.null(names(header)) && any(nzchar(names(header))))) return(FALSE)
  if (!is.atomic(header) && !is.list(header)) return(FALSE)
  header <- unlist(header, use.names = FALSE)
  length(header) > 0L && all(nzchar(trimws(as.character(header)))) &&
    !is_object_record(json[[2L]]) && (is.atomic(json[[2L]]) || is.list(json[[2L]]))
}

convert_header_array_rows_to_objects <- function(rows) {
  row_array <- rows
  if (length(row_array) < 2L) return(list())
  headers <- as.character(unlist(row_array[[1L]], use.names = FALSE))
  lapply(row_array[-1L], function(row) {
    values <- as.list(unlist(row, recursive = FALSE, use.names = FALSE))
    out <- vector("list", length(headers))
    names(out) <- headers
    for (i in seq_along(headers)) out[[i]] <- if (i <= length(values)) values[[i]] else NULL
    out
  })
}

read_loose_json_records <- function(file_path) {
  lines <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
  non_empty <- lines[nzchar(trimws(lines))]
  if (!length(non_empty)) return(list())
  records <- list()
  line_mode <- TRUE
  for (line in non_empty) {
    trimmed <- sub(",\\s*$", "", trimws(line))
    parsed <- tryCatch(jsonlite::fromJSON(trimmed, simplifyVector = FALSE), error = function(e) NULL)
    if (is.null(parsed)) {
      line_mode <- FALSE
      break
    }
    records[[length(records) + 1L]] <- parsed
  }
  if (line_mode && length(records)) return(records)
  raw <- paste(lines, collapse = "\n")
  for (candidate in c(paste0("[", raw, "]"), paste0("[", sub(",\\s*$", "", trimws(raw)), "]"))) {
    parsed <- tryCatch(jsonlite::fromJSON(candidate, simplifyVector = FALSE), error = function(e) NULL)
    if (!is.null(parsed)) return(if (is_list_array(parsed)) parsed else list(parsed))
  }
  split_records <- split_concatenated_json_objects(raw)
  if (length(split_records)) return(split_records)
  stop("JSON is not a supported loose record format. Expected NDJSON, comma-separated objects, or concatenated JSON objects.", call. = FALSE)
}

split_concatenated_json_objects <- function(raw) {
  chars <- strsplit(raw, "", fixed = TRUE)[[1]]
  depth <- 0L; start <- NA_integer_; in_string <- FALSE; escaped <- FALSE
  out <- list()
  for (i in seq_along(chars)) {
    ch <- chars[[i]]
    if (in_string) {
      if (escaped) escaped <- FALSE
      else if (identical(ch, "\\")) escaped <- TRUE
      else if (identical(ch, "\"")) in_string <- FALSE
      next
    }
    if (identical(ch, "\"")) {
      in_string <- TRUE
    } else if (identical(ch, "{")) {
      if (depth == 0L) start <- i
      depth <- depth + 1L
    } else if (identical(ch, "}")) {
      depth <- depth - 1L
      if (depth == 0L && !is.na(start)) {
        text <- paste(chars[start:i], collapse = "")
        out[[length(out) + 1L]] <- jsonlite::fromJSON(text, simplifyVector = FALSE)
        start <- NA_integer_
      }
    }
  }
  out
}

get_json_fields <- function(file_path) {
  socrata <- get_socrata_json_fields(file_path)
  if (!is.null(socrata)) return(socrata)
  json <- tryCatch(jsonlite::fromJSON(file_path, simplifyVector = FALSE),
                   error = function(e) read_loose_json_records(file_path))
  if (test_header_array_json(json)) return(sort(unique(paste0("root.", as.character(unlist(json[[1L]], use.names = FALSE))))))
  record_collection <- get_json_record_collection_info(json)
  target <- if (!is.null(record_collection) && length(record_collection$records)) record_collection$records[[1L]]
            else if (is_list_array(json) && length(json)) json[[1L]] else json
  fields <- character()
  build_tree <- function(object, prefix = "root") {
    if (is_object_record(object)) {
      for (name in visible_names(object)) {
        path <- paste(prefix, name, sep = ".")
        fields <<- c(fields, path)
        build_tree(object[[name]], path)
      }
    } else if (is_list_array(object) && length(object)) {
      build_tree(object[[1L]], prefix)
    }
  }
  build_tree(target)
  sort(unique(fields))
}
