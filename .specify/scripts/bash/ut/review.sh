#!/bin/bash
#
# ut-review.sh - Bash wrapper for /ut.review command
#
# Usage: ut-review.sh <feature-id>
# Example: ut-review.sh aa-2
#
# This script handles argument parsing and file I/O for the /ut.review command.
# All intelligent logic (test quality analysis) is handled by the AI agent.

set -e  # Exit on error

# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}

# Parse arguments
FEATURE_ID="$1"

if [ -z "$FEATURE_ID" ]; then
    echo "Error: Feature ID required"
    echo "Usage: $0 <feature-id>"
    echo "Example: $0 aa-2"
    exit 1
fi

# Set up paths
REPO_ROOT=$(get_repo_root)

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"
TEST_SPEC="${FEATURE_DIR}/test-spec.md"
TEST_PLAN="${FEATURE_DIR}/test-plan.md"
REVIEW_REPORT="${FEATURE_DIR}/review-report.md"

# Validate feature directory
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    exit 1
fi

# Search for test files in common locations
echo ""
echo "🔍 Test Review"
echo "=============="
echo "Feature ID: $FEATURE_ID"
echo ""
echo "Searching for test files..."

TEST_FILES=()

# JavaScript/TypeScript test patterns
while IFS= read -r -d '' file; do
    TEST_FILES+=("$file")
done < <(find "$REPO_ROOT" -type f \( -name "*.test.js" -o -name "*.test.ts" -o -name "*.test.jsx" -o -name "*.test.tsx" -o -name "*.spec.js" -o -name "*.spec.ts" -o -name "*.spec.jsx" -o -name "*.spec.tsx" \) -print0 2>/dev/null)

# Python test patterns
while IFS= read -r -d '' file; do
    TEST_FILES+=("$file")
done < <(find "$REPO_ROOT" -type f \( -name "test_*.py" -o -name "*_test.py" \) -print0 2>/dev/null)

# Also check __tests__ directories
while IFS= read -r -d '' file; do
    if [[ "$file" == *"__tests__"* ]]; then
        TEST_FILES+=("$file")
    fi
done < <(find "$REPO_ROOT" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" \) -path "*__tests__*" -print0 2>/dev/null)

# Remove duplicates and sort
if [ ${#TEST_FILES[@]} -gt 0 ]; then
    TEST_FILES=($(printf '%s\n' "${TEST_FILES[@]}" | sort -u))
fi

# Display results
if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo ""
    echo "❌ No test files found"
    echo ""
    echo "Please generate tests first:"
    echo "  /ut.generate $FEATURE_ID"
    exit 1
fi

echo ""
echo "Found ${#TEST_FILES[@]} test file(s):"
for file in "${TEST_FILES[@]}"; do
    # Display relative path
    REL_PATH="${file#$REPO_ROOT/}"
    LINE_COUNT=$(wc -l < "$file" 2>/dev/null || echo "?")
    echo "  ✓ $REL_PATH ($LINE_COUNT lines)"
done
echo ""

# Check optional inputs
INPUTS_AVAILABLE=()
INPUTS_MISSING=()

if [ -f "$TEST_SPEC" ]; then
    INPUTS_AVAILABLE+=("test-spec.md")
else
    INPUTS_MISSING+=("test-spec.md")
fi

if [ -f "$TEST_PLAN" ]; then
    INPUTS_AVAILABLE+=("test-plan.md")
else
    INPUTS_MISSING+=("test-plan.md")
fi

# Display available inputs
if [ ${#INPUTS_AVAILABLE[@]} -gt 0 ]; then
    echo "Reference documents:"
    for input in "${INPUTS_AVAILABLE[@]}"; do
        echo "  ✓ $input"
    done
fi

if [ ${#INPUTS_MISSING[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Optional documents missing:"
    for input in "${INPUTS_MISSING[@]}"; do
        echo "  ✗ $input (review will be limited)"
    done
fi

echo ""

# Check if review report already exists
if [ -f "$REVIEW_REPORT" ]; then
    echo "⚠️  Review report already exists: $REVIEW_REPORT"
    echo ""
    read -p "Generate new review? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "✋ Cancelled"
        exit 0
    fi
    # Backup existing
    cp "$REVIEW_REPORT" "${REVIEW_REPORT}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "   Backup created: ${REVIEW_REPORT}.backup.*"
    echo ""
fi

# Display summary
echo "Output: $REVIEW_REPORT"
echo ""

# Extract some basic stats if test-spec exists
if [ -f "$TEST_SPEC" ]; then
    SCENARIO_COUNT=$(grep -c "^### TS-" "$TEST_SPEC" 2>/dev/null || echo "0")
    CASE_COUNT=$(grep -c "^##### TC-" "$TEST_SPEC" 2>/dev/null || echo "0")

    if [ "$SCENARIO_COUNT" -gt 0 ]; then
        echo "Test Spec Requirements:"
        echo "  - $SCENARIO_COUNT test scenario(s)"
        echo "  - $CASE_COUNT test case(s)"
        echo ""
    fi
fi

# The AI agent will now review test files
echo "🤖 AI agent will review test quality..."
echo "   (The /ut.review command prompt handles all intelligent logic)"
echo ""
echo "✅ Ready for AI agent processing"
echo ""
echo "Next steps for AI agent:"
echo "1. Read generated test files"
if [ -f "$TEST_SPEC" ]; then
    echo "2. Compare against test-spec.md requirements"
fi
echo "3. Analyze assertion quality (flag weak assertions)"
echo "4. Check best practices (AAA pattern, naming, DRY)"
echo "5. Verify mocking strategy (isolation, cleanup)"
echo "6. Assess maintainability (fixtures, helpers, docs)"
echo "7. Calculate quality score (weighted dimensions)"
echo "8. Generate review report with:"
echo "   - Overall quality score"
echo "   - Completeness analysis"
echo "   - Issues found (Critical/Medium/Low)"
echo "   - Actionable recommendations"
echo "   - Before/after code examples"
echo "9. Write review-report.md"
echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with the prompt instructions

exit 0
