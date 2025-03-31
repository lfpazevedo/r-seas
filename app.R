library(shiny)
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(seasonal)
library(httr)
library(jsonlite)
library(ggplot2) # Added for plot_genhol function
library(lubridate) # Added for date functions

# Load custom functions
source(here("src", "data", "utils", "import_excel_data.R"))

# Source your custom data scripts
source(here("src", "data", "api", "ibge_pim.R"))
source(here("src", "data", "processing", "anbima.R"))
source(here("src", "data", "processing", "ibge_ftp.R"))
source(here("src", "data", "processing", "ibge_pim.R"))

# Source analysis modules
source(here("src", "model", "genhol.R"))
source(here("src", "model", "seas.R"))
source(here("src", "dataframe", "df_ftp.R"))
source(here("src", "dataframe", "df_pim.R"))
source(here("src", "plot", "plot_ftp.R"))
source(here("src", "plot", "plot_pim.R"))


# Define UI for the app
ui <- fluidPage(
  titlePanel("PIM Seasonal Adjustment App"),

  # Add styling
  tags$head(
    tags$style(HTML("
      .shiny-notification {
        position: fixed;
        top: 33%;
        left: 33%;
        width: 33%;
      }
      .sidebar-section {
        margin-bottom: 20px;
        border-bottom: 1px solid #e0e0e0;
        padding-bottom: 15px;
      }
    "))
  ),
  sidebarLayout(
    sidebarPanel(
      div(
        class = "sidebar-section",
        h4("Holiday Parameters"),
        sliderInput("carnival_range", "Carnival Range (start, end):",
          min = -10, max = 10, value = c(-4, -1)
        ),
        sliderInput("corpus_range", "Corpus Range (start, end):",
          min = -10, max = 10, value = c(1, 3)
        ),
        checkboxInput("fix_carnival_dates", "Shift Carnival dates one day forward in 2003/14/22/25", value = FALSE)
      ),
      div(
        class = "sidebar-section",
        h4("Model Selection"),
        selectInput("arima_model", "ARIMA Model:",
          choices = c(
            "(1 1 0)(1 1 0)",
            "(2 1 0)(2 1 0)",
            "(0 1 1)(0 1 1)",
            "(0 1 2)(0 1 1)"
          ),
          selected = "(0 1 2)(0 1 1)"
        )
      ),
      div(
        class = "sidebar-section",
        h4("Display Options"),
        sliderInput("plot_range", "Plot Date Range (years):",
          min = 2001, max = 2026, value = c(2001, 2026), step = 1, sep = ""
        )
      ),
      div(
        style = "display: flex; justify-content: space-between; margin-top: 20px;",
        actionButton("update", "Update View", class = "btn-primary", icon = icon("refresh")),
        actionButton("default", "Reset to Defaults", class = "btn-info", icon = icon("undo"))
      )
    ),
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel(
          "PIM Seasonal Adjustment",
          plotOutput("pimPlot", height = "400px"),
          tags$hr(),
          verbatimTextOutput("modelSummary")
        ),
        tabPanel(
          "Holiday Effects",
          plotOutput("genholPlot", height = "500px"),
          tags$hr(),
          downloadButton("downloadHolidayPlot", "Download Plot")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive values to track computation status
  status <- reactiveVal("idle")

  # Reactive values to store model data
  model_data <- reactiveValues(
    pim_results = NULL,
    genhol_results = NULL,
    last_error = NULL
  )

  # Function to show notifications
  show_status <- function(message, type = "message") {
    removeNotification(id = "statusNotification")
    showNotification(
      message,
      type = type,
      duration = NULL,
      id = "statusNotification"
    )
  }

  # Compute PIM data with error handling
  pimData <- eventReactive(input$update, {
    show_status("Computing seasonal adjustment model...", "message")
    status("computing")

    tryCatch(
      {
        result <- make_dataframe(input$carnival_range, input$corpus_range, input$arima_model)
        status("done")
        removeNotification(id = "statusNotification")
        model_data$pim_results <- result
        return(result)
      },
      error = function(e) {
        status("error")
        model_data$last_error <- e$message
        show_status(paste("Error in PIM data calculation:", e$message), "error")
        return(NULL)
      }
    )
  })

  # Compute holiday regressor data with error handling
  genholData <- eventReactive(input$update, {
    show_status("Computing holiday regressors...", "message")

    tryCatch(
      {
        # Pass the fix_carnival_dates flag from UI input
        result <- main(input$carnival_range, input$corpus_range, input$fix_carnival_dates)
        model_data$genhol_results <- result
        return(result)
      },
      error = function(e) {
        model_data$last_error <- e$message
        show_status(paste("Error in holiday data calculation:", e$message), "error")
        return(NULL)
      }
    )
  })

  # Render PIM plot
  output$pimPlot <- renderPlot({
    req(pimData())
    plot_pim(pimData(), input$plot_range)
  })

  # Render model summary
  output$modelSummary <- renderPrint({
    req(pimData())
    cat("Model Status: ", status(), "\n")
    cat("ARIMA Model: ", input$arima_model, "\n")
    cat("Date Range: ", input$plot_range[1], "-", input$plot_range[2], "\n")
    cat("Holiday Adjustments: ",
      "Carnival (", input$carnival_range[1], " to ", input$carnival_range[2], "), ",
      "Corpus (", input$corpus_range[1], " to ", input$corpus_range[2], ")\n",
      "Carnival date adjustment: ", ifelse(input$fix_carnival_dates, "Applied", "Not applied"), "\n",
      sep = ""
    )
  })

  # Render holiday effect plot
  output$genholPlot <- renderPlot({
    req(genholData())
    plot_genhol(genholData(), input$plot_range)
  })

  # Download handler for holiday plot
  output$downloadHolidayPlot <- downloadHandler(
    filename = function() {
      paste("holiday_weights_", format(Sys.Date(), "%Y%m%d"), ".png", sep = "")
    },
    content = function(file) {
      # Create the plot and save it directly
      target_years <- seq(input$plot_range[1], input$plot_range[2])
      create_ftp_plot(
        combined_long = genholData(),
        target_years = target_years,
        target_months = c(2, 3, 5, 6),
        output_file = file,
        save_plot = TRUE
      )
    }
  )

  # Reset all inputs to default values
  observeEvent(input$default, {
    updateSliderInput(session, "carnival_range", value = c(-4, -1))
    updateSliderInput(session, "corpus_range", value = c(1, 3))
    updateSelectInput(session, "arima_model", selected = "(0 1 2)(0 1 1)")
    updateSliderInput(session, "plot_range", value = c(2001, 2026))
    updateCheckboxInput(session, "fix_carnival_dates", value = FALSE)

    # Show notification
    showNotification("Reset to default values", type = "message")
  })
}

shinyApp(ui, server)
