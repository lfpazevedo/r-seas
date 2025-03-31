fetch_ibge_data <- function(
    aggregation_id,
    periods,
    variable,
    classification,
    location,
    cert_path = NULL,
    timeout = 30
) {
  results <- list()
  
  # Collapse variables (e.g., 12606|12607)
  variable_str <- paste(variable, collapse = "|")
  # Collapse classifications (e.g., 544[129314])
  classification_str <- paste(classification, collapse = "|")
  
  for (period in periods) {
    url <- paste0(
      "https://servicodados.ibge.gov.br/api/v3/agregados/", aggregation_id,
      "/periodos/", period,
      "/variaveis/", variable_str,
      "?localidades=", location,
      "&classificacao=", classification_str
    )
    
    config <- if (!is.null(cert_path)) {
      config(ssl_verifypeer = TRUE, ssl_verifyhost = TRUE, cainfo = cert_path)
    } else {
      config()
    }
    
    tryCatch({
      response <- GET(url, config, timeout(timeout))
      stop_for_status(response)
      data <- content(response, as = "parsed", type = "application/json")
      results[[period]] <- data
    }, error = function(e) {
      warning(sprintf(
        "Error fetching data for period %s at %s with variable(s) %s and aggregation %s: %s",
        period, location, variable_str, aggregation_id, e$message
      ))
      results[[period]] <- NULL
    })
  }
  
  return(results)
}
