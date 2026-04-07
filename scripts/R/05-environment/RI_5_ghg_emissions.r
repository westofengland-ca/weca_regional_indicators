# load libraries and functions ------------------------------------------------
pacman::p_load(httr2, jsonlite, tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "theme_weca.R"))

# Get the data from the open data portal using httr2 and the ODS API --------------
base_url <- "https://opendata.westofengland-ca.gov.uk/api/explore/v2.1/catalog/datasets"
endpoint <- "records"
RI_5_indicator_id <- "RI_5_ghg_emissions"
# parameters
dataset_id <- "ca_la_ghg_emissions_sub_sector_ods_vw"
kpi_sectors <- c(
  "Transport",
  "Commercial",
  "Industry",
  "Public Sector",
  "Domestic"
)
cauthnm <- "West of England"

# get the last year in the dataset
resp_max_year <- httr2::request(base_url) |>
  httr2::req_url_path_append(dataset_id, endpoint) |>
  httr2::req_url_query(
    "select" = "max(calendar_year) AS YEAR",
    "limit" = 1
  ) |>
  httr2::req_perform()

RI_5_max_date <- resp_max_year |>
  httr2::resp_body_json() |>
  pluck("results", 1, "YEAR") |>
  strptime("%Y-%m-%dT%H:%M:%S")

RI_5_start_date <- (RI_5_max_date - lubridate::years(9)) |>
  strftime("%Y-%m-%dT%H:%M:%S")

# make the API call
resp <- httr2::request(base_url) |>
  httr2::req_url_path_append(dataset_id, endpoint) |>
  httr2::req_url_query(
    "select" = "sum(territorial_emissions_kt_co2e) AS territorial_emissions_kt_co2e",
    "where" = glue::glue(
      "calendar_year IN [date'{RI_5_start_date}'..date'{RI_5_max_date}'] AND cauthnm='{cauthnm}'"
    ),
    "group_by" = "la_ghg_sector AS sector,calendar_year",
    "limit" = 100
  ) %>%
  httr2::req_perform()

# process the response object to get the tbl
RI_5_sector_emissions_weca_tbl <- resp |>
  httr2::resp_body_json() |>
  pluck("results") |>
  bind_rows() |>
  mutate(
    year = calendar_year |> strptime("%Y") |> year(),
    calendar_year = NULL
  )

RI_5_kpi_sector_emissions_weca_tbl <- RI_5_sector_emissions_weca_tbl |>
  filter(sector %in% kpi_sectors)

sector_names <- RI_5_kpi_sector_emissions_weca_tbl |>
  distinct(sector) |>
  pull(sector)

sector_count <- length(sector_names)

fill_colors <-
  weca_colors[1:sector_count] |>
  set_names(sector_names)

RI_5_plot <- RI_5_kpi_sector_emissions_weca_tbl |>
  group_by(sector) |>
  ggplot() +
  geom_col(aes(
    x = year,
    y = territorial_emissions_kt_co2e,
    # group = sector,
    fill = sector
  )) +
  labs(
    title = "Greenhouse Gas Emissions by Sector",
    subtitle = "West of England Combined Authority",
    x = "Year",
    y = "Kt CO2e",
    fill = "Sector",
    caption = "Source DESNZ: Includes North Somerset"
  ) +
  scale_fill_manual(values = fill_colors) +
  theme_weca() +
  theme(axis.title.y = element_text(angle = 0, vjust = 0.5))

RI_5_plot

RI_5_kpi_base_data_tbl <- RI_5_kpi_sector_emissions_weca_tbl |>
  group_by(year) |>
  summarise(
    total_emissions_kpi_sectors = sum(
      territorial_emissions_kt_co2e,
      na.rm = TRUE
    )
  ) |>
  arrange(year)

RI_5_kpi_fact_tbl <- RI_5_kpi_base_data_tbl |>
  mutate(
    indicator_id = RI_5_indicator_id,
    period_start = dmy(glue::glue("01-01-{year}")),
    period_end = dmy(glue::glue("31-12-{year}")),
    value = total_emissions_kpi_sectors,
    last_updated = Sys.Date(),
    year = NULL,
    total_emissions_kpi_sectors = NULL
  )

RI_5_kpi_vector <- RI_5_kpi_fact_tbl |>
  filter(
    period_end == max(period_end) |
      period_end == min(period_end) |
      period_end == max(period_end) - lubridate::years(1)
  ) |>
  pull(value) |>
  set_names(c("first", "previous", "latest"))

RI_5_kpi <- RI_5_kpi_vector["latest"]

RI_5_latest_previous_change_pc <- (RI_5_kpi_vector[
  "latest"
] /
  RI_5_kpi_vector["previous"] -
  1) *
  100

RI_5_latest_first_change_pc <- (RI_5_kpi_vector[
  "latest"
] /
  RI_5_kpi_vector["first"] -
  1) *
  100
