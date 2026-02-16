# .Rprofile - R Environment Configuration
#
# This file is automatically loaded when R starts in this project directory.
# It manages the R package environment using renv for reproducibility.

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

source("renv/activate.R") # UNCOMMENT AFTER RUNNING renv::init()

# ============================================================================
# PROJECT SETTINGS
# ============================================================================

# Load here package for project-relative paths
library(here)

# Set CRAN mirror (UK mirror for faster package downloads)
options(repos = c(CRAN = "https://cran.rstudio.com/"))

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
suppressPackageStartupMessages({
  if (requireNamespace("ragg", quietly = TRUE)) {
    # Set ragg as the default graphics device for knitr/Quarto
    options(bitmapType = "cairo")

    # Configure knitr to use ragg device
    knitr::opts_chunk$set(dev = "ragg_png")

    if (interactive()) {
      cat("✓ Graphics: Using ragg device with systemfonts\n")

      # List available fonts (for debugging)
      if (requireNamespace("systemfonts", quietly = TRUE)) {
        all_fonts <- systemfonts::system_fonts()
        weca_fonts <- all_fonts[grepl("(Open Sans|Trebuchet)",
                                       all_fonts$family, ignore.case = TRUE), ]
        if (nrow(weca_fonts) > 0) {
          cat("✓ WECA fonts detected:\n")
          for (font in unique(weca_fonts$family)) {
            cat("  -", font, "\n")
          }
        }
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
    cat("⚠️  renv not initialized yet\n")
    cat("   Run: renv::init() to set up package management\n")
    cat("   Then uncomment the activation line in .Rprofile\n")
    cat("\n")
  } else if (
    !any(grepl(
      "^[^#]*source\\(.*renv/activate\\.R",
      readLines(".Rprofile", warn = FALSE)
    ))
  ) {
    cat("⚠️  renv is initialized but not activated\n")
    cat("   Uncomment 'source(\"renv/activate.R\")' in .Rprofile\n")
    cat("\n")
  } else {
    cat("✓ renv active\n")
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
