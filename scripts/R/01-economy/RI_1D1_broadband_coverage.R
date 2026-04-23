pacman::p_load(tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "_common.R"))

# RI_1D1_broadband_coverage

RI_1D1_raw_tbl<-read_csv(here::here("data", "raw", "superfast_coverage_weighted.csv"))

head(RI_1D1_raw_tbl)

#convert to date

RI_1D1_raw_tbl <- RI_1D1_raw_tbl %>%
  mutate(date = dmy(date))

#plot

RI_1D1_plot<- ggplot(RI_1D1_raw_tbl, aes(x=date, y=superfast_coverage))+
  geom_line(linewidth=1)+
  geom_point(size=3)+
  labs(title = "Superfast broadband coverage",
       subtitle = "West of England (weighted)",
       y = "Superfast broadband coverage (%)",
       x = "Year")+
  theme_weca()+
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  )

RI_1D1_plot

#fact table

RI_1D1_fact_tbl <- RI_1D1_raw_tbl |>
  transmute(
    period_start = as.Date(glue("{date}-01-01")),
    period_end = as.Date(glue("{date}-12-31")),
    value = superfast_coverage,
    date = NULL,
    superfast_coverage = NULL
  ) |>
  glimpse()

RI_1D1_fact_tbl |> 
  build_fact("RI_1D1_broadband_coverage") |> 
  save_fact()