# Contributing to Chapter 04: Future-Ready Skills

A step-by-step guide for Megan (and anyone else) contributing to this chapter for the first time. No prior git or GitHub experience assumed.

---

## Prerequisites

Install the following before you start. Tick each one off before moving on.

| Tool | Purpose | Download |
|------|---------|----------|
| **Git** | Version control | <https://git-scm.com/download/win> |
| **R 4.5+** | Analysis language | <https://cran.r-project.org/> |
| **Quarto** | Report rendering | <https://quarto.org/docs/get-started/> |
| **Positron** (recommended) | IDE | <https://positron.posit.co/> |
| **GitHub account** | To submit your work | <https://github.com> |

Once Git is installed, open a terminal (PowerShell or Git Bash) and configure your identity — Git stamps this on every change you make:

---

## Authenticating to GitHub

GitHub no longer accepts your GitHub password when pushing from the terminal. You need to set up authentication once before your first push.

### Option 1: GitHub CLI (easiest, but requires admin)

Install from <https://cli.github.com> — note this requires an IT admin remote login on a managed laptop. Once installed:

```powershell
gh auth login
```

Follow the prompts — it opens a browser, you log in, and Git uses it automatically from then on.

### Option 2: Personal Access Token — PAT (most likely on a managed laptop)

1. Log in to GitHub in your browser.
2. Go to **Settings → Developer settings → Personal access tokens → Tokens (classic)**.
3. Click **Generate new token (classic)**.
4. Give it a name (e.g. "weca laptop"), set an expiry (90 days is reasonable), and tick the **repo** scope.
5. Click **Generate token** and copy it immediately — you cannot see it again after leaving the page.

When you run `git push` for the first time, Git will ask for your GitHub username and password. Enter:
- **Username:** your GitHub username
- **Password:** paste the token (not your GitHub account password)

Windows Credential Manager will cache this, so you only need to do it once. If it ever stops working (token expired), generate a new one and repeat.

---

```powershell
git config --global user.name "Megan Surname"
git config --global user.email "megan@example.com"
```

---

## Part 1: Get the Repository

Clone the repository to your laptop. In PowerShell or Git Bash, navigate to where you keep projects, then run:

```powershell
git clone https://github.com/westofengland-ca/weca_regional_indicators.git
cd weca_regional_indicators
```

(Ask Steve for the exact URL if you are unsure.)

---

## Part 2: Set Up Your Local Environment

### 2.1 Install R packages (renv)

Open the project in Positron (or RStudio) by opening the `weca_regional_indicators.Rproj` file. R should automatically prompt you to restore packages. If it doesn't, run in the R console:

```r
renv::restore()
```

This installs exactly the right versions of all R packages. It may take a few minutes the first time.

### 2.2 Install the pre-commit hook

This runs a secret scanner each time you commit, to make sure you never accidentally commit passwords or API keys:

```powershell
bash scripts/hooks/install-hooks.sh
```

---

## Part 3: Create a Working Branch

Never work directly on `main`. Instead, create a branch named after what you are adding:

```powershell
git checkout -b feature/skills-indicator-apprenticeships
```

Replace `apprenticeships` with whatever your indicator is. Branch names should be lowercase with hyphens, no spaces.

---

## Part 4: Write Your Indicator

### 4.1 Your chapter file

Your chapter lives at:

```
chapters/04-skills/index.qmd
```

Open it and follow the placeholder structure that is already there. Each indicator gets its own section heading. Keep narrative text in plain prose — code goes in R code chunks.

### 4.2 Load shared helpers

The first code chunk in the file already does this — do not remove it:

```r
library(tidyverse)
source(here::here("scripts", "R", "_common.R"))
```

This gives you the WECA theme, data loaders, and FACT table helpers.

### 4.3 Raw data

Put any downloaded data files in `data/raw/`. This folder is gitignored — raw files are never committed to the repository.

### 4.4 Save your indicator data to the FACT table

When your data is ready, write it to the shared FACT table so it appears in the report summary. Your wrangled data must have exactly three columns before you call `build_fact()`:

| Column | Type | Example |
|--------|------|---------|
| `period_start` | Date | `2023-01-01` |
| `period_end` | Date | `2023-12-31` |
| `value` | numeric | `12345.6` |

```r
# 1. Wrangle to exactly these three columns
my_tbl <- raw_data |>
  group_by(year) |>
  summarise(value = sum(count, na.rm = TRUE)) |>
  transmute(
    period_start = as.Date(paste0(year, "-01-01")),
    period_end   = as.Date(paste0(year, "-12-31")),
    value        = value
  )

# 2. Validate and stamp with your indicator ID
fact_tbl <- build_fact(my_tbl, indicator_id = "RI_4_apprenticeships")

# 3. Write to data/fact/RI_4_apprenticeships.csv
save_fact(fact_tbl)
```

The file lands in `data/fact/` and is automatically included when the report renders.

**Choosing an indicator ID:** Follow the pattern `RI_4_short_name` — the `4` refers to chapter 04 (Skills). Keep it lowercase with underscores. Add your indicator to the table in `chapters/04-skills/README.md`.

### 4.5 Preview your chapter locally

To check your chapter looks right before submitting:

```powershell
quarto render chapters/04-skills/index.qmd
```

Open the resulting HTML in `_output/` to review it. Fix any errors before moving on.

---

## Part 5: Commit Your Changes

### 5.1 Check what files you have changed

```powershell
git status
```

You should see your edited files listed. Typical changes:

- `chapters/04-skills/index.qmd` — your chapter content
- `chapters/04-skills/README.md` — updated indicator table
- `data/fact/RI_4_something.csv` — your FACT data file
- `_freeze/chapters/04-skills/...` — Quarto cache files (commit these)

### 5.2 Stage the files you want to commit

You can stage a whole folder at once, or use a pattern to match multiple files:

```powershell
# Stage everything in your chapter folder and its freeze cache
git add chapters/04-skills/ _freeze/chapters/04-skills/

# Stage all your FACT CSV files at once using a wildcard
git add data/fact/RI_4_*.csv
```

Avoid `git add .` — it stages every changed file in the repo, which can accidentally include large data files or unfinished work from other folders.

### 5.3 Commit with a clear message

```powershell
git commit -m "feat: add apprenticeship indicator to skills chapter"
```

Commit message rules:

- Start with `feat:` for new content, `fix:` for corrections, `docs:` for text-only changes
- Keep the first line under 50 characters
- Use the present tense ("add indicator" not "added indicator")

If the pre-commit hook blocks your commit, it has found something that looks like a secret (password, API key, etc.). Remove it from the file and try again.

---

## Part 6: Push and Open a Pull Request

### 6.1 Push your branch

```powershell
git push origin feature/skills-indicator-apprenticeships
```

### 6.2 Open a Pull Request on GitHub

1. Go to the repository on GitHub (`github.com/westofengland-ca/weca_regional_indicators`).
2. You should see a yellow banner saying your branch was recently pushed — click **Compare & pull request**.
3. Check the base branch is `main`.
4. Write a short title and description explaining what indicator you have added and where the data comes from.
5. Click **Create pull request**.

### 6.3 What happens next

Steve (or another reviewer) will look at your pull request. They may leave comments asking for changes. If they do:

1. Make the changes in your local files.
2. Commit and push again to the same branch — the pull request updates automatically.
3. Reply to comments on GitHub to let the reviewer know you have addressed them.

Once approved, the pull request gets merged into `main`, and the GitHub Actions workflow publishes the updated report to GitHub Pages automatically (usually within a few minutes).

---

## Part 7: Keeping Up to Date

Other analysts may merge changes while you are working. Before starting a new piece of work, pull the latest from `main`:

```powershell
git checkout main
git pull origin main
```

Then create a new branch for your next piece of work.

---

## Quick Reference

| Task | Command |
|------|---------|
| Check what has changed | `git status` |
| Create a new branch | `git checkout -b feature/my-branch-name` |
| Stage a folder | `git add chapters/04-skills/` |
| Stage by pattern | `git add data/fact/RI_4_*.csv` |
| Commit staged files | `git commit -m "feat: description"` |
| Push to your fork | `git push origin feature/my-branch-name` |
| Preview your chapter | `quarto render chapters/04-skills/index.qmd` |
| Sync with the main repo | `git fetch upstream && git merge upstream/main` |

---

## Getting Help

- **Chapter template and indicator table:** `chapters/04-skills/README.md`
- **FACT helper documentation:** `scripts/R/fact_helpers.R` (read the top section)
- **Worked example of a full indicator:** `chapters/05-environment/index.qmd`
- **Questions about the workflow:** ask Steve
