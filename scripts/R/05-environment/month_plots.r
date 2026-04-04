pacman::p_load(tidyverse, glue, janitor, here, DBI, duckdb)

source(here::here("scripts", "r", "theme_weca.r"))

con <- dbConnect(
    duckdb::duckdb(),
    dbdir = "~/projects/epc-new/data/epc_new.duckdb"
)
dbListTables(con)

# energy ratings
tbl(con, "epc_domestic_lep_deduplicated_vw") |>
    distinct(current_energy_rating)

#' @param raw_tbl: deduplicated epc data for wecal lep from the DB
#' @param cat_vec: vector of EPC categories to include in the "in_cat" group
#' @param yr: minimum year to include in the analysis
#' @return a tibble with monthly proportions of properties in the specified EPC categories

vw <- "epc_domestic_lep_deduplicated_vw"

raw_tbl <- tbl(con, vw) |>
    collect()

get_monthly_epc_cat_prop <- function(
    raw_tbl,
    cat_vec = c("A", "B", "C"),
    yr = 2020
) {
    raw_tbl |>
        # filter(year(lodgement_datetime) >= yr) |>
        mutate(
            epc = if_else(
                current_energy_rating %in% cat_vec,
                "in_cat",
                "out_cat"
            )
        ) |>
        group_by(
            epc,
            month = floor_date(lodgement_datetime, "month")
        ) |>
        count(epc) |>
        arrange(month) |>
        pivot_wider(names_from = epc, values_from = n) |>
        ungroup() |>
        mutate(
            in_cat_zero = replace_na(in_cat, 0),
            out_cat_zero = replace_na(out_cat, 0),
            in_cat = NULL,
            out_cat = NULL
        ) |>
        mutate(
            prop_in_cat = cumsum(in_cat_zero) *
                100 /
                (cumsum(in_cat_zero) + cumsum(out_cat_zero)),
            in_cat_zero = NULL,
            out_cat_zero = NULL
        ) |>
        filter(month >= as.Date(glue("{yr}-01-01"))) |>
        glimpse()
}

epc_a_c_tbl <- get_monthly_epc_cat_prop(raw_tbl, cat_vec = c("A", "B", "C"))
epc_a_plus_tbl <- get_monthly_epc_cat_prop(raw_tbl, cat_vec = "A")

epc_a_plus_tbl |> view()

epc_a_plus_tbl %>%
    ggplot(aes(x = month, y = prop_in_cat)) +
    geom_line(linewidth = 2, color = get_weca_color("forest_green")) +
    labs(
        title = "Percentage of Properties with Energy Rating A to C",
        subtitle = "West of England including North Somerset",
        x = "Month",
        y = "%"
    ) +
    expand_limits(y = c(0, 100)) +
    theme_weca()

epc_a_c_tbl %>%
    ggplot(aes(x = month, y = prop_in_cat)) +
    geom_line(linewidth = 2, color = get_weca_color("claret")) +
    labs(
        title = "Percentage of Properties with Energy Rating A to C",
        subtitle = "West of England including North Somerset",
        x = "Month",
        y = "%"
    ) +
    expand_limits(y = c(0, 100)) +
    theme_weca()

test = 1
