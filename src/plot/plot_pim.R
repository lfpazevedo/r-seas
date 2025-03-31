# Plot the seasonal adjustment results with a defined date range
plot_pim <- function(ts_data, plot_range) {
  plot(ts_data,
       plot.type = "single",
       col = c("blue", "red", "green"),
       lwd = 2,
       ylab = "Seasonally Adjusted Index",
       main = "PIM SA: IBGE vs X13-SEATS Model",
       xlim = plot_range)
  legend("topleft",
         legend = c("IBGE NSA", "IBGE SA", "Model SA (X13)"),
         col = c("blue", "red", "green"),
         lwd = 2,
         bty = "n")
}
