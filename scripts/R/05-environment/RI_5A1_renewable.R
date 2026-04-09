# Load renewable energy data
# sites, generation and capacity by local authority
# totals plus photovoltaics and households for RI_5A2_domestic_renewable

# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, tidyxl, readxl, sf)
# connect to the POSTGIS database - imports a connection object "con" into the environment
source(here::here("scripts", "R", "db_connect.R"))
source(here::here("scripts", "R", "_common.R"))
# spreadsheet https://assets.publishing.service.gov.uk/media/68da76d2c487360cc70c9e9d/Renewable_electricity_by_local_authority_2014_-_2024.xlsx

RI_5A1_current_spreadsheet <- "Renewable_electricity_by_local_authority_2014_-_2024.xlsx"
period_years <- 10
# metadata
RI_5A1_contents <-
    xlsx_cells(
        here::here(
            "data",
            "raw",
            RI_5A1_current_spreadsheet
        ),
        sheets = "Cover sheet"
    )

# get the start and end year from the contents sheet
RI_5A1_get_year_range <- function(contents) {
    RI_5A1_contents %>%
        filter(address == "A1") %>%
        pull(character) %>%
        str_extract_all(pattern = "\\d{4}") %>%
        pluck(1) %>%
        map_int(~ as.integer(.x))
}

RI_5A1_year_range <- RI_5A1_get_year_range(RI_5A1_contents)

#'
#' @param year_range The start and end years in the spreadsheer
#' @param type The type of renewable energy metric
#' @return A character vector of names for the sheets of a type
#'
RI_5A1_get_sheet_names <- function(year_range, type = "generation") {
    if (type == "generation") {
        sheet_prefix <- "LA - Generation,"
    } else if (type == "capacity") {
        sheet_prefix <- "LA - Capacity,"
    } else if (type == "sites") {
        sheet_prefix <- "LA - Sites"
    } else {
        stop("Invalid type. Use 'generation', 'capacity' or 'sites'.")
    }

    year_vec <- as.character(seq.int(year_range[1], year_range[2]))

    paste(sheet_prefix, year_vec)
}

# extract the relevant columns from the sheet - for this function its just totals, year and LA data
RI_5A1_get_sheet <- function(
    sheet_name,
    path = here::here(
        "data",
        "raw",
        RI_5A1_current_spreadsheet
    )
) {
    year <- str_extract(sheet_name, "\\d{4}") |> as.integer()
    # the ranges start at different rows!
    if (str_detect(sheet_name, "eneration")) {
        range = "A5:R500"
    } else {
        range = "A4:R500"
    }

    read_xlsx(
        path = path,
        sheet = sheet_name,
        range = range
    ) |>
        clean_names() |>
        mutate(year = year) |>
        filter(
            !is.na(local_authority_code_note_1),
            !str_detect(local_authority_code_note_1, pattern = "Grand"),
            str_starts(local_authority_code_note_1, pattern = "E")
        ) |>
        select(
            la_code = local_authority_code_note_1,
            la_name = 2, # the la name column header varies!
            year,
            total
        )
}

# get the PV and households columns along with year and LA data
RI_5A1_get_household_pv_sheet <- function(
    sheet_name,
    path = here::here(
        "data",
        "raw",
        RI_5A1_current_spreadsheet
    )
) {
    year <- str_extract(sheet_name, "\\d{4}") |> as.integer()
    # the ranges start at different rows!
    range = "A4:R500"

    read_xlsx(
        path = path,
        sheet = sheet_name,
        range = range
    ) |>
        clean_names() |>
        mutate(year = year) |>
        filter(
            !is.na(local_authority_code_note_1),
            !str_detect(local_authority_code_note_1, pattern = "Grand"),
            str_starts(local_authority_code_note_1, pattern = "E")
        ) |>
        select(
            la_code = local_authority_code_note_1,
            la_name = 2, # the la name column header varies!
            households = 5,
            year,
            photovoltaics_sites = photovoltaics
        ) |>
        mutate(households = as.integer(households))
}


# consolidate the PV and household data from the sites sheets for RI_5A2_domestic_renewable
RI_5A1_compile_household_pv_sheets <- function(RI_5A1_contents) {
    RI_5A1_contents %>%
        RI_5A1_get_year_range() |>
        RI_5A1_get_sheet_names(type = "sites") |>
        map(
            ~ RI_5A1_get_household_pv_sheet(
                .x,
                path = here::here(
                    "data",
                    "raw",
                    RI_5A1_current_spreadsheet
                )
            )
        ) |>
        bind_rows()
}


RI_5A1_compile_sheets <- function(RI_5A1_contents, type = "generation") {
    # capture the units for the respective columns for onward transparency
    ren_total <- function(type) {
        case_when(
            type == "generation" ~ "generation_mwh",
            type == "capacity" ~ "capacity_mw",
            type == "sites" ~ "sites"
        )
    }
    RI_5A1_contents %>%
        RI_5A1_get_year_range() |>
        RI_5A1_get_sheet_names(type = type) |>
        map(
            ~ RI_5A1_get_sheet(
                .x,
                path = here::here(
                    "data",
                    "raw",
                    RI_5A1_current_spreadsheet
                )
            )
        ) |>
        bind_rows() |>
        rename_with(.fn = ~ ren_total(type), .cols = total)
}

RI_5A1_sites_pv_tbl <- RI_5A1_compile_household_pv_sheets(RI_5A1_contents)
RI_5A1_generation_tbl <- RI_5A1_compile_sheets(contents, type = "generation")
RI_5A1_capacity_tbl <- RI_5A1_compile_sheets(contents, type = "capacity")
RI_5A1_sites_tbl <- RI_5A1_compile_sheets(contents, type = "sites")

# create a single table for all LA's of generation, capacity, households, sites and PV sites
RI_5A1_renewable_tbl <- reduce(
    list(
        RI_5A1_generation_tbl,
        RI_5A1_capacity_tbl,
        RI_5A1_sites_tbl,
        RI_5A1_sites_pv_tbl
    ),
    .f = inner_join
) |>
    mutate(
        la_name = if_else(str_starts(la_name, "Bristol"), "Bristol", la_name)
    )

# filter for weca UA's
RI_5A1_weca_renewable_tbl <- RI_5A1_renewable_tbl |>
    filter(
        la_code %in% c("E06000022", "E06000023", "E06000024", "E06000025"),
        year >= (max(year) - period_years + 1)
    )

# Get the area in KM^2 for the RI_5A2_domestic_renewable indicator

lep_area_km2 <- as.integer(
    (st_read(con, query = "SELECT * FROM os.bdline_ua_lep_diss") |>
        st_area(lep_bound)) /
        (1e6)
)

dbDisconnect(con)

# Make the plot for  RI_5A1
RI_5A1_renewable_plot <- RI_5A1_weca_renewable_tbl |>
    ggplot(aes(x = year, y = capacity_mw, fill = la_name)) +
    geom_col() +
    scale_fill_manual(values = ua_colors_by_name) +
    labs(
        title = "Renewable Electricity: Installed Capacity",
        subtitle = "All sources: Megawatts",
        y = "MW",
        x = "Year",
        fill = "Local authority",
        caption = "Source: DESNZ"
    ) +
    theme_ua() +
    guides(fill = guide_legend(ncol = 2)) +
    theme(axis.title.y = element_text(angle = 0, vjust = 0.5))

RI_5A1_renewable_plot

RI_5A1_fact_tbl <- RI_5A1_weca_renewable_tbl |>
    group_by(year) |>
    summarise(
        installed_capacity_mw = sum(capacity_mw),
        .groups = "drop"
    ) |>
    transmute(
        period_start = dmy(glue::glue("01-01-{year}")),
        period_end = dmy(glue::glue("31-12-{year}")),
        value = installed_capacity_mw / lep_area_km2
    )

RI_5A1_fact_tbl |>
    build_fact("RI_5A1_renewable_capacity_km2") |>
    save_fact()

# We also process RI_5A2_domestic_renewable here as it
# is sourced from the same data

RI_5A2_domestic_renewable_plot <- RI_5A1_weca_renewable_tbl |>
    ggplot(aes(x = year, y = photovoltaics_sites, fill = la_name)) +
    geom_col() +
    scale_fill_manual(values = ua_colors_by_name) +
    labs(
        title = "Photovoltaic (PV) sites",
        y = "Count",
        x = "Year",
        fill = "Local authority",
        caption = "Source: DESNZ"
    ) +
    theme_ua() +
    guides(fill = guide_legend(ncol = 2)) +
    theme(axis.title.y = element_text(angle = 0, vjust = 0.5))

RI_5A2_domestic_renewable_fact_tbl <-
    RI_5A1_weca_renewable_tbl |>
    group_by(year) |>
    summarise(
        pv_sites = sum(photovoltaics_sites),
        households = sum(households),
        .groups = "drop"
    ) |>
    transmute(
        period_start = dmy(glue::glue("01-01-{year}")),
        period_end = dmy(glue::glue("31-12-{year}")),
        value = pv_sites / households
    )

RI_5A2_domestic_renewable_fact_tbl |>
    build_fact("RI_5A2_domestic_renewable") |>
    save_fact()
