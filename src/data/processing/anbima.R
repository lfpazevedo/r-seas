

# 2. Function to process raw holiday data into a structured data frame
process_holiday_data <- function(df) {
  # Rename columns to standard names
  names(df) <- c("Date", "Day_of_the_Week", "Holiday")
  
  # Convert Date column to Date class.
  # If the Excel file stores dates as numbers, you might need to specify the origin.
  # For example: as.Date(df$Date, origin = "1899-12-30")
  df$Date <- as.Date(df$Date)
  
  # Filter rows where Date conversion succeeded (i.e. is not NA)
  df <- df[!is.na(df$Date), ]
  
  return(df)
}

# 3. Function to summarize holidays grouped by year
summarize_holidays <- function(df) {
  # Ensure Date column is Date type
  df$Date <- as.Date(df$Date)
  
  # Get unique years
  unique_years <- unique(format(df$Date, "%Y"))
  df_holiday <- data.frame(Year = as.integer(unique_years))
  
  # Count number of holidays by year
  year_counts <- table(format(df$Date, "%Y"))
  df_holiday$Days_by_Year <- sapply(df_holiday$Year, function(y) {
    count <- year_counts[as.character(y)]
    ifelse(is.na(count), 0, as.integer(count))
  })
  
  # Define holidays and their new column names
  holidays <- c("Carnaval", "Paixão de Cristo", "Corpus Christi")
  names <- c("Carnival", "Easter", "Corpus")
  
  for (i in seq_along(holidays)) {
    holiday <- holidays[i]
    name <- names[i]
    
    # Filter and group by year, getting the last date for each year
    holiday_data <- subset(df, Holiday == holiday)
    grouped <- aggregate(Date ~ format(Date, "%Y"), 
                         data = holiday_data, 
                         FUN = max)
    names(grouped) <- c("Year", name)
    grouped$Year <- as.integer(grouped$Year)
    grouped[[name]] <- as.Date(grouped[[name]])  # Ensure Date class
    
    # Merge with main summary
    df_holiday <- merge(df_holiday, grouped, by = "Year", all.x = TRUE)
  }
  
  return(df_holiday)
}


# # 4. Function to replace specific holiday dates (e.g., for Carnival)
# # Here, 'replacements' should be a named vector where names correspond to the original values
# replace_dates <- function(df, replacements = NULL) {
#   # Check if replacements are provided and a 'Carnival' column exists
#   if (!is.null(replacements) && "Carnival" %in% names(df)) {
#     df$Carnival <- ifelse(df$Carnival %in% names(replacements),
#                           replacements[as.character(df$Carnival)],
#                           df$Carnival)
#   }
#   return(df)
# }

# 5. Function to filter holidays by a given year range
filter_holidays_by_year <- function(df, start_date, end_date) {
  # Convert input dates to Date class and extract the years
  start_year <- as.numeric(format(as.Date(start_date), "%Y"))
  end_year <- as.numeric(format(as.Date(end_date), "%Y"))
  
  # Assuming df already has a 'Year' column, filter based on the year range
  df_filtered <- df[df$Year >= start_year & df$Year <= end_year, ]
  
  return(df_filtered)
}

