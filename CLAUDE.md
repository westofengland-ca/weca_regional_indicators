# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains data update pipelines and bespoke analysis projects for the West of England Combined Authority (WECA) Analysis & Evaluation team. The repository integrates with Databricks and hosts multiple analytical projects.

**Key projects:**

- `projects/indicators/` - Collaborative Quarto-based regional priorities report

## Architecture

### Multi-Project Structure

The repository uses a project-based organization where each subdirectory under `projects/` represents a distinct analytical initiative:

```
projects/
└── indicators/          # West of England Priority Indicators report
    ├── _quarto.yml      # Quarto configuration (chapter order, themes, execution)
    ├── index.qmd        # Report landing page
    ├── chapters/        # Modular chapter directories (one per analyst/priority)
    ├── data/            # Shared data assets (raw and processed)
    └── scripts/         # Shared utility scripts (Python/R functions)
```

Each project may use different tooling and conventions - check project-specific README files.

### Indicators Project (Quarto Polyglot Report)

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
Each priority area has a dedicated chapter directory:

- `01-economy/` - Contributing to national economic growth
- `02-transport/` - Better public transport connectivity
- `03-place/` - Affordable/sustainable homes
- `04-skills/` - Future-ready skills development
- `05-environment/` - Green jobs and growth
- `06-child-poverty/` - Lifting families out of poverty

## Working with the Indicators Project

### Rendering the Report

```bash
# Navigate to project directory
cd projects/indicators

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

- `projects/indicators/data/` - Project-specific data assets
- Raw data sources should be documented in chapter READMEs
- Processed data should be reproducible via documented scripts

## Output

Rendered reports are written to:

- `projects/indicators/_output/` (configured in `_quarto.yml`)

This directory is typically gitignored - only source files are version controlled.

## Security: Secret Scanning

A pre-commit hook scans staged files under `projects/indicators/` for secrets (API keys, tokens, credentials, `.env` files). All hook scripts live in `projects/indicators/scripts/hooks/`.

**Setup (run once per clone):**

```bash
bash projects/indicators/scripts/hooks/install-hooks.sh
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
