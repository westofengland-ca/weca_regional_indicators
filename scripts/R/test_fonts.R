# Test script to debug font registration

library(showtext)
library(sysfonts)

cat("Testing font registration...\n\n")

# Test 1: Load Open Sans from Google
cat("1. Loading Open Sans from Google Fonts...\n")
tryCatch({
  font_add_google("Open Sans", "Open Sans")
  cat("   ✓ Success\n\n")
}, error = function(e) {
  cat("   ✗ Error:", conditionMessage(e), "\n\n")
})

# Test 2: Try to find Trebuchet MS in Windows fonts directory
cat("2. Looking for Trebuchet MS font files...\n")
windows_fonts <- "C:/Windows/Fonts"
trebuc_files <- list.files(windows_fonts, pattern = "trebuc.*\\.ttf",
                           ignore.case = TRUE, full.names = TRUE)
cat("   Found:", length(trebuc_files), "files\n")
if (length(trebuc_files) > 0) {
  cat("   Files:\n")
  for (f in trebuc_files) cat("    -", basename(f), "\n")
}
cat("\n")

# Test 3: Try registering Trebuchet using full paths
cat("3. Attempting to register Trebuchet MS...\n")
tryCatch({
  font_add("Trebuchet",
           regular = file.path(windows_fonts, "trebuc.ttf"),
           bold = file.path(windows_fonts, "trebucbd.ttf"),
           italic = file.path(windows_fonts, "trebucit.ttf"),
           bolditalic = file.path(windows_fonts, "trebucbi.ttf"))
  cat("   ✓ Success\n\n")
}, error = function(e) {
  cat("   ✗ Error:", conditionMessage(e), "\n\n")
})

# Test 4: List all registered fonts
cat("4. Currently registered font families:\n")
families <- font_families()
for (f in families) cat("   -", f, "\n")
cat("\n")

# Test 5: Alternative - check systemfonts package
cat("5. Checking systemfonts for Trebuchet...\n")
if (requireNamespace("systemfonts", quietly = TRUE)) {
  sys_fonts <- systemfonts::system_fonts()
  trebuc <- sys_fonts[grepl("trebuchet", sys_fonts$family, ignore.case = TRUE), ]
  if (nrow(trebuc) > 0) {
    cat("   Found Trebuchet fonts:\n")
    print(trebuc[, c("family", "style", "path")])
  } else {
    cat("   No Trebuchet fonts found by systemfonts\n")
  }
}
