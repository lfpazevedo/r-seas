
# 1. Function to fetch holiday data from a URL and return a data frame
fetch_holiday_data <- function(url) {
  # Create a temporary file with .xls extension
  tmp_file <- tempfile(fileext = ".xls")
  
  # Download the file (binary mode)
  download.file(url, destfile = tmp_file, mode = "wb")
  
  # Read the Excel file; header is assumed to be in the first row
  df <- read_excel(tmp_file, col_names = TRUE)
  
  return(df)
}

