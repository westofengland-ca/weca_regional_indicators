pacman::p_load(tidyverse, glue, janitor, here, readxl)
source(here::here("scripts", "R", "_common.R"))

# get the data

RI_2_example_tbl <- read_csv(here::here("data", "examples", "bus_ridership.csv"))

glimpse(RI_2_example_tbl)


ggplot(RI_2_example_tbl, aes(x = year, y = ridership)) +
  geom_line() +
  geom_point() +
    labs(title = "Bus ridership",
       subtitle = "West of England",
       x = "Year",
       caption = "Source DFT") +
  theme_weca() +
  theme(axis.title.y = element_text(angle = 0, vjust = 0.5))
