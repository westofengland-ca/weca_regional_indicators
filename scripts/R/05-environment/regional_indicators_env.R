# Update the regional indicators for environment
# https://westofenglandca.sharepoint.com/sites/PolicyStrategy/Shared%20Documents/Analysis%20team/3b.%20Project%20&%20corporate%20impact/Regional%20indicators/2023/2024%20Regional%20indicators%20update.pptx?web=1


pacman::p_load(tidyverse, readxl, janitor, glue)

# Local CO2 emissions -----
# Total regional CO2 emissions	4,390.8 kilotonnes	2020	-12%	BEIS

if (file.exists("data/all_co2_emissions.rds")) {
  all_co2_tbl <- read_rds("data/all_co2_emissions.rds") |>
    clean_names()
} else {
  csv_path <- "https://assets.publishing.service.gov.uk/media/667ad86497ea0c79abfe4bfd/2005-2022-local-authority-ghg-emissions-csv-dataset.csv"

  all_co2_tbl <- read_csv(csv_path)

  write_rds(all_co2_tbl, "data/all_co2_emissions.rds")
}

weca_las <- c(
  "Bath and North East Somerset",
  "Bristol, City of",
  "South Gloucestershire",
  "Bristol, city of"
)

annual_emissions_tbl <- all_co2_tbl %>%
  filter(
    calendar_year >= 2019,
    local_authority %in% weca_las
  ) |>
  group_by(calendar_year) |>
  summarise(across(contains("emissions"), sum)) |>
  glimpse()

latest_year <- max(annual_emissions_tbl$calendar_year)

(latest_year_emissions <- annual_emissions_tbl %>%
  filter(calendar_year == latest_year) |>
  pull(territorial_emissions_kt_co2e))

# change in emissions
previous_year <- max(annual_emissions_tbl$calendar_year) - 1
previous_year_emissions <- annual_emissions_tbl %>%
  filter(calendar_year == previous_year) |>
  pull(territorial_emissions_kt_co2e) |>
  glimpse()

(change_in_emissions <- (latest_year_emissions - previous_year_emissions) / previous_year_emissions * 100)


# Sectoral Emissions ----
#
sector_emissions_tbl <- all_co2_tbl %>%
  filter(
    calendar_year == latest_year,
    local_authority %in% weca_las
  ) |>
  group_by(la_ghg_sector) |>
  summarise(sum_emissions_kt_co2e = sum(territorial_emissions_kt_co2e)) |>
  mutate(share_of_emissions = sum_emissions_kt_co2e / sum(sum_emissions_kt_co2e) * 100)

sector_emissions_tbl

(domestic <- sector_emissions_tbl %>%
  filter(la_ghg_sector == "Domestic") |>
  pull(share_of_emissions))

(transport <- sector_emissions_tbl %>%
  filter(la_ghg_sector == "Transport") |>
  pull(share_of_emissions))

(business_and_public <- 100 - (domestic + transport))

(sector_emissions <- c(
  "Domestic" = domestic,
  "Transport" = transport,
  "Business and public" = business_and_public
))

# Renewable Energy ----
#
file_path <- "data/Renewable_electricity_by_local_authority_2014_2022.xlsx"
energy_sheets <- readxl::excel_sheets(file_path)

recent_cap_sheets <- energy_sheets |>
  keep(~ str_detect(., "LA - Capacity, 202"))

read_filter_sheet <- function(sheet_name, weca_las, file_path) {
  readxl::read_xlsx(file_path, sheet = sheet_name, skip = 5) |>
    clean_names() |>
    rename_with(~ str_replace(., "_note.*", "")) |>
    filter(
      !str_detect(local_authority_code, "\\([A-Z]{2}\\)"),
      local_authority_name %in% weca_las
    ) |>
    mutate(sheet = sheet_name)
}

weca_energy_raw_tbl <- recent_cap_sheets |>
  map(~ read_filter_sheet(.x,
    weca_las = weca_las,
    file_path = file_path
  )) |>
  bind_rows()


weca_energy_tbl <- weca_energy_raw_tbl |>
  mutate(year = str_extract(sheet, "[0-9].*") |>
    as.integer()) |>
  group_by(year) |>
  summarise(total_gwh = sum(total)) |>
  glimpse()

re_max_year <- max(weca_energy_tbl$year)

(total_re_cap_latest_year <- weca_energy_tbl |>
  filter(year == re_max_year) |>
  pull(total_gwh))

(previous_year_re_cap <- weca_energy_tbl |>
  filter(year == re_max_year - 1) |>
  pull(total_gwh))

(percentage_change_re_cap <- (total_re_cap_latest_year - previous_year_re_cap) / previous_year_re_cap * 100)

# Electricity Consumption
#

consumption_file_path <- "data/Subnational_total_final_consumption_2005_2022.xlsx"

cons_last_year <- str_match_all(
  consumption_file_path,
  "([0-9]{4})"
) |>
  pluck(1, 2) |>
  as.integer()

cons_start_year <- cons_last_year - 2

consumption_sheets <- seq.int(cons_start_year,
  cons_last_year,
  by = 1
) |>
  as.character()


read_filter_consumption_sheet <- function(sheet, file_path, weca_las) {
  read_excel(file_path, sheet = sheet, skip = 5) |>
    clean_names() |>
    rename_with(~ str_remove(.x, "_note.*")) |>
    filter(local_authority %in% weca_las) |>
    select(local_authority, electricity_total) |>
    mutate(year = as.integer(sheet))
}

electricity_consumption_la_tbl <- consumption_sheets |>
  map(
    ~ read_filter_consumption_sheet(.x, file_path = consumption_file_path, weca_las = weca_las)
  ) |>
  bind_rows()

# convert the figures from Kilotonnes oil equivalent to GWh per the factor on the spreadsheet.
factor_ktoe_gwh <- 11.63

electricity_weca_tbl <- electricity_consumption_la_tbl |>
  group_by(year) |>
  summarise(elec_total_gwh = sum(electricity_total * factor_ktoe_gwh)) |>
  glimpse()


latest_year_consumption <- electricity_weca_tbl |>
  filter(year == cons_last_year) |>
  pull(elec_total_gwh)

(percentage_renewable_of_consumption <- ((total_re_cap_latest_year * 100) / latest_year_consumption) |>
  round(1))

(previous_year_consumption <- electricity_weca_tbl |>
  filter(year == cons_last_year - 1) |>
  pull(elec_total_gwh))

(previous_year_re_cap * 100) / previous_year_consumption


# Air quality ----
# Bristol
# https://open-data-bristol-bcc.hub.arcgis.com/datasets/925cadfd3a034df3beea8f0088a942d0_8/explore?showTable=true

no2_data_bristol_tbl <- read_csv("data/Air_quality_monitors_with_annual_mean_NO2_measurements.csv")


no2_data_bristol_tbl |>
  clean_names() |>
  select(location, ugm3_2021, ugm3_2022) |>
  summarise(
    exc2021 = sum(ugm3_2021 >= 40.0, na.rm = TRUE),
    exc2022 = sum(ugm3_2022 >= 40.0, na.rm = TRUE)
  )
# In Banes there is 1 site in 2022 non compliant with the NO2 annual mean objective
#
# https://beta.bathnes.gov.uk/nitrogen-dioxide-monitoring-data
# last sheet on the power BI report
#
# All sites compliant in S. glos in 2022
