# PIM Seasonal Adjustment Shiny App

This Shiny application performs seasonal adjustments for Brazil's Industrial Production Index (PIM) using the X-13-SEATS seasonal adjustment methodology. It fetches official holiday data from Anbima and economic series data from IBGE to generate robust seasonal models.

## Project Structure

```
C:/Projects/r-seas/
├── app.R                       # Main Shiny app file
├── src/
│   ├── data/
│   │   ├── api/
│   │   │   ├── anbima.R        # Functions to fetch holiday data
│   │   │   └── ibge.R          # Functions to fetch economic data
│   │   └── processing/
│   │       ├── anbima.R        # Processing Anbima data
│   │       └── ibge.R          # Processing IBGE data
│   └── model/
│       ├── dataframe.R         # Creates and processes the final dataframe
│       ├── genhol.R            # Generates holiday regressors
│       ├── seas.R              # Performs seasonal adjustment using X-13-SEATS
│       └── plot.R              # Plotting functions
└── README.md
```

## Requirements

Install the required R packages:

```r
install.packages(c("shiny", "here", "readxl", "dplyr", "tidyr", "seasonal", "httr", "jsonlite"))
```

X-13-SEATS must also be installed:

```r
seasonal::checkX13()
```

## Running the App

Open `app.R` in RStudio and click "Run App" or execute:

```r
shiny::runApp("app.R")
```

## Features

- Adjustable carnival and corpus holiday effect ranges
- Selectable ARIMA model structures
- Interactive date-range zooming on plots

## Customizing the Analysis

Modify input ranges or add additional regressors by updating:
- `src/model/genhol.R` for holiday effects.
- `src/model/seas.R` for seasonal adjustment options.
- UI components in `app.R` to extend user interactions.

## Maintainers

- Luis Fernando Pereira Azevedo (lfpazevedo@gmail.com)

---

Feel free to submit issues or pull requests for improvements!

