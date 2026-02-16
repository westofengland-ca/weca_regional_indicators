#!/bin/bash

# Scans staged (or all) files for secrets: API keys, tokens, credentials.
# Usage: ./scan_secrets.sh [directory] [--staged]
# Exit codes: 0 = pass, 2 = fail (secrets found)

TARGET_DIR="${1:-.}"
MODE="${2:-full}"
FOUND_SECRET=0

EXCLUDE_PATTERNS="node_modules|\.git|\.exe|\.pyc|\.png|\.jpg|\.svg|\.ico|\.lock|package-lock\.json"
INCLUDE_EXTENSIONS="py|ipynb|md|json|js|ts|jsx|tsx|cpp|txt|yml|yaml|sh|bash|toml|env\.example|env\.template"

# Known secret formats
PATTERN_REGEX="(sk-proj-[a-zA-Z0-9_-]{20,}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36,}|github_pat_[a-zA-Z0-9_]{82}|AKIA[0-9A-Z]{16}|xox[baprs]-[a-zA-Z0-9-]{10,})"

# Variable assignments containing secrets
VAR_REGEX="(api_?key|secret|token|password|auth(?!or)|pwd|credential)(_?[a-z]+)?\s*[:=]\s*(['\"][^'\"]{8,}['\"]|[a-zA-Z0-9_-]{20,})"

echo "--- Security Scan ---"
echo "Target: $TARGET_DIR | Mode: $MODE"

# Check for .env files in staging area
if [[ "$MODE" == "--staged" ]] && git rev-parse --git-dir > /dev/null 2>&1; then
    ENV_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '^\.env$|\.env\.')
    if [[ -n "$ENV_FILES" ]]; then
        FOUND_SECRET=1
        echo ""
        echo "[!] BLOCKED: .env file(s) staged (never commit these):"
        echo "$ENV_FILES" | sed 's/^/    /'
        echo ""
    fi
fi

# Build file list
if [[ "$MODE" == "--staged" ]] && git rev-parse --git-dir > /dev/null 2>&1; then
    FILE_LIST=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | \
                grep -E "\.($INCLUDE_EXTENSIONS)$" | \
                grep -vE "($EXCLUDE_PATTERNS)")
else
    FILE_LIST=$(find "$TARGET_DIR" -type f 2>/dev/null | \
                grep -E "\.($INCLUDE_EXTENSIONS)$" | \
                grep -vE "($EXCLUDE_PATTERNS)")
fi

# Scan
if [[ -z "$FILE_LIST" ]]; then
    echo "No files to scan."
else
    FILE_COUNT=$(echo "$FILE_LIST" | wc -l)
    echo "Scanning $FILE_COUNT file(s)..."

    while IFS= read -r file; do
        [[ ! -f "$file" ]] && continue

        P_MATCHES=$(grep -Ein "$PATTERN_REGEX" "$file" 2>/dev/null)
        V_MATCHES=$(grep -Ein "$VAR_REGEX" "$file" 2>/dev/null | grep -viE "(example|sample|test|dummy|placeholder|your_|<|>|\*\*\*)")

        if [[ -n "$P_MATCHES" || -n "$V_MATCHES" ]]; then
            FOUND_SECRET=1
            echo "[!] BLOCKED: Potential secret in $file"
            if [[ -n "$P_MATCHES" ]]; then
                echo "  Pattern matches:"
                echo "$P_MATCHES" | sed -E 's/(.{10}).{15,}(.{4})/\1********************\2/g' | sed 's/^/    /'
            fi
            if [[ -n "$V_MATCHES" ]]; then
                echo "  Variable assignments:"
                echo "$V_MATCHES" | sed -E 's/(.{10}).{15,}(.{4})/\1********************\2/g' | sed 's/^/    /'
            fi
            echo ""
        fi
    done <<< "$FILE_LIST"
fi

echo "--- Scan Finished ---"

if [ "$FOUND_SECRET" -eq 1 ]; then
    echo "FAIL - Secrets detected. Commit blocked." >&2
    echo "  Move secrets to environment variables or .env files (gitignored)." >&2
    exit 2
else
    echo "PASS - No secrets detected."
    exit 0
fi
