# FACT table helpers for WECA regional indicators ----------------------------
#
# Provides the two functions analysts need to contribute observation data to
# the shared FACT table:
#
#   1. build_fact() - validates and standardises your indicator's rows
#   2. save_fact()  - writes them to data/fact/{indicator_id}.csv
#
# The helpers enforce the agreed schema so individual indicator scripts
# cannot drift, and so the collation step at report-render time can simply
# bind every file in data/fact/ without guessing column names or types.
#
# =============================================================================
# ANALYST WORKFLOW
# =============================================================================
#
# Step 1. Do your usual data wrangling. End with a tibble that has **exactly**
#         these three columns:
#
#             period_start   (Date)    first day of the reporting period
#             period_end     (Date)    last day of the reporting period
#             value          (numeric) the indicator value for that period
#
#         Any other columns will cause build_fact() to error - this is
#         deliberate, to catch "I forgot to summarise" mistakes.
#
# Step 2. Source this file and call build_fact(), passing your tibble and
#         the indicator_id:
#
#             source(here::here("scripts", "R", "fact_helpers.R"))
#
#             fact_tbl <- my_wrangled_tbl |>
#               build_fact(indicator_id = "RI_5_ghg_emissions")
#
# Step 3. Write it to disc:
#
#             save_fact(fact_tbl)
#
# That's it. The file lands at data/fact/RI_5_ghg_emissions.csv and is
# picked up automatically by collate_fact() when the report renders.
#
# =============================================================================
# WORKED EXAMPLE (adapted from RI_5_ghg_emissions.r)
# =============================================================================
#
#   library(tidyverse)
#   library(lubridate)
#   source(here::here("scripts", "R", "fact_helpers.R"))
#
#   # 1. Wrangle your data however you like - here we aggregate by year.
#   emissions_tbl <- RI_5_kpi_sector_emissions_weca_tbl |>
#     group_by(year) |>
#     summarise(value = sum(territorial_emissions_kt_co2e, na.rm = TRUE)) |>
#     # 2. Shape the tibble to the required three columns.
#     transmute(
#       period_start = ymd(paste0(year, "-01-01")),
#       period_end   = ymd(paste0(year, "-12-31")),
#       value        = value
#     )
#
#   # 3. Hand it to build_fact() with your indicator_id.
#   fact_tbl <- build_fact(emissions_tbl, indicator_id = "RI_5_ghg_emissions")
#
#   # 4. Save it.
#   save_fact(fact_tbl)
#
# =============================================================================

#' Build FACT rows for a single indicator
#'
#' Takes a tibble of observations and returns a validated tibble matching the
#' FACT table schema, ready to hand to `save_fact()`. This is the **only**
#' function analysts should use to produce FACT rows - it guarantees the
#' schema, types, and uniqueness rules the collation step relies on.
#'
#' @param data A data frame / tibble containing **exactly** these columns:
#'   \itemize{
#'     \item `period_start` - Date (or something coercible to Date). First day
#'       of the reporting period. For a calendar year, use `YYYY-01-01`.
#'     \item `period_end` - Date (or coercible). Last day of the reporting
#'       period. For a calendar year, use `YYYY-12-31`.
#'     \item `value` - Numeric. The indicator value for that period.
#'   }
#'   Extra columns are rejected to catch "I forgot to summarise" mistakes.
#'   There must be exactly one row per reporting period.
#'
#' @param indicator_id Character scalar, e.g. `"RI_5_ghg_emissions"`. Must
#'   match the id used in the indicator DIM table and will become the
#'   filename when you call `save_fact()`.
#'
#' @return A tibble with columns `indicator_id`, `period_start`, `period_end`,
#'   `value`, `last_updated`, sorted by `period_end` ascending. Tagged with
#'   class `weca_fact` so `save_fact()` can recognise it.
#'
#' @section Validation rules:
#'   \itemize{
#'     \item `indicator_id` must be a single non-empty string.
#'     \item `data` must have exactly the three required columns, no more.
#'     \item `data` must have at least one row.
#'     \item `period_start` and `period_end` must coerce to Date without NAs.
#'     \item `period_start <= period_end` for every row.
#'     \item `value` must be numeric (NAs allowed - a genuinely missing
#'       observation is different from a broken pipeline).
#'     \item No two rows may share the same `period_end`.
#'   }
#'
#' @examples
#' \dontrun{
#' my_tbl <- tibble::tibble(
#'   period_start = as.Date(c("2023-01-01", "2024-01-01")),
#'   period_end   = as.Date(c("2023-12-31", "2024-12-31")),
#'   value        = c(1234.5, 1301.2)
#' )
#' fact_tbl <- build_fact(my_tbl, indicator_id = "RI_5_ghg_emissions")
#' }
build_fact <- function(data, indicator_id) {
  # --- indicator_id --------------------------------------------------------
  if (!is.character(indicator_id) || length(indicator_id) != 1L) {
    stop("`indicator_id` must be a single character string.", call. = FALSE)
  }
  if (is.na(indicator_id) || !nzchar(indicator_id)) {
    stop("`indicator_id` must not be empty or NA.", call. = FALSE)
  }

  # --- data shape ----------------------------------------------------------
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }
  required_cols <- c("period_start", "period_end", "value")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0L) {
    stop(
      "`data` is missing required column(s): ",
      paste(missing_cols, collapse = ", "),
      ". Required columns are: period_start, period_end, value.",
      call. = FALSE
    )
  }
  extra_cols <- setdiff(names(data), required_cols)
  if (length(extra_cols) > 0L) {
    stop(
      "`data` has unexpected column(s): ",
      paste(extra_cols, collapse = ", "),
      ". Please select/transmute down to exactly: period_start, period_end, value.",
      call. = FALSE
    )
  }
  if (nrow(data) == 0L) {
    stop("`data` has zero rows - nothing to record.", call. = FALSE)
  }

  # --- type coercion and value checks --------------------------------------
  if (!is.numeric(data$value)) {
    stop("`value` must be numeric.", call. = FALSE)
  }

  ps <- tryCatch(
    as.Date(data$period_start),
    error = function(e) {
      stop("`period_start` could not be coerced to Date: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
  pe <- tryCatch(
    as.Date(data$period_end),
    error = function(e) {
      stop("`period_end` could not be coerced to Date: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  if (any(is.na(ps)) || any(is.na(pe))) {
    stop(
      "`period_start` and `period_end` must not contain NA after coercion to Date.",
      call. = FALSE
    )
  }
  if (any(ps > pe)) {
    stop("`period_start` must be <= `period_end` for every row.", call. = FALSE)
  }

  # --- assemble ------------------------------------------------------------
  out <- tibble::tibble(
    indicator_id = indicator_id,
    period_start = ps,
    period_end   = pe,
    value        = as.numeric(data$value),
    last_updated = Sys.Date()
  )

  # --- uniqueness of period_end -------------------------------------------
  dups <- out |>
    dplyr::count(indicator_id, period_end) |>
    dplyr::filter(n > 1L)
  if (nrow(dups) > 0L) {
    bad_periods <- paste(format(dups$period_end), collapse = ", ")
    stop(
      "Duplicate period_end value(s) for '", indicator_id, "': ", bad_periods,
      ". Each indicator must have exactly one value per period - ",
      "check your group_by() / summarise() step.",
      call. = FALSE
    )
  }

  out <- dplyr::arrange(out, period_end)
  class(out) <- c("weca_fact", class(out))
  out
}

#' Write a FACT tibble to data/fact/{indicator_id}.csv
#'
#' One file per indicator keeps analysts out of each other's way - no merge
#' conflicts on a shared file. The collation step (`collate_fact()`, run at
#' report-render time) globs `data/fact/*.csv` and binds them all.
#'
#' Always call `build_fact()` first: `save_fact()` will refuse input that
#' wasn't produced by it, to prevent ad-hoc tibbles from polluting the
#' shared table.
#'
#' @param fact_tbl A tibble produced by `build_fact()`.
#' @param dir      Directory to write to. Defaults to `data/fact/` at the
#'   repository root (resolved via `here::here()`). You should not normally
#'   need to change this.
#'
#' @return The file path written, invisibly.
#'
#' @examples
#' \dontrun{
#' fact_tbl <- build_fact(my_tbl, indicator_id = "RI_5_ghg_emissions")
#' save_fact(fact_tbl)
#' # -> writes data/fact/RI_5_ghg_emissions.csv
#' }
save_fact <- function(fact_tbl, dir = here::here("data", "fact")) {
  if (!inherits(fact_tbl, "weca_fact")) {
    stop(
      "`fact_tbl` must be created with build_fact(). ",
      "Do not hand-craft the tibble - use the helper so the schema is validated.",
      call. = FALSE
    )
  }

  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  indicator_id <- unique(fact_tbl$indicator_id)
  path <- file.path(dir, paste0(indicator_id, ".csv"))

  # Strip the weca_fact class before writing so readers get a plain tibble.
  to_write <- fact_tbl
  class(to_write) <- setdiff(class(to_write), "weca_fact")

  readr::write_csv(to_write, path)
  message("Wrote ", nrow(to_write), " rows to ", path)
  invisible(path)
}
