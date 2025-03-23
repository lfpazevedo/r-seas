library(shiny)
library(here)
library(readxl)   # For reading Excel files
library(dplyr)
library(tidyr)
library(seasonal)
library(httr)
library(jsonlite)

# Source your custom data scripts
source(here("src", "data", "api", "anbima.R"))
source(here("src", "data", "processing", "anbima.R"))
source(here("src", "data", "api", "ibge.R"))
source(here("src", "data", "processing", "ibge.R"))

# Source analysis modules
source(here("src", "model", "genhol.R"))
source(here("src", "model", "seas.R"))
source(here("src", "model", "plot.R"))
source(here("src", "model", "dataframe.R"))  # New file for building the dataframe

# Define UI for the app
ui <- fluidPage(
  titlePanel("PIM Seasonal Adjustment App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("carnival_range", "Carnival Range (start, end):",
                  min = -10, max = 10, value = c(-4, -1)),
      sliderInput("corpus_range", "Corpus Range (start, end):",
                  min = -10, max = 10, value = c(1, 3)),
      selectInput("arima_model", "ARIMA Model:",
                  choices = c("(1 1 0)(1 1 0)",
                              "(2 1 0)(2 1 0)",
                              "(0 1 1)(0 1 1)",
                              "(0 1 2)(0 1 1)"),
                  selected = "(0 1 2)(0 1 1)"),
      sliderInput("plot_range", "Plot Date Range (years):",
                  min = 2001, max = 2026, value = c(2001, 2026), step = 1, sep = ""),
      actionButton("update", "Update View")
    ),
    mainPanel(
      plotOutput("pimPlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  pimData <- eventReactive(input$update, {
    # Use the modular function to create the dataframe
    make_dataframe(input$carnival_range, input$corpus_range, input$arima_model)
  })
  
  output$pimPlot <- renderPlot({
    ts_data <- pimData()
    # Plot using the modular plot function (from plot.R)
    plot_pim(ts_data, input$plot_range)
  })
}

shinyApp(ui, server)
