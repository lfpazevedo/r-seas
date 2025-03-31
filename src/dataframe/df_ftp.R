# Function to adjust Carnival dates with a boolean flag for applying adjustments
adjust_carnival <- function(data, adjust = TRUE) {
    if (adjust) {
        data <- data %>%
            mutate(
                Carnival = case_when(
                    Carnival == as.Date("2022-03-01") ~ as.Date("2022-03-02"),
                    Carnival == as.Date("2003-03-04") ~ as.Date("2003-03-05"),
                    Carnival == as.Date("2014-03-04") ~ as.Date("2014-03-05"),
                    Carnival == as.Date("2025-03-04") ~ as.Date("2025-03-05"),
                    TRUE ~ Carnival
                )
            )
    }
    data
}

# Function to load and process IBGE data
get_ibge_data <- function() {
    url <- paste0(
        "https://ftp.ibge.gov.br/Industrias_Extrativas_e_de_Transformacao/",
        "Pesquisa_Industrial_Mensal_Producao_Fisica/Material_de_apoio/",
        "2025_Pesos_ajuste_sazonal_series_iniciadas_em_2002.xls"
    )
    ibge <- extract_ibge_ftp(url)
    ibge <- ibge %>%
        mutate(date = make_date(year, month, 1))
    ibge
}

# Function to load and process holiday data, now accepts an adjust flag
get_holiday_data <- function(adjust = TRUE) {
    url <- "https://www.anbima.com.br/feriados/arqs/feriados_nacionais.xls"
    raw_data <- import_excel_data(url, file_extension = ".xls")
    holiday_data <- process_holiday_data(raw_data) %>%
        mutate(Year = as.numeric(format(Date, "%Y")))
    filtered_holidays <- filter_holidays_by_year(holiday_data, "2001-01-01", "2026-12-31")
    holiday_summary <- summarize_holidays(filtered_holidays)
    # Adjust Carnival dates based on the flag
    holiday_summary <- adjust_carnival(holiday_summary, adjust = adjust)
    holiday_summary
}

# Function to generate and prepare the regressors data frame
prepare_regs <- function(holiday_summary,
                         carnival_range = c(-4, -1),
                         corpus_range = c(1, 3),
                         start_date_str = "2001-01-01",
                         end_date_str = "2026-12-31") {
    regs <- generate_regressors(holiday_summary, carnival_range, corpus_range)
    
    start_date <- as.Date(start_date_str)
    effective_end_date <- ceiling_date(as.Date(end_date_str), "month") - days(1)
    date_seq <- seq.Date(start_date, effective_end_date, by = "month")
    
    if (nrow(regs) != length(date_seq)) {
        warning(paste(
            "Mismatch between number of rows in 'regs' (", nrow(regs),
            ") and expected number of months in the sequence (", length(date_seq),
            "). Verify the output of 'generate_regressors'."
        ))
    }
    
    regs_df <- as.data.frame(regs) %>%
        rename(
            carnival = carnival_weights,
            corpus = corpus_weights
        ) %>%
        mutate(
            date = date_seq,
            year = year(date),
            month = month(date)
        ) %>%
        select(year, month, date, carnival, corpus)
    
    regs_df
}

# Function to join IBGE and regressors data and prepare for plotting
join_and_prepare <- function(ibge_ftp, regs_df) {
    ibge_long <- ibge_ftp %>%
        pivot_longer(
            cols = c(carnival, corpus),
            names_to = "holiday",
            values_to = "ibge_weight"
        ) %>%
        select(date, year, month, holiday, ibge_weight)
    
    regs_long <- regs_df %>%
        pivot_longer(
            cols = c(carnival, corpus),
            names_to = "holiday",
            values_to = "regs_weight"
        ) %>%
        select(date, year, month, holiday, regs_weight)
    
    combined_data <- full_join(ibge_long, regs_long, by = c("date", "year", "month", "holiday"))
    
    combined_long <- combined_data %>%
        pivot_longer(
            cols = c(ibge_weight, regs_weight),
            names_to = "source",
            values_to = "weight"
        ) %>%
        mutate(source = case_when(
            source == "ibge_weight" ~ "IBGE",
            source == "regs_weight" ~ "Calculated (regs)",
            TRUE ~ source
        ))
    
    combined_long
}

# Main function to execute the workflow with user-specified parameters
main <- function(carnival_range = c(-4, -1), corpus_range = c(1, 3), adjust_carnival_flag = TRUE) {
    holiday_summary <- get_holiday_data(adjust = adjust_carnival_flag)
    ibge_ftp <- get_ibge_data()
    regs_df <- prepare_regs(holiday_summary, carnival_range = carnival_range, corpus_range = corpus_range)
    combined_long <- join_and_prepare(ibge_ftp, regs_df)
    
    # Return the combined data for further analysis or plotting
    combined_long
}
