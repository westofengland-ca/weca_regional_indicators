# Units: what was fixed, and the `unit_type` migration still to do

**Written:** 2026-07-31

Background reading: [`summary-table-units.md`](summary-table-units.md) explains
how units drive the change column (percentage points vs. relative per cent).

## Part 1 — done: shared percentage predicate

### The bug

`format_overall_summary()` tested `is_percent = (units == "%")`. The master
sheet (`data/common_project_data/indicators-master.xlsx`) spells the unit
`"Percent"`, so that test **never fired**. All 33 percentage indicators on the
landing page were rendering a *relative* change with a `%` suffix: employment
74.8 -> 75.2 came out as `+0.5%` instead of `+0.4 ppt`. The number was wrong,
not just the label.

`format_indicator_summary()` had the same fault via `identical(units, "%")`.
25 chapter calls pass `"%"` and were fine; 4 pass `"percent"` and were not.

### The fix

`scripts/R/summary_tables.R` gained a shared predicate, next to
`.fmt_change()` and `.change_colour()`:

```r
.is_percent_units <- function(units) {
  normalised <- tolower(trimws(as.character(units)))
  normalised <- sub("\\.$", "", normalised)
  !is.na(normalised) & normalised %in% c("%", "percent", "percentage", "per cent")
}
```

Vectorised, never returns `NA`. Called from:

- `format_overall_summary()` (`summary_tables.R`) — the change branch.
- `format_indicator_summary()` (`reporting_table.R`) — both the change branch
  and the value suffix, so `units = "percent"` now renders `79.6%` rather
  than `79.6 percent`.

`reporting_table.R` already depended on `.fmt_change()` from
`summary_tables.R`, so this added no new cross-file coupling. Note that
`_common.R` sources `reporting_table.R` *before* `summary_tables.R`; that's
fine because the lookup happens at call time, but it means neither file can be
sourced standalone.

### Verified

All 33 `Percent` indicators take the ppt branch; nothing else does.

```
RI_1A1_employment_rate      79.60 <- 79.900   down 0.3 ppt
RI_2_mode_share             49.45 <- 36.798   up 12.7 ppt
RI_5_ghg_emissions        4333.37 <- 4425.83  down 2.1%   (unchanged)
```

### Freeze cache

The rendered pages will not pick this up until the cache is invalidated:

```bash
rm -rf _freeze/index/execute-results _freeze/chapters/01-economy/index/execute-results
```

Four chapter-01 cards change appearance — they gain ppt changes and a `%`
value suffix:

- `RI_1B1_gdp_growth`
- `RI_1D1_broadband_coverage`
- `RI_1E2_population_change`
- `RI_1E3_area_satisfaction`

## Part 2 — done: declare units semantics in the master sheet

String matching is a stopgap. Free text keeps drifting (`Percent`, `%`,
`percent`, `Index relative to 2020 baseline.` with a trailing full stop,
`TBC`, blank), and it cannot express `"Number and %"` at all. The durable fix
is to declare the semantics rather than infer them from a display label.

### Step 1 — add a column to indicators-master.xlsx

On the `indicators` sheet, alongside `units` and `polarity`:

| column | allowed values |
|---|---|
| `unit_type` | `percent`, `count`, `currency`, `rate`, `index`, `score`, `ratio` |

Keep `units` as the display label — it carries information `unit_type`
cannot (`kt CO2e` vs `Hectares`). `unit_type` carries the semantics the code
needs.

Watch the read range in `dim_data.R`: `range = "A2:AM100"`. Adding a column
past AM will be silently truncated.

### Step 2 — pull it through `dim_data.R`

Add `unit_type` to the `select()` in **both** `get_dim_priority()` and
`get_dim_all()` (`scripts/R/dim_data.R`).

### Step 3 — validate on load

Next to the existing `file.exists()` check in `dim_data.R`:

```r
valid_unit_types <- c("percent", "count", "currency", "rate", "index", "score", "ratio")
stopifnot(all(core_dim_data_tbl$unit_type %in% valid_unit_types))
```

A typo should fail the render, not silently pick the wrong branch — which is
exactly what happened with `"Percent"` vs `"%"`.

### Step 4 — switch `format_overall_summary()`

```r
is_percent = (unit_type == "percent")
```

No string guessing.

### Step 5 — done: switch `format_indicator_summary()`

Implemented the "better end state": `format_indicator_summary()` now takes
a required `dim_tbl` argument instead of `units`, and looks up `units` and
`unit_type` for the given `indicator_id` via the new `get_dim_indicator()`
helper in `dim_data.R`. Updated all ~45 call sites across the six chapter
`.qmd` files (`dim_tbl = core_dim_data_tbl` replaces the old `units = "..."`
line). `polarity` was left as a manual argument, unchanged.

This surfaced the two disagreements flagged below as live regressions,
since the code now trusts the master sheet over the chapter's hand-typed
string:

- **`RI_1B1_gdp_growth`** — still needs `unit_type` changed from `index` to
  `percent` in indicators-master.xlsx (one-cell edit, not yet done).
- **`RI_3C3_rental_affordability`** — still needs its `unit_type`/`units`
  resolved once someone decides what the indicator is meant to measure (see
  Part 3 below; not yet done).

### Step 6 — done: delete the stopgap

Removed `.is_percent_units()` from `summary_tables.R` and its references in
`summary-table-units.md` and `CLAUDE.md`. Both `format_overall_summary()`
and `format_indicator_summary()` now read `unit_type` directly from
`core_dim_data_tbl`.

### Optional

Add a `display_unit` mapping so the Units column shows `%` rather than
`Percent`.

## Part 3 — indicators needing attention

### Genuinely ambiguous: decide before assigning `unit_type`

A FACT row holds a single `value`, so "number **and** percentage" cannot be one
indicator. Each of these is either two indicators, or one with a chosen
measure. None has FACT data yet, so nothing is currently rendering wrongly.

| indicator | units | question |
| --- | --- | --- |
| `RI_2E1_dev_site_connectivity` | `Number and percentage` | which does `value` hold? |
| `RI_3B1_building_remediation` | `Number and %` | same |
| `RI_3A1_co2_domestic` | `Kilotonnes Co2e and per capita` | same — and `scripts/R/03-place/RI_3A1_domestic_co2.R` is about to give it FACT data |

### Wrong, and rendering incorrectly now

All three have FACT data.

- **`RI_1B1_gdp_growth`** — master says `Index`; values run -0.04 to 4.4, i.e.
  a growth rate in per cent. The landing page shows `-27.7%`, the relative
  change of a growth rate, which is near-meaningless; it should read
  `-1.1 ppt`. The chapter already passes `units = "percent"`, so master and
  chapter disagree. Master should be `Percent` / `unit_type = percent`.
- **`RI_3C3_rental_affordability`** — master says `Ratio`; FACT values run
  942 -> 1677 and `chapters/03-place/index.qmd` passes `"£ per month"`. The
  indicator name says ratio, the data is a monthly rent. Resolve what the
  indicator is meant to measure rather than just relabelling it.
- **`RI_3C2_house_price_earnings`** — `Ratio`, no FACT data yet. Genuinely a
  ratio, so `unit_type = ratio` is correct. Listed only because it sits next
  to the one above.

### Missing units, to fill as FACT data lands

`NA`: `RI_2D1_satisfaction_xref`, `RI_3D2_site_viability`,
`RI_4B6_claimant_deprived_wards`, `RI_4C1_skills_gaps`.

`TBC`: `RI_1E1_business_reputation`, `RI_1D2_nondom_property_stock`,
`RI_5F2_species_richness`, `RI_5F3_land_for_nature`,
`RI_6C1_qol_deprived_areas`, `RI_6D1_life_satisfaction`.

Note `RI_4B6_claimant_deprived_wards` is described as "as % of working age
population" — a percentage indicator with an empty units cell.

### Unrelated data issue spotted in passing

`RI_1B3_median_weekly_pay` has monthly periods and values around £1,670-2,662.
That is not weekly pay. Not a units problem.

- _freeze/index/execute-results/html.json is tracked in git and was regenerated, so it'll show as modified — that's expected and should be committed with the code change.
- ↓ -27.7% in the output is RI_1B1_gdp_growth, the master-sheet mislabel from part 3 of the migration doc (Index where the data is a growth rate in per cent). Fixing that cell to Percent turns it into -1.1 ppt; it's a one-cell spreadsheet edit if you want it corrected ahead of the full unit_type migration.

Chapter 01's freeze cache is untouched, so its four cards still render the old way until you clear _freeze/chapters/01-economy/index/execute-results.
