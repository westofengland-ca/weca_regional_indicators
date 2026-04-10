# Chapter 06: Child Poverty

**Lead analyst:** MJ  
**Priority:** Lifting children and families out of poverty

---

## Indicators

| ID | Name | Status | Data source | Refresh |
|----|------|--------|-------------|---------|
| RI_6A1 | [Indicator name] | Planned | [Source] | [Annual/Quarterly] |

Add a row per indicator as they are developed.

---

## Data Sources

| Source | URL / Location | Licence | Notes |
|--------|----------------|---------|-------|
| [Source name] | [URL or internal path] | [OGL / Proprietary] | [Any caveats] |

---

## Known Gaps and Caveats

- [ ] No indicators implemented yet
- [ ] [Add known data gaps or methodological caveats here]

---

## Technical Dependencies

- R packages beyond `tidyverse`: none beyond `_common.R`
- Python: none
- External services: none

---

## Refresh Process

1. Download updated data from [source]
2. Save to `data/raw/` (not committed)
3. Run processing script: `scripts/R/06-child-poverty/[script].R`
4. Output lands in `data/fact/` (committed)
5. Re-render chapter: `quarto render chapters/06-child-poverty/index.qmd`
