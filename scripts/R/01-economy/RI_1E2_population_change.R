pacman::p_load(tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "_common.R"))

# RI_1E2_population_change

RI_1E2_raw_tbl<-read_csv(here::here("data", "raw", "pop_change_long_summary.csv"))

head(RI_1E2_raw_tbl)

#convert to date

RI_1E2_raw_tbl <- RI_1E2_raw_tbl %>%
  mutate(Date = dmy(Date))

#plot

RI_1E2_plot<- ggplot(RI_1E2_raw_tbl, aes(x=Date))+
  geom_line(aes(y = cumulative_percentage_change, color = Area), linewidth = 1.25, na.rm = TRUE) +
  scale_color_manual(values = c(
    "Bath & North East Somerset" = "#590075",
    "Bristol" = "#CE132D",
    "North Somerset" = "#ED8073",
    "South Gloucestershire" = "#1D4F2B",
    "West of England" = "#40A832"
  )) +
  labs(title = "Population change",
       subtitle = "West of England (including constituent authorities and North Somerset)",
       y = "Cumulative population change (%)",
       x = "Year",
       caption = "Source: ONS mid-year population estimates")+
  theme_weca()+
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 11))+
  guides(color = guide_legend(nrow = 2))
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  )

RI_1E2_plot

#fact table

RI_1E2_fact_tbl <- RI_1E2_raw_tbl |>
  filter(Area == "West of England") |>
  transmute(
    period_start = as.Date(glue("{Date}-01-01")),
    period_end = as.Date(glue("{Date}-12-31")),
    value = cumulative_percentage_change,
    date = NULL,
    cumulative_percentage_change = NULL
  ) |>
  glimpse()

RI_1E2_fact_tbl |> 
  build_fact("RI_1E2_population_change") |> 
  save_fact()