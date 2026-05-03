jsoncsvmaskr_app <- function() {
  default_output_dir <- ""
  has_shiny_files <- requireNamespace("shinyFiles", quietly = TRUE)
  icon_src <- get_shiny_icon_src()

  ui <- shiny::fluidPage(
    shiny::tags$head(
      if (!is.null(icon_src)) shiny::tags$link(rel = "icon", type = "image/svg+xml", href = icon_src),
      shiny::tags$style(
        ".jcm-title { display: flex; align-items: center; gap: 10px; margin-top: 12px; }",
        ".jcm-title img { width: 42px; height: 42px; flex: 0 0 auto; }",
        ".jcm-title h3 { margin: 0; }",
        ".jcm-log { height: 170px; overflow: auto; white-space: pre; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; border: 1px solid #cbd5e1; padding: 8px; background: white; }",
        ".jcm-field-list { max-height: 430px; overflow: auto; border: 1px solid #cbd5e1; padding: 8px; background: white; }",
        ".jcm-status { border: 1px solid #cbd5e1; padding: 8px; min-height: 38px; background: #f8fafc; }",
        ".jcm-selected { white-space: pre-wrap; border: 1px solid #cbd5e1; padding: 8px; min-height: 70px; background: #f8fafc; }",
        ".jcm-actions { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 12px; }",
        ".jcm-muted { color: #64748b; font-size: 12px; }",
        ".jcm-step-message { color: #9a3412; font-size: 12px; margin: 4px 0 10px; }",
        ".jcm-disclaimer { border: 1px solid #f59e0b; background: #fffbeb; padding: 10px; margin: 8px 0 14px; }"
      ),
      shiny::tags$script(
        shiny::HTML(
          "Shiny.addCustomMessageHandler('jcm-status-log', function(x) {
            var log = document.getElementById('jcm-live-log');
            if (log && x.clearLog) log.textContent = '';
            if (x.status) {
              var status = document.getElementById('jcm-live-status');
              if (status) status.textContent = x.status;
            }
            if (log && x.line) {
              log.textContent = (log.textContent ? log.textContent + '\\n' : '') + x.line;
              var lines = log.textContent.split('\\n');
              if (lines.length > 100) log.textContent = lines.slice(lines.length - 100).join('\\n');
              log.scrollTop = log.scrollHeight;
            }
          });"
        )
      )
    ),
    shiny::tags$div(
      class = "jcm-title",
      if (!is.null(icon_src)) shiny::tags$img(src = icon_src, alt = "Data Masking Tool icon"),
      shiny::h3("Data Masking Tool")
    ),
    shiny::tags$div(class = "jcm-disclaimer", jsoncsvmaskr_disclaimer_message()),
    shiny::tabsetPanel(
      id = "main_tabs",
      shiny::tabPanel(
        "Setup",
        shiny::br(),
        shiny::fluidRow(
          shiny::column(
            width = 7,
            shiny::textInput("input_path", "Input File (JSON/CSV)", value = ""),
            if (has_shiny_files) {
              shinyFiles::shinyFilesButton("browse_input_file", "Browse...", "Select input file", multiple = FALSE)
            } else {
              shiny::fileInput("input_file", NULL, accept = c(".json", ".csv"))
            },
            shiny::uiOutput("input_step_message"),
            shiny::textInput("output_folder", "Output Folder", value = ""),
            if (has_shiny_files) {
              shinyFiles::shinyDirButton("browse_output_folder", "Browse...", "Select output folder")
            } else {
              shiny::tags$p(
                class = "jcm-muted",
                "Install the shinyFiles R package to browse for folders; typed paths still work."
              )
            },
            shiny::uiOutput("output_step_message"),
            shiny::passwordInput("secret_key", "Secret Key"),
            shiny::uiOutput("key_step_message"),
            shiny::tags$div(
              class = "jcm-actions",
              shiny::actionButton("go_fields", "Select Fields to Mask"),
              shiny::actionButton("reset", "Reset")
            ),
            shiny::uiOutput("fields_button_step_message")
          ),
          shiny::column(
            width = 5,
            shiny::h4("Selected Fields"),
            shiny::tags$div(class = "jcm-selected", shiny::textOutput("selected_fields_text")),
            shiny::h4("Status"),
            shiny::tags$div(class = "jcm-status", shiny::textOutput("setup_status"))
          )
        )
      ),
      shiny::tabPanel(
        "Fields",
        shiny::br(),
        shiny::fluidRow(
          shiny::column(
            width = 8,
            shiny::uiOutput("fields_ui")
          ),
          shiny::column(
            width = 4,
            shiny::h4("Selection"),
            shiny::tags$div(class = "jcm-selected", shiny::textOutput("selected_fields_text_fields")),
            shiny::tags$div(
              class = "jcm-actions",
              shiny::actionButton("select_all_fields", "Select All"),
              shiny::actionButton("clear_fields", "Clear"),
              shiny::actionButton("go_run", "Run Tab")
            ),
            shiny::uiOutput("run_tab_step_message")
          )
        )
      ),
      shiny::tabPanel(
        "Run",
        shiny::br(),
        shiny::fluidRow(
          shiny::column(
            width = 6,
            shiny::tags$div(
              class = "jcm-actions",
              shiny::actionButton("run", "Run Masking"),
              shiny::actionButton("reset_run", "Reset")
            ),
            shiny::uiOutput("run_step_message"),
            shiny::h4("Status"),
            shiny::tags$div(id = "jcm-live-status", class = "jcm-status", "Ready")
          ),
          shiny::column(
            width = 6,
            shiny::h4("Console"),
            shiny::tags$div(id = "jcm-live-log", class = "jcm-log", "")
          )
        )
      ),
      shiny::tabPanel(
        "About",
        shiny::br(),
        shiny::tags$div(class = "jcm-disclaimer", jsoncsvmaskr_disclaimer_message()),
        shiny::tags$a("Git repository", href = jsoncsvmaskr_repo_url(), target = "_blank")
      )
    )
  )

  server <- function(input, output, session) {
    log_lines <- shiny::reactiveVal(character())
    selected_fields <- shiny::reactiveVal(character())
    output_dir <- shiny::reactiveVal("")
    input_path <- shiny::reactiveVal("")
    available_fields <- shiny::reactiveVal(character())
    asked_matching_fields <- shiny::reactiveVal(character())
    pending_matching_fields <- shiny::reactiveVal(character())
    suppress_matching_prompt <- shiny::reactiveVal(FALSE)
    status_text <- shiny::reactiveVal("Ready")
    is_running <- shiny::reactiveVal(FALSE)

    if (has_shiny_files) {
      volumes <- get_shiny_file_roots()
      default_browser_root <- get_default_shiny_root_name(volumes)
      shinyFiles::shinyFileChoose(
        input,
        "browse_input_file",
        roots = volumes,
        session = session,
        filetypes = c("json", "csv")
      )
      observeEvent(input$browse_input_file, {
        parsed <- shinyFiles::parseFilePaths(volumes, input$browse_input_file)
        if (nrow(parsed) > 0L && isTRUE(nzchar(parsed$datapath[[1]]))) {
          path <- parsed$datapath[[1]]
          input_path(path)
          shiny::updateTextInput(session, "input_path", value = path)
          refresh_available_fields(path)
        }
      })

      shinyFiles::shinyDirChoose(
        input,
        "browse_output_folder",
        roots = volumes,
        session = session,
        defaultRoot = default_browser_root,
        defaultPath = ""
      )
      observeEvent(input$browse_output_folder, {
        parsed <- tryCatch(shinyFiles::parseDirPath(volumes, input$browse_output_folder), error = function(e) character())
        if (length(parsed) > 0L && isTRUE(nzchar(parsed[[1]])) && dir.exists(parsed[[1]])) {
          selected_folder <- normalizePath(parsed[[1]], winslash = "/", mustWork = FALSE)
          output_dir(selected_folder)
          shiny::updateTextInput(session, "output_folder", value = selected_folder)
          status_text("Output folder selected")
        } else if (length(parsed) > 0L && isTRUE(nzchar(parsed[[1]]))) {
          status_text("The selected output folder does not exist.")
        }
      })
    }

    refresh_available_fields <- function(path) {
      selected_fields(character())
      asked_matching_fields(character())
      pending_matching_fields(character())
      suppress_matching_prompt(FALSE)
      shiny::updateTextInput(session, "field_search", value = "")
      fields <- get_input_fields(path)
      available_fields(fields)
      if (length(fields) > 0L) {
        status_text(sprintf("Input file selected; %d fields found", length(fields)))
      } else {
        status_text("Input file selected; no fields found")
      }
    }

    observeEvent(input$input_path, {
      path <- trimws(input$input_path %||% "")
      input_path(path)
      if (nzchar(path) && file.exists(path)) refresh_available_fields(path)
    }, ignoreNULL = FALSE)

    observe({
      output_dir(trimws(input$output_folder %||% ""))
    })

    observeEvent(input$input_file, {
      if (!has_shiny_files && !is.null(input$input_file)) {
        input_path(input$input_file$datapath)
        refresh_available_fields(input$input_file$datapath)
      }
    }, ignoreNULL = TRUE)

    output$fields_ui <- shiny::renderUI({
      fields <- selected_fields()
      all_fields <- available_fields()
      visible_fields <- filter_fields_by_query(all_fields, input$field_search %||% "")
      if (!nzchar(input_path())) {
        return(shiny::tags$div(class = "jcm-field-list", "(choose an input file on the Setup tab)"))
      }
      if (length(all_fields) == 0L) {
        return(shiny::tags$div(class = "jcm-field-list", "(no fields found)"))
      }
      shiny::tags$div(
        shiny::textInput("field_search", "Search fields", value = input$field_search %||% "", placeholder = "Type part of a field name"),
        shiny::tags$div(
          class = "jcm-field-list",
          if (length(visible_fields) == 0L) {
            shiny::tags$div("(no matching fields)")
          } else {
            shiny::checkboxGroupInput("mask_fields", "Select Fields to Mask", choices = visible_fields, selected = intersect(fields, visible_fields))
          }
        )
      )
    })

    observeEvent(input$go_fields, {
      if (!nzchar(input_path())) {
        status_text("Choose an input file before selecting fields.")
      } else {
        shiny::updateTabsetPanel(session, "main_tabs", selected = "Fields")
      }
    })

    observeEvent(input$mask_fields, {
      visible_fields <- filter_fields_by_query(available_fields(), input$field_search %||% "")
      previous <- selected_fields()
      current <- unique(c(setdiff(previous, visible_fields), input$mask_fields %||% character()))
      selected_fields(current)

      if (isTRUE(suppress_matching_prompt())) {
        suppress_matching_prompt(FALSE)
        status_text(sprintf("Selected %d fields", length(selected_fields())))
        return()
      }

      newly_selected <- setdiff(current, previous)
      asked <- asked_matching_fields()
      for (field in newly_selected) {
        leaf <- get_field_leaf_name(field)
        if (!nzchar(leaf) || leaf %in% asked) next

        matches <- find_matching_leaf_fields(field, available_fields())
        matches_to_add <- setdiff(matches, current)
        if (length(matches_to_add) == 0L) next

        asked <- unique(c(asked, leaf))
        asked_matching_fields(asked)
        pending_matching_fields(unique(c(current, matches_to_add)))
        shiny::showModal(shiny::modalDialog(
          title = "Select matching fields?",
          sprintf(
            "The field '%s' also appears in %d other place(s). Select all matching '%s' fields?",
            leaf,
            length(matches_to_add),
            leaf
          ),
          footer = shiny::tagList(
            shiny::modalButton("No"),
            shiny::actionButton("select_matching_leaf_fields", "Yes")
          ),
          easyClose = TRUE
        ))
        break
      }

      status_text(sprintf("Selected %d fields", length(selected_fields())))
    }, ignoreNULL = FALSE)

    observeEvent(input$select_matching_leaf_fields, {
      fields <- pending_matching_fields()
      shiny::removeModal()
      if (length(fields) > 0L) {
        selected_fields(fields)
        suppress_matching_prompt(TRUE)
        shiny::updateCheckboxGroupInput(session, "mask_fields", selected = fields)
        status_text(sprintf("Selected %d fields", length(fields)))
      }
      pending_matching_fields(character())
    })

    observeEvent(input$select_all_fields, {
      fields <- available_fields()
      selected_fields(fields)
      suppress_matching_prompt(TRUE)
      shiny::updateCheckboxGroupInput(session, "mask_fields", selected = intersect(fields, filter_fields_by_query(fields, input$field_search %||% "")))
    })

    observeEvent(input$clear_fields, {
      selected_fields(character())
      suppress_matching_prompt(TRUE)
      shiny::updateCheckboxGroupInput(session, "mask_fields", selected = character())
    })

    observeEvent(input$go_run, {
      shiny::updateTabsetPanel(session, "main_tabs", selected = "Run")
    })

    reset_app <- function() {
      selected_fields(character())
      available_fields(character())
      asked_matching_fields(character())
      pending_matching_fields(character())
      suppress_matching_prompt(FALSE)
      log_lines(character())
      status_text("Ready")
      is_running(FALSE)
      input_path("")
      shiny::updateTextInput(session, "input_path", value = "")
      shiny::updateTextInput(session, "field_search", value = "")
      shiny::updateTextInput(session, "output_folder", value = "")
      output_dir("")
      send_progress_message(session, status = "Ready", clear_log = TRUE)
    }

    observeEvent(input$reset, {
      reset_app()
    })

    observeEvent(input$reset_run, {
      reset_app()
    })

    observeEvent(input$run, {
      if (isTRUE(is_running())) return()
      run_input_path <- input_path()
      if (!nzchar(run_input_path) || !file.exists(run_input_path) ||
          !nzchar(input$secret_key %||% "") || length(selected_fields()) == 0L) {
        status_text("Choose an input file, enter a secret key, and select at least one field.")
        return()
      }
      is_running(TRUE)
      dir.create(output_dir(), recursive = TRUE, showWarnings = FALSE)
      status_text("Processing...")
      log_lines(character())
      send_progress_message(session, status = "Processing...", clear_log = TRUE)
      callback <- function(stage, current, total, message) {
        line <- paste(format(Sys.time(), "%H:%M:%S"), sprintf("[%s] %s", stage, message))
        log_lines(tail(c(log_lines(), line), 100L))
        status_text(sprintf("%s: %s", tools::toTitleCase(stage), message))
        send_progress_message(session, line = line, status = status_text())
      }
      tryCatch({
        # Create timestamped subfolder for GUI runs
        timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
        gui_output_dir <- file.path(output_dir(), paste0("Masked_Data_GUI_", timestamp))
        dir.create(gui_output_dir, recursive = TRUE, showWarnings = FALSE)
        
        key_file <- file.path(gui_output_dir, "masking_key.csv")
        invoke_masking(run_input_path, gui_output_dir, key_file, input$secret_key, selected_fields(), callback)
        state <- .state()
        status_text(sprintf("Complete! Processed %d %s | Masked %d fields | Generated %d tables\nOutput saved to: %s",
                            state$processed_lines, tolower(state$progress_record_label),
                            state$masked_fields_processed, state$tables_produced, gui_output_dir))
        send_progress_message(session, status = status_text())
      }, error = function(e) {
        status_text(paste("Error:", conditionMessage(e)))
        send_progress_message(session, status = status_text())
      }, finally = {
        is_running(FALSE)
      })
    })

    output$setup_status <- shiny::renderText(status_text())
    output$selected_fields_text <- shiny::renderText(format_selected_fields(selected_fields()))
    output$selected_fields_text_fields <- shiny::renderText(format_selected_fields(selected_fields()))
    output$input_step_message <- render_step_message(function() get_input_step_message(input_path()))
    output$output_step_message <- render_step_message(function() get_output_step_message(output_dir()))
    output$key_step_message <- render_step_message(function() get_key_step_message(input$secret_key))
    output$fields_button_step_message <- render_step_message(function() get_fields_button_step_message(input_path(), available_fields()))
    output$run_tab_step_message <- render_step_message(function() get_run_tab_step_message(input_path(), available_fields(), selected_fields()))
    output$run_step_message <- render_step_message(function() {
      get_run_step_message(input_path(), output_dir(), input$secret_key, selected_fields())
    })
  }

  shiny::shinyApp(ui, server)
}

run_datamaskr <- function(...) {
  shiny::runApp(jsoncsvmaskr_app(), ...)
}

run_app <- function(...) {
  run_datamaskr(...)
}

get_input_fields <- function(input_path) {
  if (is.null(input_path) || !nzchar(input_path) || !file.exists(input_path)) return(character())
  tryCatch({
    ext <- tolower(tools::file_ext(input_path))
    fields <- if (identical(ext, "csv")) get_csv_fields(input_path) else get_json_fields(input_path)
    sort(unique(fields))
  }, error = function(e) character())
}

format_selected_fields <- function(fields) {
  if (length(fields) == 0L) return("(none)")
  paste(fields, collapse = "\n")
}

get_field_leaf_name <- function(field) {
  if (is.null(field) || length(field) == 0L || !nzchar(field[[1]] %||% "")) return("")
  parts <- strsplit(field[[1]], ".", fixed = TRUE)[[1]]
  parts[[length(parts)]]
}

find_matching_leaf_fields <- function(field, fields) {
  leaf <- get_field_leaf_name(field)
  if (!nzchar(leaf) || length(fields) == 0L) return(character())
  field_leaves <- vapply(fields, get_field_leaf_name, character(1))
  setdiff(fields[field_leaves == leaf], field)
}

filter_fields_by_query <- function(fields, query) {
  query <- trimws(query %||% "")
  if (length(fields) == 0L || !nzchar(query)) return(fields)
  fields[grepl(tolower(query), tolower(fields), fixed = TRUE)]
}

render_step_message <- function(message_callback) {
  shiny::renderUI({
    message <- message_callback()
    if (is.null(message) || !nzchar(message)) return(NULL)
    shiny::tags$div(class = "jcm-step-message", message)
  })
}

get_input_step_message <- function(input_path) {
  if (!nzchar(input_path %||% "")) return("Choose an input JSON or CSV file.")
  if (!file.exists(input_path)) return("The selected input file does not exist.")
  ext <- tolower(tools::file_ext(input_path))
  if (!ext %in% c("json", "csv")) return("Choose a .json or .csv input file.")
  ""
}

get_output_step_message <- function(output_folder) {
  if (!nzchar(output_folder %||% "")) return("Choose an output folder.")
  parent <- dirname(output_folder)
  if (!dir.exists(output_folder) && !dir.exists(parent)) {
    return("Choose an output folder whose parent folder exists.")
  }
  ""
}

get_key_step_message <- function(secret_key) {
  if (!nzchar(secret_key %||% "")) return("Enter a secret key.")
  ""
}

get_fields_button_step_message <- function(input_path, available_fields) {
  input_message <- get_input_step_message(input_path)
  if (nzchar(input_message)) return("Choose a valid input file before selecting fields.")
  if (length(available_fields) == 0L) return("No fields were found in the selected input file.")
  ""
}

get_run_tab_step_message <- function(input_path, available_fields, selected_fields) {
  fields_message <- get_fields_button_step_message(input_path, available_fields)
  if (nzchar(fields_message)) return(fields_message)
  if (length(selected_fields) == 0L) return("Select at least one field to mask before going to Run.")
  ""
}

get_run_step_message <- function(input_path, output_folder, secret_key, selected_fields) {
  input_message <- get_input_step_message(input_path)
  if (nzchar(input_message)) return("You need to choose a valid input file.")
  output_message <- get_output_step_message(output_folder)
  if (nzchar(output_message)) return("You need to choose an output folder.")
  if (!nzchar(secret_key %||% "")) return("You need to enter a key.")
  if (length(selected_fields) == 0L) return("You need to select at least one field to mask.")
  ""
}

get_shiny_file_roots <- function() {
  first_existing_path <- function(paths) {
    paths <- unique(paths[nzchar(paths %||% "")])
    paths <- paths[dir.exists(paths)]
    if (length(paths) == 0L) return("")
    normalizePath(paths[[1]], winslash = "/", mustWork = FALSE)
  }

  home <- first_existing_path(c(Sys.getenv("USERPROFILE"), Sys.getenv("HOME"), path.expand("~")))
  documents_candidates <- c(path.expand("~/Documents"))
  if (nzchar(home) && !identical(tolower(basename(home)), "documents")) {
    documents_candidates <- c(file.path(home, "Documents"), documents_candidates)
  }
  documents <- first_existing_path(documents_candidates)
  temp <- first_existing_path(tempdir())

  roots <- character()
  if (nzchar(home)) roots <- c(roots, Home = home)
  if (nzchar(documents) && !documents %in% unname(roots)) roots <- c(roots, Documents = documents)
  if (nzchar(temp)) roots <- c(roots, Temp = temp)

  if (.Platform$OS.type == "windows") {
    drives <- paste0(LETTERS, ":/")
    drives <- drives[dir.exists(drives)]
    if (length(drives) > 0L) {
      drive_names <- paste0(substr(drives, 1L, 1L), " Drive")
      roots <- c(roots, stats::setNames(drives, drive_names))
    }
  } else {
    roots <- c(roots, Root = "/")
    volumes <- "/Volumes"
    if (dir.exists(volumes)) roots <- c(roots, Volumes = volumes)
  }
  roots <- roots[!duplicated(unname(roots))]
  roots <- roots[dir.exists(unname(roots))]
  stats::setNames(unname(roots), names(roots))
}

get_default_shiny_root_name <- function(roots) {
  if (length(roots) == 0L) return(NULL)
  preferred <- c("Documents", "Home")
  match <- preferred[preferred %in% names(roots)]
  if (length(match) > 0L) return(match[[1]])
  names(roots)[[1]]
}

send_progress_message <- function(session, line = NULL, status = NULL, clear_log = FALSE) {
  session$sendCustomMessage(
    "jcm-status-log",
    list(
      line = line,
      status = status,
      clearLog = isTRUE(clear_log)
    )
  )
  try(session$flushReact(), silent = TRUE)
  invisible(NULL)
}

get_shiny_icon_src <- function() {
  icon_path <- system.file("shiny", "icon.svg", package = "JsonCSVMaskr")
  if (!nzchar(icon_path) || !file.exists(icon_path)) {
    candidates <- c(
      "Rpackage/inst/shiny/icon.svg",
      "inst/shiny/icon.svg",
      "icon.svg"
    )
    matches <- candidates[file.exists(candidates)]
    icon_path <- if (length(matches) > 0L) matches[[1]] else ""
  }
  if (!nzchar(icon_path) || !file.exists(icon_path)) return(NULL)
  svg <- paste(readLines(icon_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  paste0("data:image/svg+xml;base64,", jsonlite::base64_enc(charToRaw(svg)))
}
