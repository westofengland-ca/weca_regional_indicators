#!/bin/bash
# test_render.sh - Smoke test for rendering all chapters
#
# This script attempts to render each chapter individually to catch errors
# before building the complete book. Useful for CI/CD or pre-commit checks.
#
# Usage:
#   ./scripts/test_render.sh           # Test all chapters
#   ./scripts/test_render.sh --fast    # Skip rendering, just check syntax
#   ./scripts/test_render.sh --chapter 02-transport  # Test specific chapter

set -e  # Exit on first error (can be overridden with --continue)

# ============================================================================
# Configuration
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHAPTERS_DIR="$PROJECT_ROOT/chapters"
OUTPUT_DIR="$PROJECT_ROOT/_output"
LOG_DIR="$PROJECT_ROOT/.quarto/logs"

# ANSI color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0
SKIPPED=0
FAILED_CHAPTERS=()

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  WECA Indicators - Chapter Render Test${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_summary() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Test Summary${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Passed:  $PASSED${NC}"
    echo -e "${RED}Failed:  $FAILED${NC}"
    echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
    echo ""

    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}Failed chapters:${NC}"
        for chapter in "${FAILED_CHAPTERS[@]}"; do
            echo -e "  ${RED}✗${NC} $chapter"
        done
        echo ""
        return 1
    else
        echo -e "${GREEN}✓ All chapters passed!${NC}"
        echo ""
        return 0
    fi
}

test_chapter() {
    local chapter_path=$1
    local chapter_name=$(basename $(dirname "$chapter_path"))

    echo -e "${BLUE}Testing:${NC} $chapter_name"

    # Check if file exists
    if [ ! -f "$chapter_path" ]; then
        echo -e "  ${RED}✗ File not found${NC}"
        ((FAILED++))
        FAILED_CHAPTERS+=("$chapter_name")
        return 1
    fi

    # Render the chapter
    if quarto render "$chapter_path" --quiet 2>&1 | tee "$LOG_DIR/${chapter_name}.log"; then
        echo -e "  ${GREEN}✓ Rendered successfully${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "  ${RED}✗ Render failed${NC}"
        echo -e "  ${YELLOW}See log:${NC} $LOG_DIR/${chapter_name}.log"
        ((FAILED++))
        FAILED_CHAPTERS+=("$chapter_name")
        return 1
    fi
}

test_syntax() {
    local chapter_path=$1
    local chapter_name=$(basename $(dirname "$chapter_path"))

    echo -e "${BLUE}Checking syntax:${NC} $chapter_name"

    # Basic syntax checks without rendering
    if grep -q "^---$" "$chapter_path"; then
        # Check YAML frontmatter closes properly
        local yaml_count=$(grep -c "^---$" "$chapter_path")
        if [ $yaml_count -lt 2 ]; then
            echo -e "  ${RED}✗ YAML frontmatter not closed${NC}"
            ((FAILED++))
            FAILED_CHAPTERS+=("$chapter_name")
            return 1
        fi
    fi

    # Check for common syntax errors
    if grep -q "^\`\`\`{r}$" "$chapter_path"; then
        echo -e "  ${YELLOW}⚠ Old-style code chunk syntax found (use #| instead)${NC}"
    fi

    echo -e "  ${GREEN}✓ Syntax checks passed${NC}"
    ((PASSED++))
    return 0
}

# ============================================================================
# Parse Arguments
# ============================================================================

FAST_MODE=false
CONTINUE_ON_ERROR=false
SPECIFIC_CHAPTER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --fast)
            FAST_MODE=true
            shift
            ;;
        --continue)
            CONTINUE_ON_ERROR=true
            set +e  # Don't exit on error
            shift
            ;;
        --chapter)
            SPECIFIC_CHAPTER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --fast              Skip rendering, just check syntax"
            echo "  --continue          Continue testing even if a chapter fails"
            echo "  --chapter <name>    Test only a specific chapter (e.g., 02-transport)"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Test all chapters"
            echo "  $0 --fast                   # Quick syntax check only"
            echo "  $0 --chapter 02-transport   # Test transport chapter only"
            echo "  $0 --continue               # Test all, don't stop on first failure"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Setup
# ============================================================================

print_header

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Change to project root
cd "$PROJECT_ROOT"

echo "Project root: $PROJECT_ROOT"
echo "Chapters dir: $CHAPTERS_DIR"
echo "Mode: $([ "$FAST_MODE" = true ] && echo 'Fast (syntax only)' || echo 'Full render')"
echo ""

# ============================================================================
# Run Tests
# ============================================================================

if [ -n "$SPECIFIC_CHAPTER" ]; then
    # Test specific chapter
    CHAPTER_PATH="$CHAPTERS_DIR/$SPECIFIC_CHAPTER/index.qmd"

    if [ "$FAST_MODE" = true ]; then
        test_syntax "$CHAPTER_PATH"
    else
        test_chapter "$CHAPTER_PATH"
    fi
else
    # Test all chapters
    for chapter_dir in "$CHAPTERS_DIR"/*/; do
        chapter_file="${chapter_dir}index.qmd"

        if [ -f "$chapter_file" ]; then
            if [ "$FAST_MODE" = true ]; then
                test_syntax "$chapter_file" || [ "$CONTINUE_ON_ERROR" = true ]
            else
                test_chapter "$chapter_file" || [ "$CONTINUE_ON_ERROR" = true ]
            fi
            echo ""
        else
            chapter_name=$(basename "$chapter_dir")
            echo -e "${YELLOW}Skipping:${NC} $chapter_name (no index.qmd found)"
            ((SKIPPED++))
            echo ""
        fi
    done
fi

# ============================================================================
# Summary
# ============================================================================

print_summary
exit $?
