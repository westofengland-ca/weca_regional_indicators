# VS Code R Configuration Notes

Session notes from configuring vscode-R sidebar, workspace viewer, help panel, and data viewer on Windows.

---

## Status

| Feature | Status |
|---|---|
| Workspace viewer (Global Environment) | Working |
| Clicking objects → data viewer (`View()`) | Working |
| Help panel (`?function`) | Pending — restart VS Code after path fix below |

---

## What Was Done

### 1. Created `~/.Rprofile`

No user-level `.Rprofile` existed. Created `C:/Users/steve.crawshaw/.Rprofile`:

```r
if (interactive() && Sys.getenv("RSTUDIO") == "") {
  local({
    if (nchar(Sys.getenv("R_HOME")) == 0) {
      Sys.setenv(R_HOME = R.home())
    }
    init_script <- file.path(Sys.getenv("USERPROFILE"), ".vscode-R", "init.R")
    if (file.exists(init_script)) source(init_script)
  })

  options(
    vsc.helpPanel      = "Two",
    vsc.view           = "Two",
    vsc.viewer         = "Two",
    vsc.str.max.level  = 2,
    vsc.show_object_size = TRUE,
    vsc.use_httpgd     = TRUE
  )
}
```

### 2. Updated project `.Rprofile`

Added the same block at the top of `.Rprofile` in this repo.

**Why both are needed:** R loads the project `.Rprofile` *instead of* `~/.Rprofile` (not in addition to it). Without the init code in the project file, the session watcher never activates when working in this repo.

### 3. Fixed `r.rpath.windows` in VS Code settings

The path had `Programmes` (incorrect — caused by the `britfix` hook changing the Windows directory name `Programs`). Corrected to:

```
C:/Users/steve.crawshaw/AppData/Local/Programs/R/R-4.5.1/bin/R.exe
```

The extension uses this path to launch a **separate background R process** for the help HTTP server. With the wrong path, the help server never started, causing:

```
Couldn't show help for path: /library/stats/html/filter.html
```

---

## How the Help Panel Works

The help panel does **not** load files directly from disc. It:

1. Launches a background R process (using `r.rpath.windows`) running R's dynamic help HTTP server
2. When `?function` is called in the R terminal, the session watcher sends `requestPath: "/library/stats/html/filter.html"` to VS Code (logged in `~/.vscode-R/request.log`)
3. The extension strips the leading `/` and fetches `http://localhost:PORT/library/stats/html/filter.html` from that background server
4. Renders the HTML in the help webview panel

R_HOME is **not** used for help file resolution — only `r.rpath.windows` matters.

---

## Key VS Code Settings (R-related)

```json
"r.rpath.windows": "C:/Users/steve.crawshaw/AppData/Local/Programs/R/R-4.5.1/bin/R.exe",
"r.rterm.windows": "C:/Users/steve.crawshaw/.local/bin/radian.exe",
"r.plot.useHttpgd": true,
"r.sessionWatcher": true,
"r.alwaysUseActiveTerminal": true,
"r.bracketedPaste": true,
"r.libPaths": [
  "C:/Users/steve.crawshaw/AppData/Local/Programs/R/R-4.5.1/library",
  "C:/Users/steve.crawshaw/OneDrive - West Of England Combined Authority/Documents/languageserver-library"
]
```

---

## Known Issue: britfix Hook and File Paths

The `britfix` pre-save hook corrects American spellings to British. It incorrectly changed the Windows path `Programs` → `Programmes` in `settings.json`. The hook needs to be configured to ignore file path strings, or VS Code `settings.json` should be excluded from britfix processing.

---

## Next Steps

1. Fully restart VS Code (close and reopen)
2. Open an R terminal via **R: Create R Terminal**
3. Test `?stats::filter` — help panel should open
4. Verify `getOption("vsc.helpPanel")` returns `"Two"` in the R terminal
5. Configure britfix to exclude `settings.json` or path strings

---

## Diagnostic Commands

Run in R terminal to verify session watcher is active:

```r
getOption("vsc.helpPanel")     # "Two"
getOption("vsc.view")          # "Two"
Sys.getenv("R_HOME")           # full path to R installation
```

Check what VS Code receives when help is triggered:

```r
# After running ?filter, inspect:
readLines("~/.vscode-R/request.log")
```
