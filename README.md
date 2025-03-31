# PIM Seasonal Adjustment Shiny App

This Shiny application performs seasonal adjustments for Brazil's Industrial Production Index (PIM) using the X-13-SEATS seasonal adjustment methodology. It fetches official holiday data from Anbima and economic series data from IBGE to generate robust seasonal models.

## Project Structure

```
r-seas/
├── app.R                       # Main Shiny app file
├── r-seas.Rproj                # RStudio project file
├── LICENSE                     # License file
├── src/
│   ├── data/
│   │   ├── api/
│   │   │   └── ibge_pim.R      # API functions to fetch PIM data
│   │   ├── processing/
│   │   │   ├── anbima.R        # Processing Anbima holiday data
│   │   │   ├── ibge_ftp.R      # Processing IBGE FTP data
│   │   │   └── ibge_pim.R      # Processing IBGE PIM data
│   │   └── utils/
│   │       └── import_excel_data.R  # Utility for Excel data import
│   ├── dataframe/
│   │   ├── df_ftp.R            # Creating FTP dataframes
│   │   └── df_pim.R            # Creating PIM dataframes
│   ├── model/
│   │   ├── genhol.R            # Generates holiday regressors
│   │   └── seas.R              # Performs seasonal adjustment using X-13-SEATS
│   └── plot/
│       ├── plot_ftp.R          # FTP plotting functions
│       └── plot_pim.R          # PIM plotting functions
└── README.md                   # This file
```

## Requirements

Install the required R packages:

```r
install.packages(c("shiny", "here", "readxl", "dplyr", "tidyr", "seasonal", 
                  "httr", "jsonlite", "ggplot2", "lubridate"))
```

X-13-SEATS must also be installed:

```r
seasonal::checkX13()
```

## Running the App

Open `app.R` in RStudio and click "Run App" or execute:

```r
shiny::runApp("path/to/r-seas")
```

## Features

- Adjustable carnival and corpus holiday effect ranges
- Selectable ARIMA model structures
- Interactive date-range zooming on plots
- Holiday effects visualization
- Downloadable holiday effect plots
- Optional adjustment for specific carnival dates

## Customizing the Analysis

Modify input ranges or add additional regressors by updating:
- `src/model/genhol.R` for holiday effects
- `src/model/seas.R` for seasonal adjustment options
- `src/plot/plot_pim.R` and `src/plot/plot_ftp.R` for visualization options
- UI components in `app.R` to extend user interactions

## Maintainers

- Luis Fernando Pereira Azevedo (lfpazevedo@gmail.com)

---

Feel free to submit issues or pull requests for improvements!

