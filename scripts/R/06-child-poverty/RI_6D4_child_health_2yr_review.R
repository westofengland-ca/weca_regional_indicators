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
    academic_year = timeperiod,
    timeperiod_sortable,
    count,
    denominator,
    value = value / 100
  ) |>
  filter(
    academic_year >= "2021/22"
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
  group_by(academic_year, timeperiod_sortable) |>
  summarise(
    count = sum(count, na.rm = TRUE), #ignore any missing values
    denominator = sum(denominator, na.rm = TRUE),
    value = count / denominator,
    .groups = "drop" #getting rid of the groups just incase for later (la and the time periods)
  ) |>
  mutate(
    area = "West of England"
  ) |>
  select(
    area,
    academic_year,
    timeperiod_sortable,
    count,
    denominator,
    value
  )

View(RI_6D4_child_health_2yr_review_woe_tbl)

# making the table of4 LAs + England + West of England
RI_6D4_child_health_2yr_review_plot_tbl <-
  bind_rows(
    RI_6D4_child_health_2yr_review_la_tbl,
    RI_6D4_child_health_2yr_review_woe_tbl
  ) |>
  arrange(timeperiod_sortable, area)

View(RI_6D4_child_health_2yr_review_plot_tbl)

# Bar chart: West of England -----
# Bar chart: West of England -----
RI_6D4_child_health_2yr_review_plot <-
  RI_6D4_child_health_2yr_review_woe_tbl |>
  ggplot(
    aes(
      x = academic_year,
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
    title = "Children achieving a good level of development at 2 to 2.5 year review",
    subtitle = "West of England",
    x = "Academic year",
    y = "Percentage",
    caption = "Source: Fingertips"
  ) +
  theme_ua() +
  theme(
    axis.title.y = element_text(
      angle = 0,vjust = 0.5
    ),
    
  )

#View
RI_6D4_child_health_2yr_review_plot

# Creating fact table ------------
RI_6D4_child_health_2yr_review_fact_tbl <-
  RI_6D4_child_health_2yr_review_woe_tbl |>
  mutate(
    start_year = readr::parse_number(academic_year),
    period_start = as.Date(glue("{start_year}-09-01")),
    period_end = as.Date(glue("{start_year + 1}-08-31"))
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
