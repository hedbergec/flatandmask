format_status_line <- function(text, width = getOption("width", 100L)) {
  width <- max(40L, as.integer(width) - 1L)
  vapply(as.character(text %||% ""), function(line) {
    if (nchar(line, type = "width") > width) {
      paste0(substr(line, 1L, max(1L, width - 3L)), "...")
    } else {
      sprintf(paste0("%-", width, "s"), line)
    }
  }, character(1), USE.NAMES = FALSE)
}

add_gui_log_line <- function(message) {
  if (is.null(message) || !nzchar(trimws(message))) return(invisible(NULL))
  state <- .state()
  line <- paste(format(Sys.time(), "%H:%M:%S"), message)
  state$gui_log_lines <- c(state$gui_log_lines, line)
  if (length(state$gui_log_lines) > state$gui_log_max_lines) {
    state$gui_log_lines <- tail(state$gui_log_lines, state$gui_log_max_lines)
  }
  callback <- state$log_callback
  .set_state(state)
  if (is.function(callback)) callback(state$gui_log_lines)
  invisible(line)
}

write_status_panel <- function(mode = NULL, phase = NULL, current = NULL, total = NULL,
                               detail = NULL, mask = NULL, force = FALSE) {
  state <- .state()
  if (!isTRUE(state$verbose_logging)) return(invisible(state$status_state))
  if (!is.null(mode)) state$status_state$mode <- as.character(mode)
  if (!is.null(phase)) state$status_state$phase <- as.character(phase)
  if (!is.null(detail)) state$status_state$detail <- as.character(detail)
  if (!is.null(mask)) state$status_state$mask <- as.character(mask)
  if (!is.null(current) || !is.null(total)) {
    parts <- strsplit(state$status_state$progress, " / ", fixed = TRUE)[[1]]
    if (length(parts) < 2L) parts <- c("0", "0")
    current_text <- if (!is.null(current)) as.character(current) else parts[[1]]
    total_text <- if (!is.null(total)) as.character(total) else parts[[2]]
    if (suppressWarnings(!is.na(as.integer(current_text)) && !is.na(as.integer(total_text)) &&
      as.integer(current_text) > as.integer(total_text))) {
      total_text <- current_text
    }
    state$status_state$progress <- paste(current_text, total_text, sep = " / ")
  }

  lines <- c(
    paste("Mode:    ", state$status_state$mode),
    paste("Phase:   ", state$status_state$phase),
    paste("Progress:", state$status_state$progress),
    paste("Detail:  ", state$status_state$detail),
    paste("Mask:    ", state$status_state$mask)
  )
  .set_state(state)
  if (isTRUE(force) || interactive()) message(paste(format_status_line(lines), collapse = "\n"))
  log_line <- sprintf("Mode=%s; Phase=%s; Progress=%s",
                      state$status_state$mode, state$status_state$phase,
                      state$status_state$progress)
  if (nzchar(state$status_state$detail)) log_line <- paste(log_line, state$status_state$detail, sep = "; ")
  if (nzchar(state$status_state$mask)) log_line <- paste(log_line, state$status_state$mask, sep = "; ")
  add_gui_log_line(log_line)
  invisible(state$status_state)
}

write_verbose_log <- function(message) {
  write_status_panel(detail = message)
}

write_mask_log <- function(field, original_value, masked_value) {
  state <- .state()
  if (isTRUE(state$verbose_logging) && !is.null(original_value) && nzchar(as.character(original_value))) {
    original <- as.character(original_value)
    truncated <- if (nchar(original) > 30L) paste0(substr(original, 1L, 27L), "...") else original
    write_status_panel(mask = sprintf("%s: %s -> %s", field, truncated, masked_value))
  }
  invisible(NULL)
}

update_processing_progress <- function(current, total, phase = "Processing", detail = NULL, force = FALSE) {
  progress_detail <- get_job_progress_detail(detail)
  write_status_panel(phase = phase, current = current, total = total, detail = progress_detail, force = force)
  .invoke_progress_callback("mask", current, total, progress_detail)
  invisible(NULL)
}

`%||%` <- function(x, y) if (is.null(x)) y else x
