# ------------------------------------------------------------
# 1. Function to import Excel data from a URL and return a data frame
# ------------------------------------------------------------
import_excel_data <- function(url, file_extension = ".xls") {
    # Create a temporary file with the specified extension
    tmp_file <- tempfile(fileext = file_extension)

    # Download the file (binary mode)
    download.file(url, destfile = tmp_file, mode = "wb")

    # Read the Excel file; header is assumed to be in the first row
    df <- read_excel(tmp_file, col_names = TRUE)

    return(df)
}
