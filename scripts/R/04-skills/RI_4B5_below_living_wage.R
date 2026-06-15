# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, tidyxl, readxl, here)
source(here::here("scripts", "R", "_common.R"))

# RI_4B5_below_living_wage

# Getting data
RI_4B5_below_living_wage_path <- here::here(
  "data",
  "raw",
  "4.B.5-living_wage_master_05.26.xlsx"
)

RI_4B5_below_living_wage_raw_tbl <- read_excel(
  RI_4B5_below_living_wage_path,
  sheet = "table_%_living_wage(RI)",
  skip = 2
) |>
  rename(area = 1) |>
  mutate(
    area = str_squish(area),
    area = recode(
      area,
      "Bristol, City of" = "Bristol",
      "West of England +" = "West of England"
    )
  )

glimpse(RI_4B5_below_living_wage_raw_tbl)

# Turning year columns into rows
RI_4B5_below_living_wage_long_tbl <-
  RI_4B5_below_living_wage_raw_tbl |>
  mutate(across(-area, as.character)) |>
  pivot_longer(
    cols = -area,
    names_to = "year",
    values_to = "value"
  ) |>
  mutate(
    year = as.integer(year),
    value = readr::parse_number(value)
  )

glimpse(RI_4B5_below_living_wage_long_tbl)

# Filtering West of England & dates for the bar chart
RI_4B5_below_living_wage_plot_tbl <-
  RI_4B5_below_living_wage_long_tbl |>
  filter(
    area == "West of England",
    year >= 2015
  )

View(RI_4B5_below_living_wage_plot_tbl)

# Bar chart
RI_4B5_below_living_wage_plot <-
  RI_4B5_below_living_wage_plot_tbl |>
  ggplot(aes(x = factor(year), y = value)) +
  geom_col(fill = "#40A832") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Employees earning below the Real Living Wage",
    subtitle = "West of England",
    x = "Year",
    y = "%",
    caption = "Source: ONS"
  ) +
  theme_weca() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5)
  )

# View bar chart
RI_4B5_below_living_wage_plot

# Creating fact table
RI_4B5_below_living_wage_fact_tbl <-
  RI_4B5_below_living_wage_long_tbl |>
  filter(
    area == "West of England",
    year >= 2015
  ) |>
  mutate(
    period_start = as.Date(glue("{year}-01-01")),
    period_end = as.Date(glue("{year}-12-31")), 
    value = value * 100
  ) |>
  select(
    period_start,
    period_end,
    value
  )

View(RI_4B5_below_living_wage_fact_tbl)

# Save the fact file
RI_4B5_below_living_wage_fact_tbl |>
  build_fact(
    indicator_id = "RI_4B5_below_living_wage"
  ) |>
  save_fact()

View(RI_4B5_below_living_wage_fact_tbl)
