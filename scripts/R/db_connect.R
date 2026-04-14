library(DBI)
library(RPostgres)
readRenviron(".env")

con <- dbConnect(
  Postgres(),
  host = Sys.getenv("POSTGRES_HOST"),
  port = as.integer(Sys.getenv("POSTGRES_PORT")),
  dbname = Sys.getenv("POSTGRES_DB"),
  user = Sys.getenv("POSTGRES_USER"),
  password = Sys.getenv("POSTGRES_PASSWORD")
)

# Test connection
dbGetQuery(con, "SELECT current_database(), current_user, version()")
# read spatial data - eg the lep boundary
# lep_bound <- st_read(con, query = " SELECT * FROM os.bdline_ua_lep_diss")
