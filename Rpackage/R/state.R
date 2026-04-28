.jcm_env <- new.env(parent = emptyenv())

.new_state <- function() {
  list(
    app_version = "0.1.0",
    app_title = "JsonCSVMaskr",
    repo_url = "https://github.com/hedbergec/flatandmask",
    author_name = "Eric Hedberg",
    author_email = "hedbergec@outlook.com",
    last_input_file = NULL,
    last_output_folder = NULL,
    selected_fields = character(),
    secret_key = "",
    mapping = new.env(parent = emptyenv()),
    mapping_rows = list(),
    tables = new.env(parent = emptyenv()),
    table_id_counters = new.env(parent = emptyenv()),
    original_data = NULL,
    masked_data = NULL,
    input_was_json = FALSE,
    total_lines = 0L,
    processed_lines = 0L,
    progress_record_path = "root",
    progress_record_label = "Rows",
    tables_produced = 0L,
    estimated_fields_to_mask = 0L,
    estimated_tables_to_produce = 0L,
    estimated_work_units = 0L,
    estimate_method = "",
    masked_fields_processed = 0L,
    verbose_logging = TRUE,
    gui_log_max_lines = 100L,
    gui_log_lines = character(),
    status_state = list(
      mode = "Ready",
      phase = "Idle",
      progress = "0 / 0",
      detail = "",
      mask = ""
    ),
    progress_callback = NULL,
    log_callback = NULL
  )
}

.reset_state <- function() {
  .jcm_env$state <- .new_state()
  invisible(.jcm_env$state)
}

.state <- function() {
  if (is.null(.jcm_env$state)) .reset_state()
  .jcm_env$state
}

.set_state <- function(state) {
  .jcm_env$state <- state
  invisible(state)
}

.set_progress_callback <- function(callback = NULL) {
  state <- .state()
  state$progress_callback <- callback
  .set_state(state)
}

.invoke_progress_callback <- function(stage, current, total, message = "") {
  state <- .state()
  if (is.function(state$progress_callback)) {
    state$progress_callback(stage, current, total, message)
  }
  invisible(NULL)
}
