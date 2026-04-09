# _common.R
# Shared setup sourced by every chapter in the WECA regional indicators report.
# Each chapter sources this file once via:
#   source(here::here("scripts", "R", "_common.R"))
#
# Chapter-specific helpers and `library()` calls remain in the chapter itself
# so that per-chapter dependencies stay visible.

source(here::here("scripts", "R", "theme_weca.R"))
source(here::here("scripts", "R", "helpers.R"))
source(here::here("scripts", "R", "fact_helpers.R"))
source(here::here("scripts", "R", "collate_fact.R"))
source(here::here("scripts", "R", "reporting_table.R"))
