# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, tidyxl, readxl, here)
source(here::here("scripts", "R", "_common.R"))

# RI_6B1_childcare_places

# Getting data
RI_6B1_childcare_places_path <- here::here(
  "data",
  "raw",
  "6.B.1_childcare_places_06.26.xlsx"
)

RI_6B1_childcare_places_raw_tbl <- read_excel(
  RI_6B1_childcare_places_path,
  sheet = "childcare_places",
  skip = 3
) |>
  clean_names() |>
  rename(
    date = date,
    area = area,
    value = proportion
  ) |>
  mutate(
    # Clean area names to ensure filtering and recoding work reliably
    area = str_squish(area),
    area = recode(
      area,
      "West of England+" = "West of England"
    ),
    # Convert Excel date serial numbers into proper R dates
    date = as.Date(date, origin = "1899-12-30")
  )

glimpse(RI_6B1_childcare_places_raw_tbl)

# Use West of England only for this indicator chart
RI_6B1_childcare_places_plot_tbl <-
  RI_6B1_childcare_places_raw_tbl |>
  filter(area == "West of England")

View(RI_6B1_childcare_places_plot_tbl)

# Line chart
RI_6B1_childcare_places_plot <-
  RI_6B1_childcare_places_plot_tbl |>
  ggplot(aes(x = date, y = value)) +
  geom_line(linewidth = 1.2, colour = "#40A832") +
  geom_point(size = 3, colour = "#40A832") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Childcare places relative to population aged 0 to 4",
    subtitle = "West of England",
    x = "Year",
    y = "Proportion",
    caption = "Source: Ofsted and ONS"
  ) +
  theme_weca() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5)
  )

# View line chart
RI_6B1_childcare_places_plot

# Creating fact table
# This dataset already contains point-in-time dates, so the same date is used
# for period_start and period_end.
RI_6B1_childcare_places_fact_tbl <-
  RI_6B1_childcare_places_raw_tbl |>
  filter(area == "West of England") |>
  mutate(
    period_start = date,
    period_end = date
  ) |>
  select(
    period_start,
    period_end,
    value
  )

View(RI_6B1_childcare_places_fact_tbl)

# Save the fact file
RI_6B1_childcare_places_fact_tbl |>
  build_fact(
    indicator_id = "RI_6B1_childcare_places"
  ) |>
  save_fact()

View(RI_6B1_childcare_places_fact_tbl)
