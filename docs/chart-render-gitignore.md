
Why the chart is missing

When you render the chapter, Quarto generates the plot PNG at chapters/01-economy/index_files/figure-html/RI_1D1_broadband_coverage_plot-1.png. The freeze cache JSON you committed references this file, but the file itself was blocked by the *_files/ pattern in .gitignore — so it never made it into the repo.

What to do

1. Pull the latest main into your branch (or create a new branch from main).
2. Make sure your R environment is working and you have your data at data/raw/broadband_coverage_weighted.csv.
3. Render the chapter to regenerate the figure:
quarto render chapters/01-economy/index.qmd
4. Force-add the figure directory (the gitignore blocks it normally):
git add -f chapters/01-economy/index_files/figure-html/
5. Also make sure the freeze JSONs are staged — check with git status and add if needed:
git add _freeze/chapters/01-economy/
6. Commit and push:
git commit -m "feat: add broadband chart figure to freeze"
git push

The underlying issue (for Steve to fix)

The .gitignore pattern *_files/ on line 241 is correct for gitignoring rendered output from most Quarto files, but it also catches the index_files/ directories that Quarto freeze needs committed. We should add a whitelist exception for chapter figures:

# Allow committed freeze-supporting figures in chapters
!chapters/**/index_files/figure-html/
!chapters/**/index_files/figure-html/*.png

This means subsequent analysts won't hit the same problem when they add charts.

---

