# First: extract series and tag them manually (assumes 1st is NSA, 2nd is SA)
extract_ibge_series_wide <- function(pim) {
  series_list <- pim$all
  var_names <- c("pim_nsa", "pim_sa")  # Adjust if reversed
  
  dfs <- lapply(seq_along(series_list), function(i) {
    entry <- series_list[[i]]
    series_data <- entry$resultados[[1]]$series[[1]]$serie
    
    df <- data.frame(
      date = names(series_data),
      value = as.numeric(unlist(series_data)),
      variable = var_names[i],
      stringsAsFactors = FALSE
    )
    return(df)
  })
  
  # Combine and pivot
  df_long <- do.call(rbind, dfs)
  
  df_wide <- df_long %>%
    pivot_wider(names_from = variable, values_from = value) %>%
    arrange(date)
  
  return(df_wide)
}