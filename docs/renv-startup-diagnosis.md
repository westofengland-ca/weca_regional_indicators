# renv Startup Diagnosis

## Problem

R language server (VS Code / Positron) fails intermittently with:

```
Error: ! Could not start R session, timed out
read ECONNRESET
Connection to server got closed. Server will not be restarted.
R Language Server exited with exit code null
```

## Root Cause

renv 1.2.0 calls `renv::status()` (a full lock-file diff scan) on **every** R session
start via `renv_load_report_synchronized`. This took ~1.4 s, pushing total startup
past the language server's session-init timeout.

Measured breakdown (project root, normal startup):

| Step | Time |
|---|---|
| Baseline R start (`--vanilla`) | 0.17 s |
| + `source("renv/activate.R")` default | 2.0 s |
| + `source("renv/activate.R")` with sync check disabled | 0.6 s |
| Full `.Rprofile` before fix | 2.3 s |
| Full `.Rprofile` after fix | 0.85 s |

Confirmed with `RENV_STARTUP_DIAGNOSTICS=TRUE` — top call chain:

```
renv::load → renv_load_finish → renv_load_report_synchronized → status()
  → renv_lockfile_create → renv_package_dependencies (reads all DESCRIPTION files)
```

## Fix

**`.Renviron`** (project root, new file):
```
RENV_CONFIG_SYNCHRONIZED_CHECK=FALSE
```
Loaded before `.Rprofile`, so renv sees it before `activate.R` runs.

**`_quarto.yml`** — moved `dev: ragg_png` here under `knitr: opts_chunk:`
(correct place for a render-time knitr option; removes a spurious knitr namespace
load from every non-rendering R session).

**`.Rprofile`** — removed `knitr::opts_chunk$set(dev = "ragg_png")`.

## Key Commands

```r
# Check sync status manually (since auto-check is now disabled)
renv::status()

# Re-enable diagnostic profiling for future startup investigations
Sys.setenv(RENV_STARTUP_DIAGNOSTICS = "TRUE")
source("renv/activate.R")
```
