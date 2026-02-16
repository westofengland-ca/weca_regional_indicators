# WECA Data Analysis Helper Functions
#
# Common utility functions for working with indicator data.
# Load this file at the start of your analysis scripts.
#
# Example:
#   source(here::here("scripts", "R", "helpers.R"))

# Establish project root anchor
here::i_am("scripts/R/helpers.R")

library(readr)

#' Load CSV File Safely
#'
#' Standard CSV loading with error handling and path validation.
#' Uses readr::read_csv() with sensible defaults for WECA data.
#'
#' @param file_path Path to CSV file (relative to project root or absolute)
#' @param ... Additional arguments passed to readr::read_csv()
#'
#' @return A tibble containing the CSV data
#'
#' @examples
#' # Load from data/raw directory
#' data <- load_csv("data/raw/indicator_data.csv")
#'
#'
#' @export
load_csv <- function(file_path, ...) {
  # Validate file exists
  if (!file.exists(file_path)) {
    stop(paste0(
      "File not found: ", file_path, "\n",
      "Current working directory: ", getwd(), "\n",
      "Tip: Use paths relative to the project root, e.g. 'data/raw/file.csv'."
    ))
  }

  # Check file extension
  if (!grepl("\\.csv$", file_path, ignore.case = TRUE)) {
    warning(paste0(
      "File does not have .csv extension: ", file_path, "\n",
      "Attempting to read anyway..."
    ))
  }

  # Load CSV with readr
  tryCatch(
    {
      data <- readr::read_csv(
        file_path,
        show_col_types = FALSE,  # Suppress column type messages
        ...
      )

      message(paste0(
        "✓ Loaded ", nrow(data), " rows and ",
        ncol(data), " columns from ", basename(file_path)
      ))

      return(data)
    },
    error = function(e) {
      stop(paste0(
        "Error loading CSV file: ", file_path, "\n",
        "Error message: ", e$message
      ))
    }
  )
}

#' Format Numbers for Display
#'
#' Consistent number formatting for indicators in tables and charts.
#' Handles large numbers, percentages, and currency values.
#'
#' @param x Numeric vector to format
#' @param type Format type: "number", "percent", "currency" (default: "number")
#' @param digits Number of decimal places (default: 0 for numbers, 1 for percent)
#' @param big_mark Character to use as thousands separator (default: ",")
#'
#' @return Character vector of formatted numbers
#'
#' @examples
#' format_number(1234567)                    # "1,234,567"
#' format_number(0.1234, type = "percent")   # "12.3%"
#' format_number(1234.56, type = "currency") # "£1,234.56"
#'
#' @export
format_number <- function(x, type = "number", digits = NULL, big_mark = ",") {
  # Set default digits based on type
  if (is.null(digits)) {
    digits <- switch(type,
      "number" = 0,
      "percent" = 1,
      "currency" = 2,
      0
    )
  }

  # Apply formatting based on type
  formatted <- switch(type,
    "number" = format(
      round(x, digits),
      big.mark = big_mark,
      scientific = FALSE,
      trim = TRUE
    ),
    "percent" = paste0(
      format(
        round(x * 100, digits),
        big.mark = big_mark,
        scientific = FALSE,
        trim = TRUE
      ),
      "%"
    ),
    "currency" = paste0(
      "£",
      format(
        round(x, digits),
        big.mark = big_mark,
        scientific = FALSE,
        trim = TRUE,
        nsmall = digits
      )
    ),
    # Default to number format
    format(
      round(x, digits),
      big.mark = big_mark,
      scientific = FALSE,
      trim = TRUE
    )
  )

  return(formatted)
}

#' Calculate Percentage Change
#'
#' Calculate percentage change between two values.
#' Useful for year-on-year indicator comparisons.
#'
#' @param new_value The new/current value
#' @param old_value The old/baseline value
#' @param as_decimal If TRUE, returns decimal (0.1 for 10%); if FALSE, returns percentage (10)
#'
#' @return Numeric percentage change
#'
#' @examples
#' pct_change(110, 100)              # 10 (10% increase)
#' pct_change(90, 100, as_decimal = TRUE)  # -0.1 (10% decrease)
#'
#' @export
pct_change <- function(new_value, old_value, as_decimal = FALSE) {
  if (old_value == 0) {
    warning("Old value is zero - percentage change undefined. Returning NA.")
    return(NA)
  }

  change <- ((new_value - old_value) / old_value)

  if (as_decimal) {
    return(change)
  } else {
    return(change * 100)
  }
}

#' Create a Simple Summary Table
#'
#' Generate a formatted summary table for indicator data.
#' Useful for quick exploratory analysis.
#'
#' @param data Data frame to summarize
#' @param group_var Column name to group by (optional)
#' @param value_var Column name containing values to summarize
#'
#' @return A tibble with summary statistics
#'
#' @examples
#' summary_table(data, group_var = "area", value_var = "indicator_value")
#'
#' @export
summary_table <- function(data, group_var = NULL, value_var) {
  library(dplyr)

  if (is.null(group_var)) {
    # Overall summary
    summary <- data %>%
      summarise(
        Count = n(),
        Mean = mean(.data[[value_var]], na.rm = TRUE),
        Median = median(.data[[value_var]], na.rm = TRUE),
        Min = min(.data[[value_var]], na.rm = TRUE),
        Max = max(.data[[value_var]], na.rm = TRUE),
        SD = sd(.data[[value_var]], na.rm = TRUE)
      )
  } else {
    # Grouped summary
    summary <- data %>%
      group_by(.data[[group_var]]) %>%
      summarise(
        Count = n(),
        Mean = mean(.data[[value_var]], na.rm = TRUE),
        Median = median(.data[[value_var]], na.rm = TRUE),
        Min = min(.data[[value_var]], na.rm = TRUE),
        Max = max(.data[[value_var]], na.rm = TRUE),
        SD = sd(.data[[value_var]], na.rm = TRUE),
        .groups = "drop"
      )
  }

  return(summary)
}

#' Safe Division
#'
#' Perform division with handling for division by zero.
#' Returns NA for division by zero instead of Inf or NaN.
#'
#' @param numerator Numeric vector
#' @param denominator Numeric vector
#'
#' @return Numeric vector of results (NA where denominator is zero)
#'
#' @examples
#' safe_divide(100, 10)   # 10
#' safe_divide(100, 0)    # NA
#'
#' @export
safe_divide <- function(numerator, denominator) {
  result <- ifelse(denominator == 0, NA, numerator / denominator)
  return(result)
}

#' Check for Missing Data
#'
#' Quick diagnostic for missing values in a data frame.
#' Prints a summary of missing data by column.
#'
#' @param data Data frame to check
#' @param threshold Minimum percentage of missing data to report (default: 0)
#'
#' @return Invisibly returns a tibble with missing data summary
#'
#' @examples
#' check_missing(data)
#' check_missing(data, threshold = 5)  # Only show columns with >5% missing
#'
#' @export
check_missing <- function(data, threshold = 0) {
  library(dplyr)

  missing_summary <- data.frame(
    column = names(data),
    n_missing = sapply(data, function(x) sum(is.na(x))),
    pct_missing = sapply(data, function(x) round(sum(is.na(x)) / length(x) * 100, 1))
  ) %>%
    filter(pct_missing >= threshold) %>%
    arrange(desc(pct_missing))

  if (nrow(missing_summary) == 0) {
    message("✓ No missing data found (or none above threshold)")
  } else {
    message(paste0(
      "Missing data found in ", nrow(missing_summary), " column(s):"
    ))
    print(missing_summary, row.names = FALSE)
  }

  invisible(missing_summary)
}
