# Units in summary tables: percentages vs. percentage points

Units and percentage handling flow through three files, and there's a key
distinction between an indicator's **own units** and the **units of its
period-over-period change**.

This document describes how it works today, after the migration to a
declared `unit_type` column — see
[`unit-type-migration.md`](unit-type-migration.md) for how it got here and
the list of indicators with ambiguous or wrong units still to resolve.

## 1. Where units come from

`units` is a plain string per indicator in
`data/common_project_data/indicators-master.xlsx` (e.g. `"%"`, `"kt CO2e"`,
`"GBP"`). It's pulled in via `get_dim_priority()` / `get_dim_all()` in
`scripts/R/dim_data.R:21-51` and joined onto the reporting view. The **latest
value** column in every summary table just shows this string as-is next to
the formatted number — no unit-aware logic there.

## 2. Change is computed two different ways depending on whether the indicator is itself a percentage

In `build_reporting_view()` (`scripts/R/collate_fact.R:124-127`), a relative
`pct_change` is *always* precomputed for every indicator, unit-agnostic:

```r
pct_change = (latest_value / previous_value - 1) * 100
```

But that's only actually used for non-percentage indicators. In
`format_overall_summary()`, the code branches on the indicator's declared
`unit_type` (`data/common_project_data/indicators-master.xlsx`, joined in via
`get_dim_priority()` / `get_dim_all()`):

```r
is_percent = (unit_type == "percent"),
change_raw = dplyr::if_else(
  is_percent,
  latest_value - previous_value,   # simple point difference
  pct_change                       # relative % change from build_reporting_view()
)
```

`format_indicator_summary()` (`scripts/R/reporting_table.R`) does the same
thing, looking up `unit_type` (and `units`, for the value suffix) from
`core_dim_data_tbl` by `indicator_id` via `get_dim_indicator()`
(`scripts/R/dim_data.R`) rather than taking a hand-typed `units` argument.

`unit_type` is a closed enum (`percent`, `count`, `currency`, `rate`,
`index`, `score`, `ratio`), validated at load time in `dim_data.R` — a typo
fails the render rather than silently picking the wrong branch, which is
exactly what happened under the old string-matching approach (indicators-
master.xlsx spelled the unit `"Percent"`, but the test was a literal
`units == "%"`, so all 33 percentage indicators silently rendered a
*relative* change: employment 74.8 -> 75.2 as `+0.5%` instead of `+0.4 ppt`).

The reasoning: if an indicator is already a percentage (e.g. employment rate
74.8% -> 75.2%), the meaningful change is the **percentage-point difference**
(+0.4 ppt), not the relative change of a percentage (+0.53%), which is
misleading and rarely what a reader wants. For a non-percentage indicator
(e.g. GHG emissions in kt), the natural change measure is relative % change.

## 3. Formatting the suffix

`.fmt_change()` (`scripts/R/summary_tables.R`) picks the suffix to
match which branch was taken:

```r
suffix <- dplyr::if_else(is_percent, " ppt", "%")
```

So confusingly-but-consistently: percentage indicators get a `" ppt"`
suffix on their change column, and everything else gets `"%"` (because their
`change_raw` already *is* a relative percentage).

`format_indicator_summary()` additionally uses the same `unit_type` check to
pick the *value* suffix: percentage indicators render `74.8%`, everything
else ` <units>` (`4,410 kt CO2e`).

## 4. Arrow direction and colour are independent of the above

`.change_colour()` (`scripts/R/summary_tables.R:56-66`) only cares about the
sign of `change_raw` and the indicator's `polarity` (+1 = up is good, -1 = up
is bad, from indicators-master.xlsx) — it doesn't care whether the underlying
number was ppt or %.

## Both summary tables share one code path

`format_priority_summary()` (the per-chapter table) and
`format_overall_summary()` (the landing page) both run their joined rows
through `.prepare_summary_rows()` and render them with `.build_priority_gt()`,
so the ppt/% distinction, the polarity colouring and the green priority band
behave identically in a chapter and on the landing page. A chapter's table is
that priority's landing-page sub-table with a title and subtitle added.

One consequence: `format_priority_summary()` now requires `previous_value` and
`pct_change` on the reporting view it is given, not just `latest_value`. Any
reporting view built with `build_reporting_view()` has them.
