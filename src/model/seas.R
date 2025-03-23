# Perform seasonal adjustment using the selected ARIMA model
perform_seasonal_adjustment <- function(pim_nsa_ts, regs, selected_arima) {
  m1 <- seas(x = pim_nsa_ts,
             regression.variables = c("td",
                                      "easter[1]",
                                      "LS2008.Nov",
                                      "TC2008.Dec",
                                      "AO2018.May",
                                      "AO2020.Mar",
                                      "TC2020.Apr"),
             xreg = regs,
             regression.usertype = c("holiday"),
             arima.model = selected_arima,
             outlier.types = "all",
             transform.function = "auto",
             x11 = "",
             forecast.maxlead = 12,
             forecast.maxback = 12)
  return(final(m1))
}
