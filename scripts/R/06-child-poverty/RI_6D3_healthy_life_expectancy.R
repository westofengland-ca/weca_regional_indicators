# libraries ---------------------
pacman::p_load(tidyverse, janitor, glue, fingertipsR, here)
source(here::here("scripts", "R", "_common.R"))

# RI_6D3_healthy_life_expectancy
# Healthy life expectancy at birth

# Getting data 
RI_6D3_healthy_life_expectancy_raw_tbl <- fingertips_data(
  IndicatorID = 90362,
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

glimpse(RI_6D3_healthy_life_expectancy_raw_tbl)

# Clean and filter data 
RI_6D3_healthy_life_expectancy_plot_tbl <-
  RI_6D3_healthy_life_expectancy_raw_tbl |>
  filter(
    area_name %in% c(
      "Bath and North East Somerset",
      "Bristol",
      "North Somerset",
      "South Gloucestershire"
    ),
    sex %in% c("Male", "Female"),
    timeperiod_sortable >= 20150000
  ) |>
  transmute(
    area = area_name,
    sex,
    timeperiod,
    timeperiod_sortable,
    value,
    lower_ci95_0limit,
    upper_ci95_0limit
  ) |>
  arrange(sex, area, timeperiod_sortable)

View(RI_6D3_healthy_life_expectancy_plot_tbl)

# Male chart 
RI_6D3_healthy_life_expectancy_male_plot <-
  RI_6D3_healthy_life_expectancy_plot_tbl |>
  filter(
    sex == "Male"
  ) |>
  ggplot(
    aes(
      x = timeperiod,
      y = value,
      colour = area,
      group = area
    )
  ) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_colour_manual(
    values = ua_colors_by_name
  ) +
  scale_y_continuous(
    breaks = seq(60, 70, by = 2)
  ) +
  coord_cartesian(
    ylim = c(60, 70)
  ) +
  labs(
    title = "Male healthy life expectancy at birth",
    x = "Time period",
    y = "Years",
    colour = NULL,
    caption = "Source: Fingertips"
  ) +
  theme_ua() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  guides(
    colour = guide_legend(ncol = 2)
  )

RI_6D3_healthy_life_expectancy_male_plot

# Female chart
RI_6D3_healthy_life_expectancy_female_plot <-
  RI_6D3_healthy_life_expectancy_plot_tbl |>
  filter(
    sex == "Female"
  ) |>
  ggplot(
    aes(
      x = timeperiod,
      y = value,
      colour = area,
      group = area
    )
  ) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_colour_manual(
    values = ua_colors_by_name
  ) +
  scale_y_continuous(
    breaks = seq(60, 70, by = 2)
  ) +
  coord_cartesian(
    ylim = c(60, 70)
  ) +
  labs(
    title = "Female healthy life expectancy at birth",
    x = "Time period",
    y = "Years",
    colour = NULL,
    caption = "Source: Fingertips"
  ) +
  theme_ua() +
  theme(
    axis.title.y = element_text(angle = 0, vjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  guides(
    colour = guide_legend(ncol = 2)
  )

RI_6D3_healthy_life_expectancy_female_plot

# Male fact table ----------------
#RI_6D3_healthy_life_expectancy_male_fact_tbl <-
  #RI_6D3_healthy_life_expectancy_plot_tbl |>
 # filter(
  #  sex == "Male"
 # ) |>
 # transmute(
 #   area,
 #   period_start = as.Date(glue("{timeperiod_sortable %/% 10000}-01-01")),
 #   period_end = as.Date(glue("{(timeperiod_sortable %/% 10000) + 2}-12-31")),
 #   value
 # )

# View(RI_6D3_healthy_life_expectancy_male_fact_tbl)
# 
# # Save male fact file
# RI_6D3_healthy_life_expectancy_male_fact_tbl |>
#   build_fact(
#     indicator_id = "RI_6D3_healthy_life_expectancy_male"
#   ) |>
#   save_fact()
# 
# 
# # Female fact table --------------
# RI_6D3_healthy_life_expectancy_female_fact_tbl <-
#   RI_6D3_healthy_life_expectancy_plot_tbl |>
#   filter(
#     sex == "Female"
#   ) |>
#   transmute(
#     area,
#     period_start = as.Date(glue("{timeperiod_sortable %/% 10000}-01-01")),
#     period_end = as.Date(glue("{(timeperiod_sortable %/% 10000) + 2}-12-31")),
#     value
#   )
# 
# View(RI_6D3_healthy_life_expectancy_female_fact_tbl)
# 
# # Save female fact file
# RI_6D3_healthy_life_expectancy_female_fact_tbl |>
#   build_fact(
#     indicator_id = "RI_6D3_healthy_life_expectancy_female"
#   ) |>
#   save_fact()
