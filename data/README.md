# Data Directory Guide

This directory contains all data files used in the West of England Regional Priorities Indicators project.

---

## 📁 Directory Structure

```
data/
├── common_project_data/  # meta data about indicators (Committed to Git)
├── raw/              # Original, unmodified data files (NOT committed to Git)
├── processed/        # Cleaned/transformed data ready for analysis (NOT committed to Git)
└── examples/         # Small example datasets for templates (COMMITTED to Git)
```

---

## 🗂️ Directory Purposes

### `raw/`

**Purpose:** Store original data files exactly as received from the source.

**What goes here:**

- Downloaded CSV/Excel files from ONS, DfT, local authorities
- API responses saved to files
- Survey data exports
- Any data that hasn't been modified

**Rules:**

- ✅ Never modify files in this directory
- ✅ Keep original filenames or use descriptive names
- ✅ Document the source and download date
- ❌ Don't commit to Git (files ignored by `.gitignore`)

**Example files:**

```
raw/
├── bus_ridership_DfT_2024-01-15.csv
├── housing_prices_ONS_2024-02-01.xlsx
├── employment_NOMIS_2023-12-10.csv
└── council_budget_WECA_2024-01-20.xlsx
```

---

### `processed/`

**Purpose:** Store cleaned, filtered, or transformed data ready for analysis.

**What goes here:**

- Data after cleaning (removed nulls, fixed datatypes)
- Filtered datasets (e.g., only West of England authorities)
- Aggregated or summarised data
- Merged datasets from multiple sources
- Intermediate analysis outputs

**Rules:**

- ✅ Keep processing scripts in `scripts/` directory
- ✅ Make processing reproducible (script should recreate processed file from raw)
- ✅ Use descriptive filenames indicating transformations
- ❌ Don't commit to Git (files ignored by `.gitignore`)

**Example files:**

```
processed/
├── bus_ridership_cleaned_2024-02-05.csv
├── housing_prices_weca_only_2024-02-05.parquet
├── employment_annual_summary_2024-02-06.csv
└── combined_transport_metrics_2024-02-10.csv
```

---

### `examples/`

**Purpose:** Small, anonymised example datasets for testing and templates.

**What goes here:**

- Dummy data for code examples (fake but realistic)
- Small subsets of real data (if permitted and anonymised)
- Test datasets for validating analysis scripts

**Rules:**

- ✅ Keep files small (<100 KB, ideally <50 KB)
- ✅ These files ARE committed to Git
- ✅ Ensure no sensitive or personal data
- ✅ Document what the data represents

**Example files:**

```
examples/
├── example_indicator.csv         # Generic indicator template data
├── sample_transport_data.csv     # Example transport metrics
└── demo_housing_prices.csv       # Fictitious housing data
```

---

## 📝 File Naming Conventions

Use this pattern for consistency:

```
<topic>_<source>_<YYYY-MM-DD>.<ext>
```

### Examples

**Good naming:**

```
✅ bus_ridership_DfT_2024-01-15.csv
✅ housing_prices_ONS_2024-02-01.xlsx
✅ employment_NOMIS_2023-12-10.csv
✅ council_budget_WECA_2024-01-20.xlsx
✅ transport_metrics_cleaned_2024-02-05.csv
```

**Avoid:**

```
❌ data.csv                       # Too vague
❌ Download (1).xlsx              # Browser default name
❌ FINAL_FINAL_v2.csv             # Version chaos
❌ mydata_03-02-24.csv            # Ambiguous date format (UK vs US)
❌ Data File With Spaces.csv     # Spaces complicate scripting
```

### Naming Components

| Component | Description | Examples |
|-----------|-------------|----------|
| **Topic** | What the data is about | `bus_ridership`, `housing_prices`, `employment` |
| **Source** | Where it came from | `ONS`, `DfT`, `NOMIS`, `WECA`, `council` |
| **Date** | When downloaded/created | `2024-01-15` (ISO 8601: YYYY-MM-DD) |
| **Extension** | File format | `.csv`, `.xlsx`, `.parquet`, `.rds` |

### Optional Suffixes

Add these when helpful:

- `_cleaned` - Data after cleaning
- `_filtered` - Subset of larger dataset
- `_summary` - Aggregated/summarised
- `_combined` - Merged from multiple sources
- `_weca` - Filtered to WECA geography

---

## 🔗 Referencing Data in Code

### R (using relative paths)

**Recommended approach:**

```r
library(readr)

# Load raw data
data <- read_csv("data/raw/bus_ridership_DfT_2024-01-15.csv")

# Load processed data
clean_data <- read_csv("data/processed/bus_ridership_cleaned_2024-02-05.csv")

# Load example data
example <- read_csv("data/examples/example_indicator.csv")
```

**Why relative paths from project root?**

- ✅ Quarto sets the working directory to the project root (`execute-dir: project` in `_quarto.yml`)
- ✅ Paths work for all team members
- ✅ Simple and easy to read

**Avoid:**

```r
# ❌ Absolute path (breaks for other users)
data <- read_csv("C:/Users/heather/projects/weca_regional_indicators/data/raw/file.csv")

# ❌ Navigating up with ../.. (fragile if file moves)
data <- read_csv("../../data/raw/file.csv")
```

---

### Python (using `pathlib.Path`)

**Recommended approach:**

```python
from pathlib import Path
import pandas as pd

# Define project root
project_root = Path(__file__).parent.parent  # Adjust based on script location
# Or use a fixed reference point
project_root = Path("C:/Users/steve.crawshaw/projects/weca_regional_indicators")

# Load raw data
data_path = project_root / "data" / "raw" / "bus_ridership_DfT_2024-01-15.csv"
df = pd.read_csv(data_path)

# Load processed data
processed_path = project_root / "data" / "processed" / "bus_ridership_cleaned_2024-02-05.csv"
df_clean = pd.read_csv(processed_path)
```

**Or use relative paths from Quarto:**

```python
import pandas as pd

# Quarto executes from project root, so relative paths work
df = pd.read_csv("data/raw/bus_ridership_DfT_2024-01-15.csv")
```

---

## 🔄 Data Refresh Workflow

When updating data with new versions:

### 1. Download New Data

```bash
# Download to data/raw/ with date stamp
data/raw/bus_ridership_DfT_2024-03-15.csv
```

### 2. Update Processing Script

```r
# Update date in script
source("scripts/R/process_bus_data.R")
```

### 3. Verify Processed Output

```r
# Check that processed data looks correct
processed <- read_csv("data/processed/bus_ridership_cleaned_2024-03-15.csv")
summary(processed)
```

### 4. Update Chapter Code

```r
# Update date reference in chapter
data <- read_csv("data/raw/bus_ridership_DfT_2024-03-15.csv")
```

### 5. Re-render Chapter

```bash
quarto render chapters/02-transport/index.qmd
```

### 6. Archive Old Files (Optional)

```bash
# Create archive directory if needed
mkdir -p data/archive/

# Move old version
mv data/raw/bus_ridership_DfT_2024-01-15.csv data/archive/
```

---

## 🚫 What NOT to Commit

The `.gitignore` file prevents these from being committed:

### Data File Patterns

```gitignore
data/raw/*           # All raw data
data/processed/*     # All processed data
*.csv                # CSV files (except in examples/)
*.xlsx               # Excel files
*.xls                # Legacy Excel files
*.rds                # R data files
*.parquet            # Parquet files
*.feather            # Feather files
*.db                 # Databases
*.sqlite             # SQLite databases
```

### Exceptions (WILL be committed)

```gitignore
!data/examples/      # Example data is committed
!data/raw/.gitkeep   # Keep directory structure
!data/processed/.gitkeep
```

---

## 📊 Recommended File Formats

| Format | Use Case | Pros | Cons |
|--------|----------|------|------|
| **CSV** | Small/medium datasets, universal compatibility | Human-readable, widely supported | No metadata, larger file size |
| **Parquet** | Large datasets, columnar data | Compressed, fast, typed columns | Not human-readable |
| **Excel (xlsx)** | Raw data from sources, small datasets | Familiar, supports multiple sheets | Slower to read, proprietary |
| **RDS** | R-specific intermediate data | Preserves R object types | R-only |
| **Feather** | Cross-language (R/Python) | Fast, preserves types | Less compression than Parquet |

### Recommendations

**For raw data:**

- Keep in original format (usually CSV or Excel)

**For processed data:**

- **Small (<1 MB):** CSV is fine
- **Medium (1-100 MB):** Parquet for better compression/speed
- **Large (>100 MB):** Parquet or Feather
- **R-specific:** RDS if staying in R ecosystem

---

## 📋 Data Documentation Template

Create a data dictionary for each dataset in your chapter:

```markdown
## Data: Bus Ridership

**Source:** Department for Transport (DfT)
**URL:** https://www.gov.uk/government/statistics/...
**Downloaded:** 2024-01-15
**Geographic coverage:** West of England Combined Authority
**Time period:** 2015-2024 (annual)
**File:** `data/raw/bus_ridership_DfT_2024-01-15.csv`

### Variables

| Column | Description | Type | Example |
|--------|-------------|------|---------|
| `year` | Calendar year | Integer | 2024 |
| `authority` | Local authority name | String | Bristol City |
| `ridership` | Annual bus passengers (millions) | Float | 45.2 |
| `routes` | Number of bus routes | Integer | 127 |

### Notes
- Data for 2020-2021 affected by COVID-19 pandemic
- Ridership figures exclude school buses
- Routes counted as of end of calendar year
```

---

## 🔐 Data Security & Privacy

### Personal Data

- ❌ **Never commit** personal data (names, addresses, contact info)
- ❌ **Never commit** sensitive data (health records, financial details)
- ✅ **Do anonymise** before using in examples
- ✅ **Do aggregate** to area level (not individual level)

### Sensitive Information

- ❌ Don't include API keys in data files
- ❌ Don't include database credentials
- ✅ Store credentials in `.env` files (automatically ignored)

### Data Sharing

- Cheque data licence before committing to Git
- Some datasets may prohibit redistribution
- When in doubt, ask the data owner or team lead

---

## 📏 File Size Guidelines

### Git Repository Limits

| File Size | Action |
|-----------|--------|
| **< 10 MB** | Fine to commit (if appropriate for `examples/`) |
| **10-50 MB** | Use caution - consider if needed in repo |
| **> 50 MB** | Do NOT commit - use shared drive or Databricks |

### Checking File Sizes

```bash
# List files in data/raw/ by size
ls -lhS data/raw/

# Find files larger than 10MB
find data/ -type f -size +10M
```

---

## ✅ Quick Reference Checklist

**Before adding data to the project:**

- [ ] File is in correct directory (`raw/`, `processed/`, `examples/`)
- [ ] Filename follows naming convention
- [ ] File size is appropriate (<50 MB)
- [ ] No personal or sensitive data
- [ ] Data source is documented in chapter
- [ ] Data licence permits use
- [ ] Large files are NOT in `examples/` (won't be committed)

**Before referencing data in code:**

- [ ] Using relative paths from project root (R) or `pathlib.Path` (Python)
- [ ] No hardcoded absolute paths
- [ ] File path works for all team members
- [ ] Data file exists in expected location

**Before updating existing data:**

- [ ] New file follows same naming pattern with updated date
- [ ] Processing script updated (if applicable)
- [ ] Chapter code updated to reference new file
- [ ] Old file archived or documented

---

## 🆘 Common Issues

**Q: I can't find my data file**

```r
# Use this to check your working directory
getwd()

# List files in data/raw/
list.files("data/raw")
```

**Q: Git is trying to commit my large CSV file**

- Cheque `.gitignore` includes `*.csv` pattern
- File should be in `data/raw/` or `data/processed/`
- If it's example data, move to `data/examples/` AND ensure <50 KB

**Q: Data path works for me but not colleagues**

- Likely using absolute path - switch to relative paths from project root
- Cheque for hardcoded username in path
- Verify file is in Git repo (not local-only location)

**Q: How do I share large data files with team?**

- Use shared drive (OneDrive, SharePoint)
- Store in Databricks
- Document location in chapter README
- Never commit >50 MB files to Git

---

**Need help?** See `GETTING_STARTED.md` or ask in the Analysts Team Chat.
