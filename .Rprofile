# .Rprofile - R Environment Configuration
#
# This file is automatically loaded when R starts in this project directory.
# It manages the R package environment using renv for reproducibility.

# Activate renv FIRST so all subsequent package loads use the project library.
# (vscode-R init below loads languageserver/httpgd which pull in rlang - if
# renv isn't active yet, they load from the system library and pin the wrong
# rlang namespace for the whole session.)
source("renv/activate.R")

# vscode-R session watcher: enables workspace viewer, help panel, plot viewer
# (must be here because project .Rprofile overrides ~/.Rprofile)
if (interactive() && Sys.getenv("RSTUDIO") == "") {
  local({
    # Ensure R_HOME is set so vscode-R can resolve help file paths on Windows
    if (nchar(Sys.getenv("R_HOME")) == 0) {
      Sys.setenv(R_HOME = R.home())
    }

    init_script <- file.path(
      Sys.getenv("USERPROFILE"),
      ".vscode-R", "init.R"
    )
    if (file.exists(init_script)) source(init_script)
  })

  # vsc options: control where panels open and what the workspace viewer shows
  options(
    vsc.helpPanel = "Two", # help opens in editor group 2
    vsc.view = "Two", # View() opens in editor group 2
    vsc.viewer = "Two", # htmlwidgets open in editor group 2
    vsc.str.max.level = 2, # show nested list/df structure in workspace viewer
    vsc.show_object_size = TRUE, # show object size in workspace viewer tooltips
    vsc.use_httpgd = TRUE # consistent with r.plot.useHttpgd: true in settings
  )
}

# ============================================================================
# RENV SETUP (Currently Commented Out)
# ============================================================================
#
# Uncomment the line below AFTER you have initialized renv:
#
# Step 1: Install renv if you haven't already
#   install.packages("renv")
#
# Step 2: Initialize renv for this project (run once)
#   renv::init()
#
# Step 3: Uncomment the activation line below
#
# Step 4: Install required packages
#   install.packages(c("ggplot2", "dplyr", "readr", "tidyr", "knitr"))
#
# Step 5: Save the package state
#   renv::snapshot()
#
# After initialization, other team members can restore your exact environment:
#   renv::restore()
#
# ============================================================================
# (renv activated at top of file)

# ============================================================================
# PROJECT SETTINGS
# ============================================================================

# Set CRAN mirror (UK mirror for faster package downloads)
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))
# options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Increase width for better console output
options(width = 120)

# Disable scientific notation for better readability of large numbers
options(scipen = 999)

# Set default number of digits to display
options(digits = 4)

# Improve error messages
options(show.error.locations = TRUE)

# ============================================================================
# FONT CONFIGURATION FOR GRAPHICS
# ============================================================================

# Configure ragg graphics device for proper font support (R 4.3+)
# ragg integrates with systemfonts to automatically find system fonts
if (interactive()) suppressPackageStartupMessages({
  if (requireNamespace("ragg", quietly = TRUE)) {
    options(bitmapType = "cairo")
    cat("[OK] Graphics: Using ragg device with systemfonts\n")
    if (requireNamespace("systemfonts", quietly = TRUE)) {
      all_fonts <- systemfonts::system_fonts()
      weca_fonts <- all_fonts[
        grepl("(Open Sans|Trebuchet)", all_fonts$family, ignore.case = TRUE),
      ]
      if (nrow(weca_fonts) > 0) {
        cat("[OK] WECA fonts detected:\n")
        for (font in unique(weca_fonts$family)) cat("  -", font, "\n")
      }
    }
  }
})

# ============================================================================
# STARTUP MESSAGE
# ============================================================================

if (interactive()) {
  cat("\n")
  cat("=================================================\n")
  cat("  WECA Regional Priorities - Indicators Project  \n")
  cat("=================================================\n")
  cat("\n")
  cat("Project directory: ", getwd(), "\n")
  cat("\n")

  # Check if renv is initialized
  if (!file.exists("renv/activate.R")) {
    cat("[WARN] renv not initialized yet\n")
    cat("   Run: renv::init() to set up package management\n")
    cat("   Then uncomment the activation line in .Rprofile\n")
    cat("\n")
  } else if (
    !any(grepl(
      "^[^#]*source\\(.*renv/activate\\.R",
      readLines(".Rprofile", warn = FALSE)
    ))
  ) {
    cat("[WARN] renv is initialized but not activated\n")
    cat("   Uncomment 'source(\"renv/activate.R\")' in .Rprofile\n")
    cat("\n")
  } else {
    cat("[OK] renv active\n")
    cat("\n")
  }

  # Remind about shared scripts
  cat("Shared resources:\n")
  cat("  - WECA theme: source(here('scripts', 'R', 'theme_weca.R'))\n")
  cat("  - Helpers: source(here('scripts', 'R', 'helpers.R'))\n")
  cat("  - Use here() for all file paths relative to project root\n")
  cat("\n")
  cat("=================================================\n")
  cat("\n")
}
