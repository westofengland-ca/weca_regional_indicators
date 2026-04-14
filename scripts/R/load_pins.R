library(pins)
library(arrow)
library(tidyverse)
library(sf)

board <- board_s3(
  bucket = "stevecrawshaw-bucket",
  prefix = "pins/",
  region = "eu-west-2"
)

# pin_list(board)

# df <- pin_read(board, "ca_la_lookup_tbl")
# df |> glimpse()

# SPATIAL - Download the GeoParquet file

read_spatial_pin <- function(spatial_pin_name) {
  pin_path <- pin_download(board, spatial_pin_name)
  arrow_tbl <- arrow::read_parquet(pin_path, as_data_frame = FALSE)
  sf_obj <- st_as_sf(as_tibble(arrow_tbl))
  return(sf_obj)
}
