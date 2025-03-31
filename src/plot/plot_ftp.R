create_ftp_plot <- function(combined_long,
                            target_years = 2001:2026,
                            target_months = c(2, 3, 5, 6),
                            output_file = "holiday_horizontal_bar_comparison.png",
                            save_plot = TRUE) {
  # ------------------------------------------------------------
  # 1. Filter data and create CHARACTER label
  # ------------------------------------------------------------
  panel_data <- combined_long %>%
    filter(
      year %in% target_years,
      month %in% target_months
    ) %>%
    mutate(
      date = as.Date(date), # Ensure it's a Date object
      year_month_label_char = format(date, "%Y %b")
    )

  # ------------------------------------------------------------
  # 2. Determine Correct Factor Order
  # ------------------------------------------------------------
  ordered_levels <- panel_data %>%
    distinct(date, year_month_label_char) %>%
    arrange(date) %>%
    pull(year_month_label_char)

  # ------------------------------------------------------------
  # 3. Convert to ORDERED FACTOR
  # ------------------------------------------------------------
  panel_data <- panel_data %>%
    mutate(
      year_month_label = factor(year_month_label_char, levels = ordered_levels)
    )

  # ------------------------------------------------------------
  # 4. Create the plot
  # ------------------------------------------------------------
  if (inherits(panel_data$year_month_label, "factor")) {
    horizontal_bar_plot <- ggplot(panel_data, aes(y = year_month_label, x = weight, fill = source)) +
      geom_col(position = position_dodge(width = 0.9), width = 0.8) +
      facet_wrap(~holiday, scales = "free_x", ncol = 2) +
      labs(
        title = "Holiday Weights Comparison (Selected Months)",
        subtitle = paste("Years: 2001 to 2026", "; Months: Feb, Mar, May, Jun"),
        x = "Weight Value",
        y = "Year & Month",
        fill = "Data Source"
      ) +
      theme_minimal() +
      theme(
        axis.text.y = element_text(size = 9),
        strip.text = element_text(size = 11, face = "bold")
      )

    print(horizontal_bar_plot)

    # ------------------------------------------------------------
    # 5. Save the plot (optional)
    # ------------------------------------------------------------
    if (save_plot) {
      ggsave(
        filename = output_file,
        plot = horizontal_bar_plot,
        width = 10,
        height = 7,
        dpi = 300
      )
    }

    return(horizontal_bar_plot)
  } else {
    message("Skipping plot generation because 'panel_data' or 'year_month_label' factor is not set up correctly. Please check the transformation.")
    return(NULL)
  }
}

# ------------------------------------------------------------
# Function to plot holiday data from the FTP dataset
# ------------------------------------------------------------
plot_genhol <- function(combined_long, year_range) {
  # Convert year range slider values to actual range for filtering
  target_years <- seq(year_range[1], year_range[2])

  # Use the existing create_ftp_plot function with specified year range
  # and default months that are most relevant (Feb, Mar, May, Jun)
  plot <- create_ftp_plot(
    combined_long = combined_long,
    target_years = target_years,
    target_months = c(2, 3, 5, 6),
    save_plot = FALSE
  )

  return(plot)
}
