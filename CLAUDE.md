# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository (`weca_regional_indicators`) contains the West of England Combined Authority (WECA) regional priorities report - a collaborative Quarto-based book where each analyst contributes a chapter.

**Published report:** [https://westofengland-ca.github.io/weca_regional_indicators/](https://westofengland-ca.github.io/weca_regional_indicators/)

## Architecture

### Repository Structure

Everything lives at the repository root (no nested `projects/` directory):

```
weca_regional_indicators/
├── _quarto.yml          # Quarto configuration (chapter order, themes, execution)
├── _brand.yml           # WECA branding configuration
├── index.qmd            # Report landing page
├── custom.scss          # Custom SCSS styling
├── chapters/            # Modular chapter directories (one per analyst/priority)
│   ├── 01-economy/
│   ├── 02-transport/
│   ├── 03-place/
│   ├── 04-skills/
│   ├── 05-environment/
│   └── 06-child-poverty/
├── data/                # Shared data assets
│   ├── raw/             # Original data files (not committed)
│   ├── processed/       # Cleaned/transformed data (not committed)
│   └── examples/        # Small example datasets (committed)
├── scripts/             # Shared utility scripts
│   ├── R/               # R helper functions and WECA theme
│   ├── python/          # Python utility scripts
│   └── hooks/           # Pre-commit hook scripts
├── _freeze/             # Quarto execution cache (committed)
├── _output/             # Rendered HTML/PDF output (gitignored)
├── pyproject.toml       # Python dependencies (uv-managed)
├── renv.lock            # R package lock file
└── .github/workflows/   # GitHub Actions (publish to GitHub Pages)
```

### Quarto Polyglot Report

**Tech Stack:**

- **Rendering:** Quarto
- **Python:** Managed via `uv` (pyproject.toml-based)
- **R:** Managed via `renv`
- **IDE:** Positron (recommended)

**Architecture Pattern:**

- **Polyglot:** Chapters can use R or Python as needed
- **Modular:** Each chapter has its own directory to prevent merge conflicts
- **Freeze execution:** Chapters only re-render when source changes (`freeze: auto`)
- **Shared resources:** `data/` and `scripts/` directories contain assets used across chapters

**Chapter Structure:**
Each priority area has a dedicated chapter directory under `chapters/`:

- `chapters/01-economy/` - Contributing to national economic growth
- `chapters/02-transport/` - Better public transport connectivity
- `chapters/03-place/` - Affordable/sustainable homes
- `chapters/04-skills/` - Future-ready skills development
- `chapters/05-environment/` - Green jobs and growth
- `chapters/06-child-poverty/` - Lifting families out of poverty

## Working with the Report

### Rendering

```bash
# From the repository root:

# Render entire book (HTML and PDF)
quarto render

# Preview with live reload
quarto preview

# Render specific chapter only
quarto render chapters/05-environment/index.qmd
```

### Environment Setup

**Python (using uv):**

```bash
# Install dependencies from pyproject.toml
uv sync

# Activate virtual environment
uv venv
source .venv/bin/activate  # Unix
.venv\Scripts\activate     # Windows
```

**R (using renv):**

```bash
# Restore R package environment
R -e "renv::restore()"
```

### Adding a New Chapter

1. Create directory: `chapters/XX-topic-name/`
2. Add `index.qmd` file with Quarto frontmatter
3. Update `_quarto.yml` to include the chapter in sidebar navigation
4. Use `freeze: auto` to prevent re-rendering other chapters during development

### Code Display Settings

The report uses code folding to keep output clean:

- `code-fold: true` - Code is hidden by default
- `code-summary: "Show code"` - Toggle to reveal code blocks
- Set chunk options `message: false` and `warning: false` in code blocks

## Quarto Execution Model

**Key concept:** `freeze: auto` prevents R/Python environment conflicts during final assembly. Chapters are cached and only re-executed when their source files change.

**Execution engines:**

- Python chunks use the `uv` virtual environment
- R chunks use the `renv` library
- Jupyter kernel: `python3`

## Data Integration

**Databricks Connection:**
This repository integrates with Databricks for scheduled data updates. Connection details and pipeline configurations should be stored securely (never commit credentials).

**Data locations:**

- `data/` - Project data assets
- Raw data sources should be documented in chapter READMEs
- Processed data should be reproducible via documented scripts

## Output

Rendered reports are written to:

- `_output/` (configured in `_quarto.yml`)

This directory is gitignored - only source files are version controlled. The report is published to GitHub Pages via GitHub Actions.

## Security: Secret Scanning

A pre-commit hook scans staged files for secrets (API keys, tokens, credentials, `.env` files). All hook scripts live in `scripts/hooks/`.

**Setup (run once per clone):**

```bash
bash scripts/hooks/install-hooks.sh
```

**What the hook scans for:**

- `.env` files (blocked automatically)
- API keys (OpenAI, GitHub, AWS, Slack)
- Variable assignments containing passwords, tokens, credentials

**If a commit is blocked:**

1. Remove the secret from the file
2. Move credentials to environment variables or `.env` files (gitignored)
3. For false positives, update exclude patterns in `scripts/hooks/scan_secrets.sh`

**Databricks credentials:**
Never commit Databricks connection strings, tokens, or passwords. Use environment variables or secure configuration management.
