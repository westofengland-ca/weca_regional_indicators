# Collate per-indicator FACT files into the master FACT table ---------------
#
# Each analyst writes their indicator's rows to data/fact/{indicator_id}.csv
# via `save_fact()` (see fact_helpers.R). This script binds them into a
# single FACT table and derives a reporting view suitable for summary tables
# with % change and sparklines.
#
# Usage:
#
#   source(here::here("scripts", "R", "collate_fact.R"))
#   fact_tbl     <- collate_fact()
#   reporting_df <- build_reporting_view(fact_tbl)
#
# `collate_fact()` is the single source of truth: observation_id is generated
# here as a surrogate key, not by analysts.

#' Read and bind every per-indicator FACT file
#'
#' Globs `data/fact/*.csv`, binds them, validates the combined schema, and
#' generates `observation_id` as a stable surrogate key (indicator_id +
#' period_end hash-free: just row_number() after a deterministic sort).
#'
#' @param dir Directory containing per-indicator FACT CSVs. Defaults to
#'   data/fact/ at the repository root.
#'
#' @return A tibble with columns: observation_id, indicator_id, period_start,
#'   period_end, value, last_updated. Ordered by indicator_id, period_end.
collate_fact <- function(dir = here::here("data", "fact")) {
  if (!dir.exists(dir)) {
    stop("FACT directory does not exist: ", dir, call. = FALSE)
  }

  files <- list.files(dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(files) == 0L) {
    stop("No FACT CSV files found in ", dir, call. = FALSE)
  }

  # Force column types so a malformed file fails loudly rather than silently
  # coercing (e.g. a stray string in `value`).
  col_types <- readr::cols(
    indicator_id = readr::col_character(),
    period_start = readr::col_date(),
    period_end   = readr::col_date(),
    value        = readr::col_double(),
    last_updated = readr::col_date()
  )

  rows <- purrr::map(files, function(f) {
    tryCatch(
      readr::read_csv(f, col_types = col_types),
      error = function(e) {
        stop("Failed to read FACT file '", basename(f), "': ",
          conditionMessage(e),
          call. = FALSE
        )
      }
    )
  })

  combined <- dplyr::bind_rows(rows)

  # Re-check uniqueness across the whole set (per-file check already happened
  # at build_fact() time, but a duplicated indicator_id across two files
  # would slip through).
  dups <- combined |>
    dplyr::count(indicator_id, period_end) |>
    dplyr::filter(n > 1L)
  if (nrow(dups) > 0L) {
    offenders <- paste(unique(dups$indicator_id), collapse = ", ")
    stop(
      "Duplicate (indicator_id, period_end) rows across FACT files for: ",
      offenders,
      ". Each indicator must live in exactly one file.",
      call. = FALSE
    )
  }

  combined |>
    dplyr::arrange(indicator_id, period_end) |>
    dplyr::mutate(observation_id = dplyr::row_number(), .before = 1L)
}

#' Build a reporting view with latest value, previous value and sparkline
#'
#' One row per indicator, suitable for a summary table. Includes:
#'   - latest_value, latest_period_start, latest_period_end
#'   - previous_value, previous_period_start, previous_period_end
#'   - pct_change (latest vs previous)
#'   - first_value, first_period_end (for longer-run context)
#'   - pct_change_since_first
#'   - sparkline (list-column of all values, oldest to newest)
#'   - n_observations
#'
#' @param fact_tbl The tibble returned by `collate_fact()`.
#'
#' @return A tibble, one row per indicator_id.
build_reporting_view <- function(fact_tbl) {
  required <- c("indicator_id", "period_end", "value")
  missing_cols <- setdiff(required, names(fact_tbl))
  if (length(missing_cols) > 0L) {
    stop("fact_tbl is missing required columns: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  fact_tbl |>
    dplyr::arrange(indicator_id, period_end) |>
    dplyr::group_by(indicator_id) |>
    dplyr::summarise(
      n_observations = dplyr::n(),
      first_period_end = dplyr::first(period_end),
      first_value = dplyr::first(value),
      previous_period_end = dplyr::nth(period_end, -2L, default = as.Date(NA)),
      previous_value = dplyr::nth(value, -2L, default = NA_real_),
      previous_period_start = dplyr::nth(period_start, -2L, default = as.Date(NA)),
      latest_period_start = dplyr::last(period_start),
      latest_period_end = dplyr::last(period_end),
      latest_value = dplyr::last(value),
      sparkline = list(value),
      last_updated = max(last_updated, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      pct_change             = (latest_value / previous_value - 1) * 100,
      pct_change_since_first = (latest_value / first_value - 1) * 100
    )
}
