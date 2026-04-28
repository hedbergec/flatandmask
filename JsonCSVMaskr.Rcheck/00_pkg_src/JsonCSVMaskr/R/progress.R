reset_job_estimate <- function() {
  state <- .state()
  state$estimated_fields_to_mask <- 0L
  state$estimated_tables_to_produce <- 0L
  state$estimated_work_units <- 0L
  state$estimate_method <- ""
  state$masked_fields_processed <- 0L
  state$progress_record_path <- "root"
  state$progress_record_label <- "Rows"
  .set_state(state)
}

set_job_estimate <- function(rows, fields, tables, method) {
  state <- .state()
  state$total_lines <- max(0L, as.integer(rows))
  state$estimated_fields_to_mask <- max(0L, as.integer(fields))
  state$estimated_tables_to_produce <- max(0L, as.integer(tables))
  state$estimated_work_units <- state$total_lines + state$estimated_fields_to_mask + state$estimated_tables_to_produce
  state$estimate_method <- as.character(method %||% "")
  .set_state(state)
}

sync_table_estimate_with_produced <- function() {
  state <- .state()
  if (state$estimated_tables_to_produce <= 0L && length(ls(state$tables)) > 0L) {
    state$estimated_tables_to_produce <- length(ls(state$tables))
    state$estimated_work_units <- state$total_lines + state$estimated_fields_to_mask + state$estimated_tables_to_produce
    .set_state(state)
  }
  invisible(NULL)
}

get_job_progress_detail <- function(detail = NULL) {
  state <- .state()
  parts <- character()
  if (!is.null(detail) && nzchar(detail)) parts <- c(parts, detail)
  if (state$estimated_fields_to_mask > 0L) {
    parts <- c(parts, sprintf("fields %d/~%d", state$masked_fields_processed, state$estimated_fields_to_mask))
  }
  if (state$estimated_tables_to_produce > 0L) {
    parts <- c(parts, sprintf("tables %d/~%d", state$tables_produced, state$estimated_tables_to_produce))
  }
  if (nzchar(state$estimate_method)) parts <- c(parts, state$estimate_method)
  paste(parts, collapse = "; ")
}

write_job_estimate_status <- function(mode = NULL) {
  state <- .state()
  detail <- sprintf("%s %d; fields ~%d; tables ~%d",
                    tolower(state$progress_record_label), state$total_lines,
                    state$estimated_fields_to_mask, state$estimated_tables_to_produce)
  if (state$estimated_work_units > 0L) {
    detail <- paste0(detail, "; work units ~", state$estimated_work_units)
  }
  if (nzchar(state$estimate_method)) detail <- paste(detail, state$estimate_method, sep = "; ")
  write_status_panel(mode = mode, phase = "Estimated", current = 0L, total = state$total_lines,
                     detail = detail, force = TRUE)
  .invoke_progress_callback("load", 100L, 100L, detail)
  invisible(NULL)
}

set_progress_record_target <- function(path = "root", label = "Rows") {
  state <- .state()
  state$progress_record_path <- if (!nzchar(trimws(path %||% ""))) "root" else path
  state$progress_record_label <- if (!nzchar(trimws(label %||% ""))) "Rows" else label
  .set_state(state)
}
