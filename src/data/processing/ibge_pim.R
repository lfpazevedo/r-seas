# ------------------------------------------------------------
# 1) Extract IBGE series and pivot to "wide" format
#    Assumes pim$all is a list where each element has a structure:
#        entry$resultados[[1]]$series[[1]]$serie
#    and we want to label the first extracted series as "pim_nsa"
#    and the second as "pim_sa". Modify 'var_names' as needed.
# ------------------------------------------------------------
extract_ibge_series_wide <- function(pim) {
  # 'pim$all' should be a list of at least length 2
  series_list <- pim$all
  
  # Adjust if the order or number of series differs
  var_names <- c("pim_nsa", "pim_sa")  
  
  # Loop over each element in 'series_list' and build a data frame
  dfs <- lapply(seq_along(series_list), function(i) {
    entry <- series_list[[i]]
    series_data <- entry$resultados[[1]]$series[[1]]$serie
    
    # Create a data frame of date (from names) and value (as numeric)
    df <- data.frame(
      date = names(series_data),
      value = as.numeric(unlist(series_data)),
      variable = var_names[i],
      stringsAsFactors = FALSE
    )
    return(df)
  })
  
  # Combine all extracted data frames into one "long" data frame
  df_long <- do.call(rbind, dfs)
  
  # Pivot to wide format: separate columns for "pim_nsa" and "pim_sa"
  df_wide <- df_long %>%
    pivot_wider(
      names_from = variable, 
      values_from = value
    ) %>%
    arrange(date)
  
  return(df_wide)
}