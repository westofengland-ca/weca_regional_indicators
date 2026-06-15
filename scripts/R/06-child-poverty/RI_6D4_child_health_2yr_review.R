# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, fingertipsR, here)
source(here::here("scripts", "R", "_common.R"))

# RI_6D4_child_health_2yr_review
# Child health: Percentage achieving good level of development at 2-2.5 year review

# Getting data ------------------ (fingertips API)
RI_6D4_child_health_2yr_review_raw_tbl <- fingertips_data(
  IndicatorID = 93436,
  AreaTypeID = 502
) |>
  clean_names() |>
  mutate(
    area_name = str_squish(area_name),
    area_name = recode(
      area_name,
      "Bristol, City of" = "Bristol"
    )
  )

glimpse(RI_6D4_child_health_2yr_review_raw_tbl)

# Keep required areas -----------
RI_6D4_child_health_2yr_review_la_tbl <-
  RI_6D4_child_health_2yr_review_raw_tbl |>
  filter(
    area_name %in% c(
      "Bath and North East Somerset",
      "Bristol",
      "North Somerset",
      "South Gloucestershire",
      "England"
    )
  ) |>
  transmute(
    area = area_name,
    financial_year = timeperiod,
    timeperiod_sortable,
    count,
    denominator,
    value = value / 100
  ) |>
  filter(
    financial_year >= "2021/22"
  )

View(RI_6D4_child_health_2yr_review_la_tbl)

# Create West of England figure
# Use summed count / summed denominator.
RI_6D4_child_health_2yr_review_woe_tbl <-
  RI_6D4_child_health_2yr_review_la_tbl |>
  filter(
    area %in% c(
      "Bath and North East Somerset",
      "Bristol",
      "North Somerset",
      "South Gloucestershire"
    )
  ) |>
  group_by(financial_year, timeperiod_sortable) |>
  summarise(
    count = sum(count, na.rm = TRUE),
    denominator = sum(denominator, na.rm = TRUE),
    value = count / denominator,
    .groups = "drop"
  ) |>
  mutate(
    area = "West of England"
  ) |>
  select(
    area,
    financial_year,
    timeperiod_sortable,
    count,
    denominator,
    value
  )

View(RI_6D4_child_health_2yr_review_woe_tbl)

# Making the table of 4 LAs + England + West of England
RI_6D4_child_health_2yr_review_plot_tbl <-
  bind_rows(
    RI_6D4_child_health_2yr_review_la_tbl,
    RI_6D4_child_health_2yr_review_woe_tbl
  ) |>
  arrange(timeperiod_sortable, area)

View(RI_6D4_child_health_2yr_review_plot_tbl)

# Bar chart: West of England -----
RI_6D4_child_health_2yr_review_plot <-
  RI_6D4_child_health_2yr_review_woe_tbl |>
  ggplot(
    aes(
      x = financial_year,
      y = value
    )
  ) +
  geom_col(
    fill = "#40A832"
  ) +
  scale_y_continuous(
    labels = scales::percent,
    breaks = seq(0.70, 1.00, by = 0.05)
  ) +
  coord_cartesian(
    ylim = c(0.70, 1.00)
  ) +
  labs(
    title = "Children achieving a good level of development \nat 2 to 2.5 year review",
    subtitle = "West of England",
    x = "Financial year",
    y = "%",
    caption = "Source: Fingertips"
  ) +
  theme_ua() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5)
  )

# View
RI_6D4_child_health_2yr_review_plot

# Creating fact table ------------
RI_6D4_child_health_2yr_review_fact_tbl <-
  RI_6D4_child_health_2yr_review_woe_tbl |>
  mutate(
    start_year = readr::parse_number(financial_year),
    period_start = as.Date(glue("{start_year}-04-01")),
    period_end = as.Date(glue("{start_year + 1}-03-31")),
    value = value * 100
  ) |>
  select(
    period_start,
    period_end,
    value
  )

View(RI_6D4_child_health_2yr_review_fact_tbl)

# Save the fact file -------------
RI_6D4_child_health_2yr_review_fact_tbl |>
  build_fact(
    indicator_id = "RI_6D4_child_health_2yr_review"
  ) |>
  save_fact()
