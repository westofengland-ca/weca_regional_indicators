# Multi-indicator GT summary tables ------------------------------------------
#
# Two cross-indicator aggregate functions that complement the single-indicator
# card in reporting_table.R:
#
#   - format_priority_summary(): one row per indicator within a priority,
#     for the top of each chapter.
#   - format_overall_summary():  one row per indicator across the whole report,
#     for the landing page (index.qmd).
#
# Both join DIM data (from dim_data.R) to the reporting view produced by
# build_reporting_view() in collate_fact.R.
#
# Usage:
#
#   source(here::here("scripts", "R", "_common.R"))
#   rv  <- build_reporting_view(collate_fact())
#   format_priority_summary(rv, core_dim_data_tbl, priority = 5)
#   format_overall_summary(rv, core_dim_data_tbl)

#' Internal: format a change value as "+x.x%" or "+x.x ppt"
#'
#' Fully vectorised: operates on same-length `value` and `is_percent` vectors.
#' Returns "--" for NA values (no previous observation).
#'
#' @param value Numeric vector of change amounts.
#' @param is_percent Logical vector; TRUE for percentage indicators (ppt suffix).
#' @return Character vector.
#' @keywords internal
.fmt_change <- function(value, is_percent) {
  sign      <- dplyr::if_else(value >= 0, "+", "", missing = "")
  suffix    <- dplyr::if_else(is_percent, " ppt", "%")
  formatted <- paste0(sign, formatC(value, format = "f", digits = 1), suffix)
  dplyr::if_else(is.na(value), "--", formatted)
}

#' Per-chapter priority summary GT table
#'
#' One row per indicator within the given priority, showing the latest
#' observed value, its period, and units. Only indicators that have FACT
#' data are included (inner join on indicator_id).
#'
#' @param reporting_view A tibble produced by `build_reporting_view()`. Must
#'   contain `indicator_id`, `latest_period_start`, `latest_period_end`,
#'   `latest_value`.
#' @param dim_tbl The core DIM data tibble (e.g. `core_dim_data_tbl`).
#' @param priority Priority number (1-6) or character. Passed to
#'   `get_dim_priority()`.
#' @param title Optional gt table title.
#' @param subtitle Optional gt table subtitle.
#'
#' @return A `gt_tbl` object.
format_priority_summary <- function(reporting_view,
                                    dim_tbl,
                                    priority,
                                    title = NULL,
                                    subtitle = NULL) {
  if (!is.data.frame(reporting_view)) {
    stop("`reporting_view` must be a data frame produced by build_reporting_view().",
      call. = FALSE
    )
  }
  if (!is.data.frame(dim_tbl)) {
    stop("`dim_tbl` must be a data frame (e.g. core_dim_data_tbl).",
      call. = FALSE
    )
  }
  if (length(priority) != 1L || is.na(priority)) {
    stop("`priority` must be a single non-NA value.", call. = FALSE)
  }

  required_rv <- c("indicator_id", "latest_period_start", "latest_period_end", "latest_value")
  missing_rv  <- setdiff(required_rv, names(reporting_view))
  if (length(missing_rv) > 0L) {
    stop("`reporting_view` is missing columns: ", paste(missing_rv, collapse = ", "),
      call. = FALSE
    )
  }

  dim_priority <- get_dim_priority(dim_tbl, priority)

  tbl <- dplyr::inner_join(dim_priority, reporting_view, by = dplyr::join_by(indicator_id)) |>
    dplyr::mutate(
      period_start = format(latest_period_start),
      period_end   = format(latest_period_end)
    ) |>
    dplyr::select(
      indicator_summary,
      period_start,
      period_end,
      value = latest_value,
      units
    )

  if (nrow(tbl) == 0L) {
    stop("No indicators with FACT data found for priority ", priority, ".",
      call. = FALSE
    )
  }

  gt::gt(tbl) |>
    gt::tab_header(
      title    = title %||% paste0("Priority ", priority),
      subtitle = subtitle
    ) |>
    gt::cols_label(
      indicator_summary = "Indicator",
      period_start      = "From",
      period_end        = "To",
      value             = "Latest value",
      units             = "Units"
    ) |>
    gt::cols_align(align = "left",   columns = c("indicator_summary", "units")) |>
    gt::cols_align(align = "right",  columns = "value") |>
    gt::cols_align(align = "center", columns = c("period_start", "period_end")) |>
    gt::fmt_number(columns = "value", decimals = 1, use_seps = TRUE) |>
    gt::cols_width(indicator_summary ~ gt::px(360)) |>
    gt::tab_options(table.width = gt::pct(100))
}

#' Whole-report summary GT table for the landing page
#'
#' One row per indicator across all priorities that have FACT data, grouped
#' by priority. Includes a change column: percentage-point change for
#' percentage indicators (units == "%"), otherwise relative % change vs
#' previous observation. "--" where no previous observation exists.
#'
#' @param reporting_view A tibble produced by `build_reporting_view()`.
#' @param dim_tbl The core DIM data tibble (e.g. `core_dim_data_tbl`).
#' @param title Optional gt table title.
#' @param subtitle Optional gt table subtitle.
#'
#' @return A `gt_tbl` object.
format_overall_summary <- function(reporting_view,
                                   dim_tbl,
                                   title = NULL,
                                   subtitle = NULL) {
  if (!is.data.frame(reporting_view)) {
    stop("`reporting_view` must be a data frame produced by build_reporting_view().",
      call. = FALSE
    )
  }
  if (!is.data.frame(dim_tbl)) {
    stop("`dim_tbl` must be a data frame (e.g. core_dim_data_tbl).",
      call. = FALSE
    )
  }

  required_rv <- c(
    "indicator_id", "latest_period_start", "latest_period_end", "latest_value",
    "previous_value", "pct_change"
  )
  missing_rv <- setdiff(required_rv, names(reporting_view))
  if (length(missing_rv) > 0L) {
    stop("`reporting_view` is missing columns: ", paste(missing_rv, collapse = ", "),
      call. = FALSE
    )
  }

  dim_all <- get_dim_all(dim_tbl)

  tbl <- dplyr::inner_join(dim_all, reporting_view, by = dplyr::join_by(indicator_id)) |>
    dplyr::mutate(
      is_percent   = (units == "%"),
      change_raw   = dplyr::if_else(is_percent, latest_value - previous_value, pct_change),
      change       = .fmt_change(change_raw, is_percent),
      period_start = format(latest_period_start),
      period_end   = format(latest_period_end),
      priority     = paste0("Priority ", priority)
    ) |>
    dplyr::arrange(priority, indicator_id) |>
    dplyr::select(
      priority,
      indicator_summary,
      period_start,
      period_end,
      value = latest_value,
      units,
      change
    )

  if (nrow(tbl) == 0L) {
    stop("No indicators with FACT data found.", call. = FALSE)
  }

  gt::gt(tbl, groupname_col = "priority") |>
    gt::tab_header(
      title    = title %||% "Regional Priorities: All Indicators",
      subtitle = subtitle
    ) |>
    gt::cols_label(
      indicator_summary = "Indicator",
      period_start      = "From",
      period_end        = "To",
      value             = "Latest value",
      units             = "Units",
      change            = "Change"
    ) |>
    gt::cols_hide(columns = "priority") |>
    gt::cols_align(align = "left",   columns = c("indicator_summary", "units")) |>
    gt::cols_align(align = "right",  columns = c("value", "change")) |>
    gt::cols_align(align = "center", columns = c("period_start", "period_end")) |>
    gt::fmt_number(columns = "value", decimals = 1, use_seps = TRUE) |>
    gt::cols_width(indicator_summary ~ gt::px(360)) |>
    gt::tab_options(table.width = gt::pct(100))
}
