# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, tidyxl, readxl, here)
source(here::here("scripts", "R", "_common.R"))

# RI_4A3_apprenticeship_starts

#Getting data
RI_4A3_apprenticeship_starts_path <- here::here (
  "data",
  "raw",
  "4.A.3-data_apprenticeships_starts_05.26.xlsx"
)

RI_4A3_apprenticeship_starts_raw_tbl <- read_excel(
  RI_4A3_apprenticeship_starts_path,
  sheet = "app_starts(RI)",
  skip = 2
) |>
  rename(area = 1) |>
  mutate(
    area = str_squish(area),
    area = recode(
      area,
      "Bristol, City of" = "Bristol"
    )
  ) |> 
  glimpse()

#Turning year columns into rows
RI_4A3_apprenticeship_starts_long_tbl <-
  RI_4A3_apprenticeship_starts_raw_tbl |>
  pivot_longer(
    cols = -area,
    names_to = "academic_year",
    values_to = "value"
  ) |>
  glimpse()

# Filtering the local authorities & dates for the stacked chart
RI_4A3_apprenticeship_starts_plot_tbl <-
  RI_4A3_apprenticeship_starts_long_tbl |>
  filter(
    academic_year >= "2015/16"
  ) |>
  filter(
    area %in% c(
      "Bath and North East Somerset",
      "Bristol",
      "North Somerset",
      "South Gloucestershire"
    )
  )
View(RI_4A3_apprenticeship_starts_plot_tbl)

#stacked bar chart 
RI_4A3_apprenticeship_starts_plot <-
  RI_4A3_apprenticeship_starts_plot_tbl |>
  ggplot(aes(x = academic_year, y = value, fill = area)) +
  geom_col() + 
  scale_fill_manual(values = ua_colors_by_name) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Apprenticeship starts",
    subtitle = "West of England",
    x = "Academic year",
    y = "Number\nof starts",
    fill = NULL,
    caption = "Source: Department for Education"
  ) +
  theme_ua() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

#View stacked bar chart
RI_4A3_apprenticeship_starts_plot

#creating fact table 
RI_4A3_apprenticeship_starts_fact_tbl <-
  RI_4A3_apprenticeship_starts_long_tbl |>
  filter(area == "West of England LEP")
View(RI_4A3_apprenticeship_starts_fact_tbl)
glimpse(RI_4A3_apprenticeship_starts_long_tbl)


RI_4A3_apprenticeship_starts_fact_tbl <-
  RI_4A3_apprenticeship_starts_fact_tbl |>
  mutate(
    start_year = readr::parse_number(academic_year),
    period_start = as.Date(glue("{start_year}-08-01")),
    period_end = as.Date(glue("{start_year + 1}-07-31"))
  ) |>
  filter(period_start >= as.Date("2014-01-01")) |>
  select(
    period_start,
    period_end,
    value
  )
View(RI_4A3_apprenticeship_starts_fact_tbl) 
glimpse(RI_4A3_apprenticeship_starts_fact_tbl)

#Save the fact file
RI_4A3_apprenticeship_starts_fact_tbl |>
  build_fact(
    indicator_id = "RI_4A3_apprenticeship_starts"
  ) |>
  save_fact()

View(RI_4A3_apprenticeship_starts_fact_tbl)
