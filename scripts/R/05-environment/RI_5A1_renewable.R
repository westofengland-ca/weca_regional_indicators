# Load renewable energy data
# sites, generation and capacity by local authority
# totals plus photovoltaics and households for RI_5A2_domestic_renewable

# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, tidyxl, readxl)

# spreadsheet https://assets.publishing.service.gov.uk/media/68da76d2c487360cc70c9e9d/Renewable_electricity_by_local_authority_2014_-_2024.xlsx

RI_5A1_current_spreadsheet <- "Renewable_electricity_by_local_authority_2014_-_2024.xlsx"

# metadata
RI_51A_contents <-
    xlsx_cells(
        here::here(
            "data",
            "raw",
            RI_5A1_current_spreadsheet
        ),
        sheets = "Cover sheet"
    )

# get the start and end year from the contents sheet
RI_51A_get_year_range <- function(contents) {
    RI_51A_contents %>%
        filter(address == "A1") %>%
        pull(character) %>%
        str_extract_all(pattern = "\\d{4}") %>%
        pluck(1) %>%
        map_int(~ as.integer(.x))
}

RI_51A_year_range <- RI_51A_get_year_range(RI_51A_contents)

#'
#' @param year_range The start and end years in the spreadsheer
#' @param type The type of renewable energy metric
#' @return A character vector of names for the sheets of a type
#'
RI_51A_get_sheet_names <- function(year_range, type = "generation") {
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
RI_51A_get_sheet <- function(
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
RI_51A_get_household_pv_sheet <- function(
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
RI_51A_compile_household_pv_sheets <- function(RI_51A_contents) {
    RI_51A_contents %>%
        RI_51A_get_year_range() |>
        RI_51A_get_sheet_names(type = "sites") |>
        map(
            ~ RI_51A_get_household_pv_sheet(
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


RI_51A_compile_sheets <- function(RI_51A_contents, type = "generation") {
    # capture the units for the respective columns for onward transparency
    ren_total <- function(type) {
        case_when(
            type == "generation" ~ "generation_mwh",
            type == "capacity" ~ "capacity_mw",
            type == "sites" ~ "sites"
        )
    }
    RI_51A_contents %>%
        RI_51A_get_year_range() |>
        RI_51A_get_sheet_names(type = type) |>
        map(
            ~ RI_51A_get_sheet(
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

RI_51A_sites_pv_tbl <- RI_51A_compile_household_pv_sheets(RI_51A_contents)
RI_51A_generation_tbl <- RI_51A_compile_sheets(contents, type = "generation")
RI_51A_capacity_tbl <- RI_51A_compile_sheets(contents, type = "capacity")
RI_51A_sites_tbl <- RI_51A_compile_sheets(contents, type = "sites")

# create a single table for all LA's of generation, capacity, households, sites and PV sites
RI_51A_renewable_tbl <- reduce(
    list(
        RI_51A_generation_tbl,
        RI_51A_capacity_tbl,
        RI_51A_sites_tbl,
        RI_51A_sites_pv_tbl
    ),
    .f = inner_join
)

# filter for weca UA's
RI_51A_weca_renewable_tbl <- RI_51A_renewable_tbl |>
    filter(
        la_code %in% c("E06000022", "E06000023", "E06000024", "E06000025")
    ) |>
    glimpse()
