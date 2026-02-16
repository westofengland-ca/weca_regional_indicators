#!/bin/bash

# Installs the pre-commit hook for the indicators project.
# Run from anywhere inside the repo:
#   bash projects/indicators/scripts/hooks/install-hooks.sh

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

HOOK_DIR="$REPO_ROOT/projects/indicators/scripts/hooks"

mkdir -p "$REPO_ROOT/.git/hooks"
cp "$HOOK_DIR/pre-commit" "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$HOOK_DIR/scan_secrets.sh"

echo "Pre-commit hook installed. Scans indicators files for secrets before each commit."
