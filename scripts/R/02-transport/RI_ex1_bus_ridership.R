# load libraries
pacman::p_load(tidyverse, glue, janitor, here)

# Heather you can also instead do:
#
# library(tidyverse)
# library(glue)
# library(janitor)
# library(here)

# it looks like pacman is the issue

# load up helper scripts that i set up for you
source(here::here("scripts", "R", "_common.R"))


# note how here() works - from the project root, each subfolder and file in quotation marks separated by commas
here::here("data", "examples", "bus_ridership.csv")

# read the data
# if you are reading excel, you load the readxl library (add to first line at the top of script) and you would use a function like read_xlsx() instead of read_csv()
RI_ex1_raw_tbl <- read_csv(here::here("data", "examples", "bus_ridership.csv"))

# Now we create the plot set the aesthetics, add the geometries, add the labels, add the theme to make it look nice
RI_ex1_plot <- ggplot(RI_ex1_raw_tbl, aes(x = year, y = ridership)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(
    title = "Bus Ridership",
    subtitle = "West of England",
    x = "Year"
  ) +
  theme_weca()

# we assigned the plot to this variable
RI_ex1_plot

# let's explore piping versus traditional syntax
# not needed for indicator - just a demo
glimpse(RI_ex1_raw_tbl)

# ugly
filter(mutate(filter(RI_ex1_raw_tbl, year >= 2019), r_times_2 = ridership * 2), r_times_2 <= 100)

# same, but readable and nice - can easily see order of operations

result <- RI_ex1_raw_tbl |>
  filter(year >= 2019) |>
  mutate(r_times_2 = ridership * 2) |>
  filter(r_times_2 <= 100)

result

# let's make the FACT table
# we need 3 columns: period_start, period_end (both date format) and value - a number for each period

# we make a string of characters with the glue() function
# we then change the data type from string (glue) to date - for both period start and period end
# we delete the extraneous columns

RI_ex1_fact_tbl <- RI_ex1_raw_tbl |>
  mutate(
    period_start = as.Date(glue("{year}-01-01")),
    period_end = as.Date(glue("{year}-12-31")),
    value = ridership,
    year = NULL,
    ridership = NULL
  )

# here we verify the format, supply the indicator name (from the spreadsheet)
# and save it as a csv
RI_ex1_fact_tbl |>
  build_fact("RI_ex1_bus_ridership") |>
  save_fact()
