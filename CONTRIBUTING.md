# Contributing to WECA Indicators

Thank you for contributing to the West of England Regional Priorities Indicators project! This guide will help you collaborate effectively with the team.

---

## 📂 Project Structure

```
projects/indicators/
├── chapters/              # One directory per priority area
│   ├── 01-economy/
│   ├── 02-transport/
│   ├── 03-place/
│   ├── 04-skills/
│   ├── 05-environment/
│   └── 06-child-poverty/
├── data/
│   ├── raw/              # Original data files (not committed)
│   ├── processed/        # Cleaned/transformed data (not committed)
│   └── examples/         # Small example datasets (committed)
├── scripts/
│   ├── R/                # Shared R functions
│   └── python/           # Shared Python functions
├── _quarto.yml           # Book configuration
└── index.qmd             # Landing page
```

---

## 🤝 Collaborative Rendering: How the Freeze Workflow Works

**The Core Problem:** Each analyst has their own data on their machine. How do we render the full book without requiring everyone's data in one place?

**The Solution:** Quarto's `freeze: auto` mode caches execution results so analysts can share outputs without sharing raw data.

### Understanding Freeze Mode

When you render your chapter with `freeze: auto` enabled:

1. **Quarto executes your code** (Python/R) using your local data
2. **All outputs are cached** (plots, tables, results) in the `_freeze/` directory
3. **You commit both source and cache** to git
4. **Others render the full book** using your cached outputs
5. **Their Quarto skips re-executing your code** - uses cached results instead
6. **Only modified chapters re-execute** when source files change

### What Gets Shared vs. Local

| Item | Location | Git Tracked | Why |
|------|----------|-------------|-----|
| **Source code** (`.qmd`) | `chapters/XX-topic/` | ✅ Yes | Your analysis narrative |
| **Cached outputs** | `_freeze/` | ✅ Yes | Rendered plots, tables, results |
| **Raw data** | `data/raw/` | ❌ No | Often sensitive, stays local |
| **Processed data** | `data/processed/` | ❌ No | Intermediate datasets |
| **Final HTML/PDF** | `_output/` | ❌ No | Generated from cache |

### Step-by-Step Collaborative Workflow

#### 1️⃣ **You:** Work on Your Chapter

```bash
cd projects/indicators

# Edit your chapter
code chapters/05-environment/index.qmd

# Render your chapter (generates cache)
quarto render chapters/05-environment/index.qmd
```

**What happens:**
- Quarto runs your Python/R code with your local data
- Generates plots, tables, calculations
- Saves results to `_freeze/html/chapters/05-environment/`

#### 2️⃣ **You:** Commit Source AND Cache

```bash
# Critical: Commit BOTH files
git add chapters/05-environment/index.qmd
git add _freeze/html/chapters/05-environment/

git commit -m "Update environment chapter: add renewable energy analysis"
git push
```

**Important:** If you forget to commit `_freeze/`, others can't render the book!

#### 3️⃣ **Others:** Render Full Book Without Your Data

```bash
git pull  # Get your changes

quarto render  # Render full book
```

**What happens:**
- Quarto sees your `_freeze/` cache is up to date
- Uses your cached outputs instead of re-executing your code
- Assembles all chapters into complete book
- Only re-executes chapters where source files changed

### Common Scenarios

#### **Scenario: You update your chapter**

```bash
# Edit your chapter
nano chapters/05-environment/index.qmd

# Re-render to update cache
quarto render chapters/05-environment/index.qmd

# Commit both source and updated cache
git add chapters/05-environment/
git add _freeze/html/chapters/05-environment/
git commit -m "Add solar panel installation trends"
git push
```

#### **Scenario: You want to force re-execution**

```bash
# Force refresh even if source unchanged (e.g., data updated)
quarto render chapters/05-environment/index.qmd --execute-freeze refresh
```

#### **Scenario: Someone forgot to commit _freeze/**

**Symptom:** Rendering fails with "data file not found" for their chapter

**Fix:** Ask them to:
```bash
quarto render chapters/XX-topic/index.qmd
git add _freeze/
git commit -m "Add missing freeze cache"
git push
```

#### **Scenario: Merge conflict in _freeze/**

**Rare but possible if two people edit the same chapter simultaneously**

```bash
# Delete your local freeze cache for that chapter
rm -rf _freeze/html/chapters/XX-topic/

# Re-render your version
quarto render chapters/XX-topic/index.qmd

# Commit fresh cache
git add _freeze/
git commit -m "Resolve freeze cache conflict"
```

### Checking Cache Status

**Preview what will re-execute:**
```bash
quarto render --dry-run
```

**Force re-render everything:**
```bash
quarto render --execute-freeze refresh
```

**Render just your chapter for testing:**
```bash
quarto render chapters/05-environment/index.qmd
```

### Troubleshooting

#### "Full book won't render - missing data file"

**Cause:** Someone didn't commit their `_freeze/` cache

**Fix:**
1. Check which chapter is failing
2. Ask that person to render their chapter and commit `_freeze/`
3. Pull their changes and try again

#### "My chapter re-executes every time even though I didn't change it"

**Cause:** Source file timestamp changed (e.g., git operations)

**Fix:**
```bash
# Clear cache and re-render once
rm -rf _freeze/html/chapters/XX-topic/
quarto render chapters/XX-topic/index.qmd
```

#### "_freeze/ directory is huge in git"

**Unlikely but possible with many large plots**

**Fix:**
- Optimize figure sizes in code chunks (`fig-width`, `fig-height`, `dpi`)
- Use compressed formats (PNG instead of SVG for complex plots)
- Consider Git LFS (ask team lead)

### Quick Reference

| Task | Command |
|------|---------|
| Render your chapter | `quarto render chapters/XX-topic/index.qmd` |
| Render full book | `quarto render` |
| Preview with live reload | `quarto preview` |
| Force re-execute | `quarto render --execute-freeze refresh` |
| Check what will run | `quarto render --dry-run` |

---

## 🌿 Git Workflow

### Branch Naming Convention

Use this pattern: `yourname/chapter-or-feature`

**Examples:**

- `heather/transport` - Heather working on transport chapter
- `alex/environment` - Alex working on environment chapter
- `sarah/weca-theme-update` - Sarah updating the WECA theme

**Rules:**

- ✅ Use lowercase
- ✅ Use hyphens to separate words
- ✅ Include your name or initials
- ❌ Don't use spaces or special characters

### Creating a Branch

```bash
# Start from main
git checkout main
git pull

# Create and switch to new branch
git checkout -b yourname/chapter-name

# Verify you're on the right branch
git branch
```

---

## 💬 Commit Messages

Write clear, concise commit messages that explain **what changed and why**.

### Format

Use the **imperative mood** (like giving a command):

```
✅ Add bus ridership indicator
✅ Fix data loading error in transport chapter
✅ Update WECA color palette
✅ Remove outdated employment data
```

**Not this:**

```
❌ Added stuff
❌ Fixed things
❌ Updates
❌ WIP
```

### Commit Message Template

```
<action> <what changed>

Optional: More details if needed
- Why this change was made
- Any relevant context
- Related issue numbers
```

**Examples:**

```
Add housing affordability indicator to place chapter

Includes:
- Data from ONS housing market statistics
- Trend analysis 2015-2024
- Comparison with national average
```

```
Fix percentage calculation in skills indicator

The previous formula didn't account for null values,
causing incorrect percentages in some years.
```

### Commit Frequency

- **Commit often** - small, logical chunks
- **One feature per commit** - easier to review and revert
- **Test before committing** - ensure code runs

```bash
# Good workflow
git add chapters/02-transport/index.qmd
git commit -m "Add bus ridership indicator"

git add chapters/02-transport/index.qmd
git commit -m "Add rail passenger numbers indicator"

# Not this
git add .
git commit -m "Finished transport chapter"
```

---

## 🔄 Pull Request Workflow

### 1. Before Creating a PR

**Checklist:**

- [ ] Code runs without errors (`quarto render chapters/XX-topic/index.qmd`)
- [ ] All charts have titles, labels, and data sources
- [ ] No hardcoded file paths (use relative paths from project root)
- [ ] Code is commented where logic isn't obvious
- [ ] Data sources are documented in the chapter
- [ ] Pre-commit hook passes (no secrets detected)

### 2. Create the Pull Request

```bash
# Push your branch to remote
git push -u origin yourname/chapter-name
```

On GitHub:

1. Click **"Compare & pull request"**
2. Fill in the PR template (see below)
3. Assign a reviewer
4. Add relevant labels

### 3. PR Template

```markdown
## Summary
Brief description of what this PR adds or changes.

## Changes
- Added bus ridership indicator (2015-2024)
- Updated transport chapter introduction
- Created helper function for percentage calculations

## Checklist
- [x] Code runs without errors
- [x] Charts have titles, labels, sources
- [x] Data sources documented
- [x] Code is commented
- [ ] Peer reviewed

## Data Sources
- Bus ridership data: Local Transport Authority annual reports
- Population data: ONS mid-year estimates

## Screenshots (optional)
[Attach chart images if helpful]
```

### 4. Responding to Review Comments

- Address all comments before merging
- Push new commits to the same branch
- Mark conversations as resolved when fixed
- Thank reviewers for their time

### 5. Merging

**After approval:**

```bash
# Option 1: Merge via GitHub UI
# Click "Squash and merge" or "Merge pull request"

# Option 2: Command line
git checkout main
git pull
git merge yourname/chapter-name
git push
```

**Clean up your branch:**

```bash
git branch -d yourname/chapter-name          # Delete local
git push origin --delete yourname/chapter-name  # Delete remote
```

---

## 🎨 Code Style Guide

### When to Use R vs. Python

**Use R when:**

- ✅ Working with statistical models (regression, hypothesis tests)
- ✅ Creating publication-quality visualizations with ggplot2
- ✅ Following existing R patterns in the chapter
- ✅ You're more comfortable with R

**Use Python when:**

- ✅ Processing large datasets (>1GB) - use `polars`
- ✅ Web scraping or API calls
- ✅ Machine learning or advanced data transformations
- ✅ You're more comfortable with Python

**Either is fine for:**

- Basic data wrangling
- Simple calculations
- Reading CSV/Excel files

### R Style

**General principles:**

- Use `<-` for assignment (not `=`)
- Use snake_case for variable names
- Load packages at the top of code chunks
- Use relative paths from the project root for file paths

**Example:**

```r
#| label: load-data

library(dplyr)
library(ggplot2)
source(here::here("scripts", "R", "theme_weca.R"))

# Load and process data
employment_data <- load_csv(here::here("data", "raw", "employment.csv")) %>%
  filter(year >= 2015) %>%
  mutate(
    employment_rate = safe_divide(employed, total_population) * 100
  )

# Visualize
ggplot(employment_data, aes(x = year, y = employment_rate)) +
  geom_line(colour = get_weca_color("forest_green")) +
  theme_weca() +
  labs(
    title = "Employment Rate Trend",
    x = "Year",
    y = "Employment Rate (%)"
  )
```

### Python Style

**General principles:**

- Follow PEP 8 (enforced by `ruff` and `black`)
- Use snake_case for variables and functions
- Add type hints where helpful
- Use `pathlib.Path` for file paths

**Example:**

```python
#| label: load-data

import polars as pl
from pathlib import Path

# Build project-relative path
project_root = Path(__file__).parent.parent  # Adjust based on script location
data_path = project_root / "data" / "raw" / "employment.csv"
df = pl.read_csv(data_path)

# Process
employment_data = (
    df
    .filter(pl.col("year") >= 2015)
    .with_columns([
        (pl.col("employed") / pl.col("total_population") * 100)
        .alias("employment_rate")
    ])
)

# Visualize
import matplotlib.pyplot as plt

plt.plot(employment_data["year"], employment_data["employment_rate"])
plt.title("Employment Rate Trend")
plt.xlabel("Year")
plt.ylabel("Employment Rate (%)")
plt.show()
```

### Quarto Code Chunk Options

**Standard settings:**

```r
#| label: descriptive-name
#| message: false
#| warning: false
#| fig-cap: "Descriptive caption for accessibility"
```

**Hide code by default** (already set globally):

- `code-fold: true` is in `_quarto.yml`
- Users can toggle code visibility

**When to show code:**

```r
#| code-fold: false

# Show this code for teaching purposes
```

---

## 📁 File Naming Conventions

### Data Files

**Format:** `descriptor_YYYY-MM-DD.ext`

**Examples:**

- `bus_ridership_2024-01-15.csv`
- `housing_prices_processed_2024-02-01.csv`
- `employment_ONS_2024-01-20.xlsx`

**Rules:**

- Use lowercase
- Use underscores to separate words
- Include date stamp for time-sensitive data
- Include source if helpful (e.g., `_ONS`, `_DfT`)

### Script Files

**Format:** `purpose_description.ext`

**Examples:**

- `theme_weca.R` ✅
- `data_cleaning_utilities.py` ✅
- `plot_helper_functions.R` ✅

---

## 👥 Peer Review Checklist

Use this checklist when reviewing someone else's pull request.

### Code Quality

- [ ] Code runs without errors
- [ ] Code is well-commented (complex logic explained)
- [ ] No hardcoded paths (uses relative paths from project root or `Path`)
- [ ] No secrets or API keys in code
- [ ] Functions have clear names and purposes

### Data Handling

- [ ] Data sources are documented in the chapter
- [ ] Data files are in correct directories (`data/raw/`, `data/processed/`)
- [ ] Large data files are not committed (.gitignore working)
- [ ] Data transformations are reproducible

### Visualization & Output

- [ ] Charts have descriptive titles
- [ ] Axes are labeled with units
- [ ] Data sources are cited in captions or footnotes
- [ ] Charts use WECA color palette (when appropriate)
- [ ] Figures have alt text for accessibility

### Analysis Quality

- [ ] Calculations are correct (spot-check a few)
- [ ] Methodology is clearly explained
- [ ] Key findings are highlighted
- [ ] Limitations or caveats are noted (if applicable)

### Accessibility

- [ ] Alt text provided for figures (`fig-cap:` in code chunks)
- [ ] Color choices are colorblind-friendly
- [ ] Text is clear and jargon-free
- [ ] Headings follow logical hierarchy

### Quarto/Markdown

- [ ] YAML frontmatter is correct
- [ ] Sections are properly structured (##, ###)
- [ ] Code chunks have labels (`#| label:`)
- [ ] Chapter renders successfully

---

## 🚫 What NOT to Commit

**Never commit:**

- ❌ `.env` files (blocked by pre-commit hook)
- ❌ API keys, passwords, tokens
- ❌ Large data files (>10MB)
- ❌ Rendered outputs (`.html`, `.pdf`) - these are generated
- ❌ Personal credentials or sensitive data

**Why?**

- Git history is permanent - secrets can't be easily removed
- Large files bloat the repository
- Rendered outputs should be generated fresh

**What to do instead:**

- Use environment variables for secrets
- Store large files in shared drives or Databricks
- Add patterns to `.gitignore`

---

## 🆘 Common Scenarios

### Scenario 1: Merge Conflict

**What happened:** Two people edited the same file.

**How to resolve:**

```bash
# Pull latest changes
git pull origin main

# Git will mark conflicts in your files
# Open the file and look for:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> main

# Choose which version to keep (or combine them)
# Remove the conflict markers
# Save the file

# Mark as resolved
git add filename.qmd
git commit -m "Resolve merge conflict in transport chapter"
```

### Scenario 2: Accidentally Committed to Main

**Fix:**

```bash
# Create branch from current state
git branch yourname/chapter-name

# Reset main to match remote
git checkout main
git reset --hard origin/main

# Your changes are safe on the new branch
git checkout yourname/chapter-name
```

### Scenario 3: Need to Undo Last Commit

```bash
# Undo commit but keep changes
git reset --soft HEAD~1

# Undo commit and discard changes (careful!)
git reset --hard HEAD~1
```

### Scenario 4: Want to Update Branch with Latest Main

```bash
# On your feature branch
git checkout yourname/chapter-name

# Get latest main
git fetch origin main

# Merge main into your branch
git merge origin/main

# Or rebase (cleaner history)
git rebase origin/main
```

---

## 📊 Quality Standards

All indicators should meet these standards:

### Data Quality

- ✅ Data sources are reputable (ONS, DfT, local authorities)
- ✅ Data is recent (within last 5 years unless historical trends needed)
- ✅ Sample sizes are adequate
- ✅ Limitations are acknowledged

### Analysis Quality

- ✅ Methods are appropriate for the data type
- ✅ Calculations are reproducible
- ✅ Assumptions are stated
- ✅ Uncertainty is quantified (where applicable)

### Presentation Quality

- ✅ Clear narrative explaining what the indicator shows
- ✅ Context provided (e.g., national comparisons)
- ✅ Visualizations are appropriate for data type
- ✅ Key findings are highlighted

### Accessibility

- ✅ Plain English (avoid jargon)
- ✅ Charts have alt text
- ✅ Color choices work for colorblind readers
- ✅ Logical heading structure

---

## 🎓 Learning Resources

### Git & GitHub

- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [GitHub Flow Guide](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Oh Shit, Git!?!](https://ohshitgit.com/) - Fixing common mistakes

### R

- [R for Data Science](https://r4ds.had.co.nz/)
- [ggplot2 Cheat Sheet](https://rstudio.github.io/cheatsheets/data-visualization.pdf)
- [Tidyverse Style Guide](https://style.tidyverse.org/)

### Python

- [Python for Data Analysis](https://wesmckinney.com/book/)
- [Polars User Guide](https://pola-rs.github.io/polars-book/)
- [PEP 8 Style Guide](https://pep8.org/)

### Quarto

- [Quarto Guide](https://quarto.org/docs/guide/)
- [Quarto for Academics](https://quarto.org/docs/manuscripts/)
- [Quarto Gallery](https://quarto.org/docs/gallery/)

---

## 💡 Tips for Success

1. **Start small** - Don't try to add 10 indicators at once
2. **Ask questions early** - Don't struggle in silence
3. **Review others' work** - You'll learn by seeing different approaches
4. **Document as you go** - Don't wait until the end to add comments
5. **Test frequently** - Render often to catch errors early
6. **Use the templates** - Chapters have worked examples to copy
7. **Commit often** - Small commits are easier to review and debug

---

## ✅ Final Checklist Before Submitting PR

- [ ] Code runs without errors
- [ ] Data sources documented
- [ ] Charts have titles, labels, sources
- [ ] No hardcoded file paths (use relative paths from project root)
- [ ] No secrets in code
- [ ] Code is commented
- [ ] Pre-commit hook passes
- [ ] Branch is up to date with main
- [ ] PR description is complete
- [ ] Reviewer assigned

---

**Questions?** Ask in the Analysts Team Chat or tag a team lead on GitHub.

**Next step:** See `QA_CHECKLIST.md` for detailed quality assurance guidelines →
