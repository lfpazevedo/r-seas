# ------------------------------------------------------------
# 2. Process the downloaded data (filter, clean)
# ------------------------------------------------------------
extract_ibge_ftp <- function(url) {
    # Download + read
    df <- import_excel_data(url)

    # Set the second row as column names
    colnames(df) <- as.character(df[2, ])

    # Remove the (old) first data row after setting colnames
    df <- df[-1, ]

    # Rename columns to "year", "month", "carnival", "corpus"
    # (adjust these if the file actually has more/other columns)
    colnames(df) <- c("year", "month", "carnival", "corpus")

    # Filter out rows with NA values in the "year" column
    df_cleaned <- df %>%
        filter(!is.na(year))

    # Remove the last row (often a totals row or extraneous line)
    df_cleaned <- df_cleaned[-nrow(df_cleaned), ]

    # Convert columns to appropriate types
    df_cleaned <- df_cleaned %>%
        mutate(
            year     = as.integer(year),
            month    = as.integer(month),
            carnival = as.numeric(carnival),
            corpus   = as.numeric(corpus)
        )

    return(df_cleaned)
}
