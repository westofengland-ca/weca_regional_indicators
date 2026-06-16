pacman::p_load(tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "_common.R"))

# RI_1E3_area_satisfaction

RI_1E3_raw_tbl<-read_csv(here::here("data", "raw", "community life", "community_life_time_series.csv"))

head(RI_1E3_raw_tbl)

#convert to date

RI_1E3_raw_tbl <- RI_1E3_raw_tbl %>%
  mutate(date = dmy(date))

#plot

RI_1E3_plot<- ggplot(RI_1E3_raw_tbl, aes(x=date))+
  geom_line(aes(y = percent_satisfied, color = area), linewidth = 1.25, na.rm = TRUE) +
  geom_point(aes(y = percent_satisfied, color = area), size = 2, na.rm = TRUE) +
  scale_color_manual(values = c(
    "Bath & North East Somerset" = "#590075",
    "Bristol" = "#CE132D",
    "North Somerset" = "#ED8073",
    "South Gloucestershire" = "#1D4F2B"
  )) +
  labs(title = "Satisfaction with local area as a place to live",
       subtitle = "Constituent authorities within the West of England region and North Somerset",
       y = "Percentage of respondents satisfied (%)",
       x = "Year",
       caption = "Source: Community Life Survey (Department for Culture, Media and Sport)")+
  theme_weca()+
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 11))+
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  )

RI_1E3_plot

#fact table

RI_1E3_fact_tbl <- RI_1E3_raw_tbl |>
  filter(area == "Bristol") |>
  transmute(
    period_start = as.Date(glue("{date}-01-01")),
    period_end = as.Date(glue("{date}-12-31")),
    value = percent_satisfied,
    date = NULL,
    percent_satisfied = NULL
  ) |>
  glimpse()

RI_1E3_fact_tbl |> 
  build_fact("RI_1E3_area_satisfaction") |> 
  save_fact()