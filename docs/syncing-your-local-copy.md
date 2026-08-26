# Syncing your local copy with GitHub

**Who this is for:** analysts who cloned this repo a while ago and haven't touched Git since. Recent changes on GitHub include renamed files and restructured scripts, so a plain "pull" is likely to hit conflicts if you have your own unsaved edits sitting in your folder.

**Before you start:** open a terminal in your project folder. In Positron/RStudio this is the **Terminal** tab (not the R Console). All commands below are typed there, then press Enter.

If anything on screen doesn't match what's described here, stop and message Steve rather than guessing — it's much easier to fix a problem before you've typed more commands.

------------------------------------------------------------------------

## Step 1 — Check what state you're in

``` bash
git status
```

Read the output. It will tell you one of three things:

- **"nothing to commit, working tree clean"** → you have no unsaved changes. Skip to [Step 3](#step-3--pull-the-latest-changes).
- **A list of files under "Changes not staged for commit" or "Untracked files"** → you have local edits. Go to [Step 2](#step-2--save-your-changes).
- Anything else, or an error message → stop and message Steve with a screenshot.

## Step 2 — Save your changes

Even if you're not ready to "finish" your work, save it as a commit so it can't be lost or overwritten.

``` bash
git add .
git commit -m "wip: save my in-progress work before syncing"
```

`wip` means "work in progress" — that's fine as a commit message here, this isn't a final commit.

If the commit is **blocked** with a message mentioning a secret, API key, or `.env` file: stop and message Steve. Do not try to force it through.

## Step 3 — Pull the latest changes

``` bash
git pull
```

One of three things will happen:

### A) It just works

You'll see a summary of files changed. You're done — read [After syncing](#after-syncing) below.

### B) You get a merge conflict

Git will list files marked as "both modified". This means someone else's change and your change touched the same lines of the same file.

``` bash
git status
```

Files listed under "Unmerged paths" need attention. Open each one in your editor and look for blocks like this:

```         
<<<<<<< HEAD
your version of the lines
=======
their version of the lines
>>>>>>> some-branch-name
```

Decide which version to keep (or blend them), then **delete the `<<<<<<<`, `=======`, and `>>>>>>>` marker lines themselves** — leave only the final text you want. Do this for every conflicted file, then:

``` bash
git add .
git commit -m "merge: resolve conflicts after sync"
```

If you're unsure which version is correct, message Steve with the filename before committing — don't guess on shared data or scripts.

### C) Git says "Your local changes would be overwritten by merge"

This means you skipped Step 2. Go back and do it now, then repeat Step 3.

## Step 4 — Reconnect renamed files

Some scripts and chapter files have been renamed or moved. If your local work references an old filename (e.g. in a `source()` call, a data path, or a cross-reference), it will now fail silently or throw a "file not found" error.

``` bash
git log --diff-filter=R --summary -- '*.R' '*.qmd'
```

This lists recent renames as `rename old/path.R => new/path.R`. Check whether any of the old paths on the left appear in files you're working on (`Ctrl+Shift+F` / "Find in Files" in your editor), and update them to the new path on the right.

## Step 5 — Handle the freeze cache

This project uses a "freeze cache" (`_freeze/`) so GitHub can publish chapters without needing anyone's raw data. See [`WORKFLOW_LEARNING_GUIDE.md`](WORKFLOW_LEARNING_GUIDE.md) for the full concept — this step is just the pull-side version of that.

**If a conflict shows up in a file under `_freeze/`** (path ending in `execute-results/html.json`): do **not** try to hand-edit the `<<<<<<<` markers like a normal file — it's a large machine-generated blob, not something you can merge line by line. Instead pick a side wholesale and then re-render to regenerate it properly:

``` bash
# keep your own version for now, then regenerate it
git checkout --ours _freeze/chapters/0X-topic/index/execute-results/html.json
git add _freeze/chapters/0X-topic/index/execute-results/html.json
```

Then re-render your chapter (see Step 6) before committing anything else.

**Even without a conflict**, if the pull touched any `.qmd`, `scripts/R/`, or `data/fact/` files in a chapter you work on, treat its freeze snapshot as possibly stale — the fingerprint check described in `WORKFLOW_LEARNING_GUIDE.md` will fail on GitHub (not on your machine) if it's out of date, and that failure is hard to diagnose remotely. Re-render it now rather than waiting to find out later.

## Step 6 — Re-render and re-check

``` bash
quarto render chapters/0X-topic/index.qmd
git status
```

If `html.json` or `figure-html/` shows as changed, that's expected — stage and commit it along with whatever else you were already syncing:

``` bash
git add chapters/0X-topic/index.qmd
git add _freeze/chapters/0X-topic/index/execute-results/html.json
git commit -m "chore: refresh freeze cache after sync"
```

## After syncing {#after-syncing}

Run this to confirm you're clean and up to date:

``` bash
git status
```

It should say `nothing to commit, working tree clean` and mention your branch is up to date with `origin/main`.

------------------------------------------------------------------------

## If you get stuck

Do **not** run any of the following unless Steve tells you to — they can permanently discard work:

- `git reset --hard`
- `git checkout .`
- `git clean -f`
- anything with `--force`

Instead, stop, take a screenshot of the terminal, and message Steve. Nothing here is unrecoverable as long as you commit your work (Step 2) before doing anything else.