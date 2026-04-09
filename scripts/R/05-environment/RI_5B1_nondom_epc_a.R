pacman::p_load(arrow, tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "_common.R"))

RI_5B1_nondom_epc_a_url <-
  "https://opendata.westofengland-ca.gov.uk/api/explore/v2.1/catalog/datasets/epc_non_domestic_lep_ods/exports/csv/?lang=en&select=asset_rating_band%2C+lodgement_date%2C+certificate_number&timezone=Europe%2FLondon"

# RI_5B1_nondom_epc_a
RI_5B1_nondom_epc_a_path <- here::here(
  "data",
  "raw",
  "RI_5B1_nondom_epc_a.csv"
)


f_exists <- fs::file_exists(RI_5B1_nondom_epc_a_path)
f_modified_dttm <- fs::file_info(RI_5B1_nondom_epc_a_path)$modification_time
old_file <- difftime(Sys.time(), f_modified_dttm, units = "weeks") > 1

if ((f_exists && old_file) || !f_exists) {
  RI_5B1_nondom_epc_a_raw_tbl <- read_csv2(
    RI_5B1_nondom_epc_a_url
  )
  RI_5B1_nondom_epc_a_raw_tbl |> write_csv2(RI_5B1_nondom_epc_a_path)
  print(glue("Downloading csv file from {RI_5B1_nondom_epc_a_url}"))
} else if (f_exists && !old_file) {
  RI_5B1_nondom_epc_a_raw_tbl <- read_csv2(
    RI_5B1_nondom_epc_a_path
  )
  print(glue("using stored csv file from {f_modified_dttm}"))
}

max_date <- max(RI_5B1_nondom_epc_a_raw_tbl$lodgement_date)
start_date <- max_date - (years(10))

RI_5B1_nondom_epc_a_raw_tbl |>
  arrange(lodgement_date) |>
  mutate(is_a = if_else(asset_rating_band %in% c("A", "A+"), TRUE, FALSE)) |>
  group_by(ym = format(lodgement_date, "%Y-%m")) |>
  summarise(count_a = sum(is_a), cert_count = n(), .groups = "drop") |>
  mutate(
    prop_a = cumsum(count_a) / cumsum(cert_count),
    period_end = ym(ym) |> rollforward(),
    period_start = as.Date(glue("{ym}-01")),
    ym = NULL
  ) |>
  filter(period_start >= start_date) |>
  glimpse()
