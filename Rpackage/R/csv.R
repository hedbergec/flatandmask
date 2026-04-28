set_csv_job_estimate <- function(input_file, mask_fields, row_count) {
  selected <- get_selected_field_set(mask_fields)
  sample_limit <- if (row_count <= 1000L) row_count else min(row_count, max(1000L, ceiling(row_count * 0.10)))
  sampled <- 0L
  field_count <- 0L
  selected_columns <- 0L
  if (sample_limit > 0L) {
    sample <- utils::read.csv(input_file, nrows = sample_limit, stringsAsFactors = FALSE,
                              check.names = FALSE, fileEncoding = "UTF-8-BOM")
    sampled <- nrow(sample)
    selected_columns <- sum(paste0("root.", names(sample)) |> normalize_field_name() %in% selected)
    for (name in names(sample)) {
      if (test_estimate_field_match(paste0("root.", name), selected)) field_count <- field_count + sampled
    }
  }
  if (sampled == 0L) selected_columns <- length(mask_fields)
  estimated <- if (sampled > 0L && sampled < row_count) ceiling((field_count / sampled) * row_count)
               else if (sampled > 0L) field_count else row_count * selected_columns
  method <- if (sampled < row_count) sprintf("CSV estimate from %d/%d rows", sampled, row_count) else "CSV exact preflight"
  set_job_estimate(row_count, estimated, 1L, method)
}

get_csv_fields <- function(file_path) {
  names(utils::read.csv(file_path, nrows = 1L, stringsAsFactors = FALSE,
                        check.names = FALSE, fileEncoding = "UTF-8-BOM"))
}

convert_to_csv_line <- function(values) {
  escaped <- vapply(values, function(value) {
    if (is.null(value) || is.na(value)) "\"\"" else paste0("\"", gsub("\"", "\"\"", as.character(value), fixed = TRUE), "\"")
  }, character(1))
  paste(escaped, collapse = ",")
}
