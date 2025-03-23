# src/model/dataframe.R

make_dataframe <- function(carnival_range, corpus_range, arima_model) {
  # Load and process holidays
  url <- "https://www.anbima.com.br/feriados/arqs/feriados_nacionais.xls"
  raw_data <- fetch_holiday_data(url)
  holiday_data <- process_holiday_data(raw_data)
  holiday_data <- holiday_data %>% mutate(Year = as.numeric(format(Date, "%Y")))
  filtered_holidays <- filter_holidays_by_year(holiday_data, "2001-01-01", "2026-12-31")
  holiday_summary <- summarize_holidays(filtered_holidays)
  
  # Generate holiday regressors using the modular function (from genhol.R)
  regs <- generate_regressors(holiday_summary, carnival_range, corpus_range)
  
  # Fetch PIM data from IBGE:
  AGGREGATION_ID <- 8888
  PERIODS <- c("all")
  VARIABLE <- c(12606, 12607)
  CLASSIFICATION <- c("544[129314]")
  LOCATIONS <- c("N1[all]")
  
  pim <- fetch_ibge_data(
    aggregation_id = AGGREGATION_ID,
    periods = PERIODS,
    variable = VARIABLE,
    classification = CLASSIFICATION,
    location = LOCATIONS[1]
  )
  
  df_pim <- extract_ibge_series_wide(pim)
  
  # Extract year and month from 'date' column
  df_pim$year <- as.numeric(substr(df_pim$date, 1, 4))
  df_pim$month <- as.numeric(substr(df_pim$date, 5, 6))
  start_year <- df_pim$year[1]
  start_month <- df_pim$month[1]
  pim_nsa_ts <- ts(df_pim$pim_nsa, start = c(start_year, start_month), frequency = 12)
  pim_sa_ts  <- ts(df_pim$pim_sa, start = c(start_year, start_month), frequency = 12)
  
  # Perform seasonal adjustment using the modular function (from seas.R)
  model_sa <- perform_seasonal_adjustment(pim_nsa_ts, regs, arima_model)
  
  # Combine series for plotting
  ts_data <- ts.union(IBGE_NSA = pim_nsa_ts,
                      IBGE_SA  = pim_sa_ts,
                      Model_SA = model_sa)
  
  return(ts_data)
}
