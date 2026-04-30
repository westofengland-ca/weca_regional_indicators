pacman::p_load(tidyverse, glue, janitor, here)
source(here::here("scripts", "R", "_common.R"))

# RI_1D1_broadband_coverage

RI_1D1_raw_tbl<-read_csv(here::here("data", "raw", "broadband_coverage_weighted.csv"))

head(RI_1D1_raw_tbl)

#convert to date

RI_1D1_raw_tbl <- RI_1D1_raw_tbl %>%
  mutate(date = dmy(date))

#plot

RI_1D1_plot<- ggplot(RI_1D1_raw_tbl, aes(x=date))+
  geom_line(aes(y = superfast_coverage, color = "Superfast (30mbps)"), linewidth = 1, na.rm = TRUE) +
  geom_line(aes(y = gigabit_coverage, color = "Gigabit (1000mbps)"), linewidth = 1, na.rm = TRUE) +
  geom_point(aes(y = superfast_coverage, color = "Superfast (30mbps)"), size = 2, na.rm = TRUE) +
  geom_point(aes(y = gigabit_coverage, color = "Gigabit (1000mbps)"), size = 2, na.rm = TRUE) +
  scale_color_manual(values = c(
    "Superfast (30mbps)" = "#40A832",
    "Gigabit (1000mbps)" = "#590075"
  )) +
  labs(title = "Broadband coverage",
       subtitle = "West of England (weighted)",
       y = "Coverage (%)",
       x = "Year",
       caption = "Source: Ofcom Connected Nations")+
  theme_weca()+
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 11))+
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