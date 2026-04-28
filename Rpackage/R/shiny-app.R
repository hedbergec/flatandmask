jsoncsvmaskr_app <- function() {
  default_output_dir <- file.path(tempdir(), "JsonCSVMaskr-output")

  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(
        ".jcm-progress { height: 10px; background: #e5e7eb; border-radius: 4px; overflow: hidden; margin: 6px 0 12px; }",
        ".jcm-progress > div { height: 100%; background: #2f7d57; transition: width .2s ease; }",
        ".jcm-log { height: 170px; overflow: auto; white-space: pre; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; border: 1px solid #cbd5e1; padding: 8px; background: white; }",
        ".jcm-field-list { max-height: 260px; overflow: auto; border: 1px solid #cbd5e1; padding: 8px; background: white; }",
        ".jcm-status { border: 1px solid #cbd5e1; padding: 8px; min-height: 38px; background: #f8fafc; }"
      )
    ),
    shiny::h3("JsonCSVMaskr"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::fileInput("input_file", "Input File (JSON/CSV)", accept = c(".json", ".csv")),
        shiny::textInput("output_folder", "Output Folder", value = default_output_dir),
        shiny::passwordInput("secret_key", "Secret Key"),
        shiny::actionButton("load_fields", "Select Fields to Mask"),
        shiny::br(), shiny::br(),
        shiny::actionButton("run", "Run Masking"),
        shiny::actionButton("reset", "Reset"),
        shiny::hr(),
        shiny::tags$p("NO WARRANTY: This tool is provided as-is, without warranty of any kind."),
        shiny::tags$a("Git repository", href = "https://github.com/hedbergec/flatandmask", target = "_blank")
      ),
      shiny::column(
        width = 8,
        shiny::h4("Selected Fields"),
        shiny::uiOutput("fields_ui"),
        shiny::h4("Progress"),
        progress_bar_ui("Load", "load_bar"),
        progress_bar_ui("Mask", "mask_bar"),
        progress_bar_ui("Normalize", "normalize_bar"),
        progress_bar_ui("Export", "export_bar"),
        shiny::h4("Status"),
        shiny::tags$div(class = "jcm-status", shiny::textOutput("status")),
        shiny::h4("Console"),
        shiny::tags$div(class = "jcm-log", shiny::textOutput("console_log"))
      )
    )
  )

  server <- function(input, output, session) {
    progress_values <- shiny::reactiveVal(list(load = 0, mask = 0, normalize = 0, export = 0))
    log_lines <- shiny::reactiveVal(character())
    selected_fields <- shiny::reactiveVal(character())
    output_dir <- shiny::reactiveVal(default_output_dir)
    status_text <- shiny::reactiveVal("Ready")

    observe({
      if (nzchar(input$output_folder %||% "")) output_dir(input$output_folder)
    })

    output$fields_ui <- shiny::renderUI({
      input_file <- input$input_file
      fields <- selected_fields()
      if (is.null(input_file)) return(shiny::tags$div(class = "jcm-field-list", "(none)"))
      all_fields <- tryCatch({
        ext <- tolower(tools::file_ext(input_file$name))
        if (identical(ext, "csv")) get_csv_fields(input_file$datapath) else get_json_fields(input_file$datapath)
      }, error = function(e) character())
      shiny::tags$div(
        class = "jcm-field-list",
        shiny::checkboxGroupInput("mask_fields", NULL, choices = all_fields, selected = fields)
      )
    })

    observeEvent(input$load_fields, {
      selected_fields(input$mask_fields %||% character())
      status_text(sprintf("Selected %d fields", length(selected_fields())))
    })

    observeEvent(input$mask_fields, {
      selected_fields(input$mask_fields %||% character())
    }, ignoreNULL = FALSE)

    observeEvent(input$reset, {
      selected_fields(character())
      log_lines(character())
      progress_values(list(load = 0, mask = 0, normalize = 0, export = 0))
      status_text("Ready")
    })

    observeEvent(input$run, {
      req_file <- input$input_file
      if (is.null(req_file) || !nzchar(input$secret_key %||% "") || length(selected_fields()) == 0L) {
        status_text("Choose an input file, enter a secret key, and select at least one field.")
        return()
      }
      dir.create(output_dir(), recursive = TRUE, showWarnings = FALSE)
      status_text("Processing...")
      log_lines(character())
      progress_values(list(load = 0, mask = 0, normalize = 0, export = 0))
      callback <- function(stage, current, total, message) {
        values <- progress_values()
        values[[stage]] <- if (total <= 0) 0 else round(100 * current / total)
        progress_values(values)
        line <- paste(format(Sys.time(), "%H:%M:%S"), sprintf("[%s] %s", stage, message))
        log_lines(tail(c(log_lines(), line), 100L))
      }
      tryCatch({
        key_file <- file.path(output_dir(), "masking_key.csv")
        invoke_masking(req_file$datapath, output_dir(), key_file, input$secret_key, selected_fields(), callback)
        state <- .state()
        status_text(sprintf("Complete! Processed %d %s | Masked %d fields | Generated %d tables",
                            state$processed_lines, tolower(state$progress_record_label),
                            state$masked_fields_processed, state$tables_produced))
      }, error = function(e) {
        status_text(paste("Error:", conditionMessage(e)))
      })
    })

    output$load_bar <- render_progress_width("load", progress_values)
    output$mask_bar <- render_progress_width("mask", progress_values)
    output$normalize_bar <- render_progress_width("normalize", progress_values)
    output$export_bar <- render_progress_width("export", progress_values)
    output$status <- shiny::renderText(status_text())
    output$console_log <- shiny::renderText(paste(log_lines(), collapse = "\n"))
  }

  shiny::shinyApp(ui, server)
}

run_datamaskr <- function(...) {
  shiny::runApp(jsoncsvmaskr_app(), ...)
}

run_app <- function(...) {
  run_datamaskr(...)
}

progress_bar_ui <- function(label, output_id) {
  shiny::tagList(
    shiny::tags$div(label),
    shiny::tags$div(class = "jcm-progress", shiny::uiOutput(output_id))
  )
}

render_progress_width <- function(stage, progress_values) {
  shiny::renderUI({
    value <- progress_values()[[stage]] %||% 0
    shiny::tags$div(style = sprintf("width: %d%%;", max(0, min(100, value))))
  })
}
