## Summary

<!-- Brief description of what this PR adds or changes -->

**Related Issue:** #
<!-- Link to the issue this PR addresses -->

---

## Changes Made

<!-- List the key changes in this PR -->

-
-
-

---

## QA Checklist

**Before submitting this PR, I have completed the following from `QA_CHECKLIST.md`:**

### Code Execution
- [ ] All code chunks execute without errors
- [ ] Required packages/libraries are documented
- [ ] File paths use relative paths from project root (R) or `pathlib.Path()` (Python)

### Data & Calculations
- [ ] Data sources are documented (location, access method, coverage)
- [ ] Calculations are correct and reproducible
- [ ] Assumptions and caveats are clearly stated

### Visualizations
- [ ] Charts are clear, properly labeled, and use WECA branding (`theme_weca()`)
- [ ] Alt text provided for all figures
- [ ] Color palettes are accessible (colorblind-safe)

### Narrative & Context
- [ ] Executive summary provided (key findings, implications)
- [ ] Trends are explained (not just described)
- [ ] Limitations and data quality issues are noted

### Accessibility
- [ ] Tables have proper headers and captions
- [ ] Color is not the only way to convey information
- [ ] Text meets contrast requirements

### Code Quality
- [ ] Code follows project style guide (see `CONTRIBUTING.md`)
- [ ] Inline comments explain non-obvious logic
- [ ] No hardcoded credentials or sensitive data

### Reproducibility
- [ ] Chapter renders successfully with `quarto render`
- [ ] Dependencies are documented in environment files
- [ ] Data refresh workflow is documented

**Full QA Checklist:** See [`QA_CHECKLIST.md`](../QA_CHECKLIST.md)

---

## Data Sources

**Primary data sources used in this PR:**

| Dataset | Source | Date Accessed | Coverage |
|---------|--------|---------------|----------|
| <!-- e.g., "Employment by LA" --> | <!-- e.g., "NOMIS API" --> | <!-- e.g., "2024-01-15" --> | <!-- e.g., "2015-2024" --> |

---

## Testing & Validation

**How has this been tested?**

- [ ] Local render: `quarto render chapters/XX-chapter/index.qmd`
- [ ] Test render script: `./scripts/test_render.sh`
- [ ] Manual validation: <!-- Describe manual checks, e.g., "Verified calculations against source data" -->

**Output preview:**

<!-- If applicable, provide screenshots of key visualizations or tables -->

---

## Reviewer Notes

**Areas for special attention:**

<!-- Highlight any sections that need careful review, e.g., complex calculations, data assumptions -->

---

## Post-Merge Actions

<!-- Any follow-up tasks after this PR is merged? -->

- [ ] Update issue tracker
- [ ] Notify stakeholders
- [ ] Schedule data refresh (if applicable)
