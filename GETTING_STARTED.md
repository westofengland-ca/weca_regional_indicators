# Getting Started with WECA Indicators Project

Welcome to the West of England Regional Priorities Indicators project! This guide will help you set up your environment and create your first indicator.

---

## 📋 Prerequisites

Before you begin, install the following software:

### Required Software

| Tool | Purpose | Download Link |
|------|---------|---------------|
| **Positron** | IDE for R and Python | [https://github.com/posit-dev/positron/releases](https://github.com/posit-dev/positron/releases) |
| **R** (≥4.3) | Statistical computing | [https://cran.r-project.org/](https://cran.r-project.org/) |
| **Python** (≥3.10) | Data analysis | [https://www.python.org/downloads/](https://www.python.org/downloads/) |
| **Quarto** (≥1.4) | Document rendering | [https://quarto.org/docs/get-started/](https://quarto.org/docs/get-started/) |
| **Git** | Version control | [https://git-scm.com/downloads](https://git-scm.com/downloads) |
| **uv** | Python package manager | [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/) |

### Verify Installation

Open **Git Bash** and run:

```bash
# Check versions
positron --version
R --version
python --version
quarto --version
git --version
uv --version
```

---

## 🚀 First-Time Setup

### 1. Clone the Repository

```bash
# Navigate to your projects folder
cd ~/projects

# Clone the repository
git clone <repository-url>
cd weca_analysis_and_evaluation/projects/indicators
```

### 2. Install Pre-Commit Hooks

The project uses pre-commit hooks to prevent accidental commits of secrets (API keys, passwords).

```bash
# Make the script executable (Git Bash)
chmod +x scripts/install-hooks.sh

# Run the installer
./scripts/install-hooks.sh
```

**What this does:**

- Installs a secret-scanning hook that runs before each commit
- Blocks commits containing `.env` files, API keys, passwords
- Prevents accidental exposure of sensitive data

### 3. Set Up Python Environment

```bash
# Create and activate virtual environment
uv venv
source .venv/bin/activate  # Git Bash
# .venv\Scripts\activate   # Windows CMD (if needed)

# Install dependencies
uv sync
```

**Installed packages:** pandas, polars, matplotlib, plotly, jupyter, and more (see `pyproject.toml`)

### 4. Set Up R Environment

Open **Positron** and run in the R console:

```r
# Install renv (if not already installed)
install.packages("renv")

# Initialize renv for this project (first time only)
renv::init()

# Install core packages
install.packages(c(
  # Data wrangling ecosystem
  "tidyverse",    # Meta-package: includes ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats

  # Data import/export
  "readxl",       # Read Excel files (.xlsx, .xls)
  "writexl",      # Write Excel files (lightweight, no Java dependency)

  # API and web data
  "httr2",        # Modern HTTP client for API requests
  "jsonlite",     # Parse and generate JSON data

  # Data cleaning
  "janitor",      # Clean column names, remove duplicates, tabulate frequencies

  # String manipulation
  "glue",         # String interpolation and formatting

  # Advanced visualization
  "ggtext",       # Markdown/HTML formatting in ggplot2 labels
  "ggrepel",      # Smart label positioning (avoid overlaps)
  "plotly",       # Interactive plots and dashboards

  # Project management
  "here"          # Robust file path construction (already documented in project)
))

# Save the package state
renv::snapshot()
```

**What these packages do:**

| Package | Purpose |
|---------|---------|
| **tidyverse** | Meta-package containing 8 core packages: `ggplot2` (visualization), `dplyr` (data manipulation), `tidyr` (reshaping), `readr` (CSV import), `purrr` (functional programming), `tibble` (modern data frames), `stringr` (text processing), `forcats` (factor handling) |
| **readxl** | Import Excel files without external dependencies |
| **writexl** | Export data frames to Excel format |
| **httr2** | Make HTTP requests to REST APIs (successor to `httr`) |
| **jsonlite** | Parse JSON responses from APIs or web sources |
| **janitor** | Clean messy data: standardize column names, find duplicates, create frequency tables |
| **glue** | Insert R expressions into strings (e.g., `glue("The mean is {mean(x)}")`) |
| **ggtext** | Use Markdown/HTML formatting in plot titles, labels, and annotations |
| **ggrepel** | Automatically position text labels to avoid overlapping points |
| **plotly** | Convert ggplot2 charts to interactive web visualizations |
| **here** | Build file paths relative to project root (works regardless of working directory) |

**Using `here()` for robust file paths:**

The `here` package builds paths relative to your project root, preventing issues when working directories change:

```r
# Load data with here()
data <- read_csv(here::here("data", "raw", "myfile.csv"))

# Source scripts with here()
source(here::here("scripts", "R", "helpers.R"))
```

**Edit `.Rprofile`:** Uncomment the line `source("renv/activate.R")` to auto-activate renv.

**Note on knitr:** Positron has built-in support for Quarto rendering, so `knitr` is not explicitly required in your package library. Quarto will handle code chunk execution automatically.

---

## 🎯 Your First Indicator

Follow this step-by-step tutorial to add an indicator to a chapter.

### Step 1: Create a Branch

```bash
# Create a new branch (use your name and chapter)
git checkout -b yourname/transport

# Verify you're on the new branch
git branch
```

### Step 2: Open a Chapter

Open `chapters/02-transport/index.qmd` in Positron.

### Step 3: Add Your Indicator

Scroll to the "Indicators" section and add a new subsection:

````markdown
## Bus Ridership Trends

### Data

```{r}
#| label: load-bus-data
#| message: false

# Load helper functions
source(here::here("scripts", "R", "helpers.R"))
source(here::here("scripts", "R", "theme_weca.R"))

# Load data
bus_data <- load_csv(here::here("data", "raw", "bus_ridership.csv"))
```

### Analysis

```{r}
#| label: bus-trend-chart
#| fig-cap: "Annual bus ridership in the West of England, 2015-2024"

library(ggplot2)

ggplot(bus_data, aes(x = year, y = ridership)) +
  geom_line(colour = get_weca_color("forest_green"), linewidth = 1.2) +
  geom_point(colour = get_weca_color("forest_green"), size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Bus Ridership Trends",
    x = "Year",
    y = "Annual Ridership (millions)",
    caption = "Source: Local Transport Authority"
  ) +
  theme_weca()
```

### Key Findings

- Bus ridership increased by **15%** between 2015 and 2024
- Peak ridership occurred in 2019 (pre-pandemic)
- Recovery to 2019 levels expected by 2025
````

### Step 4: Render the Chapter

```bash
# Preview in browser with live reload
quarto preview chapters/02-transport/index.qmd

# Or render just this chapter
quarto render chapters/02-transport/index.qmd
```

### Step 5: Commit Your Changes

```bash
# Check what's changed
git status

# Stage the chapter file
git add chapters/02-transport/index.qmd

# Commit with a clear message
git commit -m "Add bus ridership indicator to transport chapter"

# Push to remote
git push -u origin yourname/transport
```

### Step 6: Create a Pull Request

1. Go to GitHub repository
2. Click **"Compare & pull request"**
3. Fill in the PR template (see `CONTRIBUTING.md`)
4. Request a review from a team member

---

## 💻 Essential Git Bash Commands

If you're new to the command line, here are the essential commands:

### Navigation

```bash
# Print working directory (where am I?)
pwd

# List files in current directory
ls

# Change directory
cd projects/indicators

# Go up one level
cd ..

# Go to home directory
cd ~
```

### Git Basics

```bash
# Check status of files
git status

# See what changed
git diff

# Create a new branch
git checkout -b branch-name

# Switch to existing branch
git checkout main

# Stage files for commit
git add filename.qmd
git add .                    # Add all changes (be careful!)

# Commit changes
git commit -m "Your message"

# Push to remote
git push

# Pull latest changes
git pull

# View commit history
git log --oneline
```

### Quarto Commands

```bash
# Render entire book
quarto render

# Render specific chapter
quarto render chapters/01-economy/index.qmd

# Preview with live reload
quarto preview

# Check Quarto version
quarto --version
```

---

## 🔒 Pre-Commit Hook Guide

### What It Does

The pre-commit hook scans your code for:

- `.env` files (blocked automatically)
- API keys (OpenAI, GitHub, AWS, Slack)
- Passwords, tokens, secrets in variable assignments
- High-entropy strings (potential keys)

### What Triggers It

```bash
git commit -m "Your message"
```

### If a Commit Is Blocked

**Example output:**

```
Scanning for secrets...
⚠️  Potential secret detected in data/config.py
    Line 42: Variable assignment with sensitive pattern
❌ Commit blocked - please remove secrets
```

**How to fix:**

1. **Remove the secret** from the file
2. **Move to environment variable:**

   ```python
   import os
   api_key = os.getenv("API_KEY")  # Good ✅
   ```

3. **Add to `.env` file** (automatically ignored by `.gitignore`)
4. **Try commit again**

### False Positives

If the hook blocks a commit incorrectly:

1. Check if it's actually sensitive data
2. If truly a false positive, ask a team lead to review
3. The hook can be updated to exclude specific patterns

**Never use `--no-verify` to bypass the hook** unless explicitly approved.

---

## ❓ Troubleshooting FAQ

### Python Issues

**Q: `uv: command not found`**

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Q: Virtual environment not activating**

```bash
# Recreate virtual environment
rm -rf .venv
uv venv
source .venv/bin/activate
```

### R Issues

**Q: `renv` packages not loading**

```r
# Restore packages from lockfile
renv::restore()

# If that fails, rebuild
renv::rebuild()
```

**Q: Package installation fails**

```r
# Clear cache and retry
renv::purge()
install.packages("package-name")
```

### Quarto Issues

**Q: `quarto: command not found`**

- Restart your terminal after installing Quarto
- Check PATH: `echo $PATH` should include Quarto bin directory

**Q: Render fails with "Kernel error"**

```bash
# Reinstall Jupyter kernel
uv pip install ipykernel --force-reinstall
```

**Q: R code chunks don't execute**

- Ensure `renv` is activated (check `.Rprofile`)
- Verify R packages are installed: `renv::status()`

### Git Issues

**Q: Merge conflicts in `.qmd` files**

1. Open the file in Positron
2. Look for conflict markers: `<<<<<<`, `======`, `>>>>>>`
3. Keep the version you want
4. Remove conflict markers
5. `git add` the resolved file
6. `git commit`

**Q: Accidentally committed to `main` instead of a branch**

```bash
# Create branch from current state
git branch your-feature-branch

# Reset main to remote
git checkout main
git reset --hard origin/main

# Switch back to your branch
git checkout your-feature-branch
```

### General Issues

**Q: Where do I put my data files?**

- Raw data → `data/raw/`
- Processed data → `data/processed/`
- Example data (committed) → `data/examples/`

**Q: How do I reference data files in code?**

Use the `here()` function to build project-relative paths. This works regardless of where you run your code from.

```r
# ✅ Recommended: Use here() for robust paths
data <- load_csv(here::here("data", "raw", "myfile.csv"))
source(here::here("scripts", "R", "helpers.R"))

# ❌ Avoid: Hardcoded relative paths (fragile if working directory changes)
data <- read.csv("data/raw/myfile.csv")
source("scripts/R/helpers.R")

# ❌ Never: Absolute paths (breaks on other machines)
data <- read.csv("C:/Users/yourname/projects/indicators/data/raw/myfile.csv")
```

**When to use `here::i_am()`:**

You don't need `here::i_am()` in .qmd chapter files - Quarto handles the working directory automatically. Only use it in standalone R scripts:

```r
# At the top of scripts/R/my_script.R
here::i_am("scripts/R/my_script.R")
```

**Tip:** The `.Rprofile` loads the `here` package automatically, so you can use `here()` instead of `here::here()`. However, using the full `here::here()` makes code more explicit about where the function comes from.

**Q: Can I use Python instead of R?**
Yes! Both are supported. See `CONTRIBUTING.md` for guidance on when to use each.

---

## 📚 Additional Resources

- **R for Excel Users:** [https://rstudio-conf-2020.github.io/r-for-excel/](https://rstudio-conf-2020.github.io/r-for-excel/)
- **Quarto Documentation:** [https://quarto.org/docs/guide/](https://quarto.org/docs/guide/)
- **Git Tutorial:** [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2)
- **GitHub Desktop:** [https://desktop.github.com/](https://desktop.github.com/) (GUI alternative to Git Bash)
- **RAP Best Practices:** [https://analysisfunction.civilservice.gov.uk/support/reproducible-analytical-pipelines/](https://analysisfunction.civilservice.gov.uk/support/reproducible-analytical-pipelines/)

---

## 🆘 Getting Help

- **Technical issues:** Ask in the Analysts Team Chat
- **Git problems:** See `CONTRIBUTING.md` or ask a team lead
- **Quarto questions:** Check [Quarto documentation](https://quarto.org) first
- **Code review:** Request reviews on your pull requests

**Next step:** Read `CONTRIBUTING.md` for collaboration guidelines →
