#!/bin/bash
#
# ut-run.sh - Bash wrapper for /ut.run command
#
# Usage: ut-run.sh <feature-id> [--no-coverage]
# Example: ut-run.sh aa-2
#          ut-run.sh aa-2 --no-coverage
#
# This script handles argument parsing and test execution for the /ut.run command.
# Test analysis and reporting logic is handled by the AI agent.


# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}
set -e  # Exit on error

# Parse arguments
FEATURE_ID="$1"
RUN_COVERAGE=true

# Parse optional flags
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-coverage)
            RUN_COVERAGE=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$FEATURE_ID" ]; then
    echo "Error: Feature ID required"
    echo "Usage: $0 <feature-id> [--no-coverage]"
    echo "Example: $0 aa-2"
    exit 1
fi

# Set up paths
REPO_ROOT=$(get_repo_root)

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"
COVERAGE_REPORT="${FEATURE_DIR}/coverage-report.json"
TEST_RESULTS="${FEATURE_DIR}/test-results.md"

# Validate feature directory
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    exit 1
fi

echo ""
echo "🧪 Test Execution"
echo "================="
echo "Feature ID: $FEATURE_ID"
echo ""

# Detect framework from coverage report
FRAMEWORK="Unknown"
FRAMEWORK_VERSION=""

if [ -f "$COVERAGE_REPORT" ] && command -v jq &> /dev/null; then
    FRAMEWORK=$(jq -r '.environment.framework.name // "Unknown"' "$COVERAGE_REPORT" 2>/dev/null)
    FRAMEWORK_VERSION=$(jq -r '.environment.framework.version // ""' "$COVERAGE_REPORT" 2>/dev/null)
fi

# If framework not detected, try to detect from project files
if [ "$FRAMEWORK" == "Unknown" ] || [ "$FRAMEWORK" == "null" ]; then
    if [ -f "${REPO_ROOT}/package.json" ]; then
        if grep -q '"jest"' "${REPO_ROOT}/package.json" 2>/dev/null; then
            FRAMEWORK="Jest"
        elif grep -q '"vitest"' "${REPO_ROOT}/package.json" 2>/dev/null; then
            FRAMEWORK="Vitest"
        fi
    elif [ -f "${REPO_ROOT}/pytest.ini" ] || [ -f "${REPO_ROOT}/pyproject.toml" ]; then
        FRAMEWORK="Pytest"
    fi
fi

# Display framework
if [ "$FRAMEWORK" != "Unknown" ] && [ "$FRAMEWORK" != "null" ]; then
    echo "Framework: $FRAMEWORK"
    if [ -n "$FRAMEWORK_VERSION" ] && [ "$FRAMEWORK_VERSION" != "null" ]; then
        echo "Version: $FRAMEWORK_VERSION"
    fi
else
    echo "⚠️  Framework: Auto-detect"
fi

echo ""

# Search for test files
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

# __tests__ directories
while IFS= read -r -d '' file; do
    if [[ "$file" == *"__tests__"* ]]; then
        TEST_FILES+=("$file")
    fi
done < <(find "$REPO_ROOT" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" \) -path "*__tests__*" -print0 2>/dev/null)

# Remove duplicates
if [ ${#TEST_FILES[@]} -gt 0 ]; then
    TEST_FILES=($(printf '%s\n' "${TEST_FILES[@]}" | sort -u))
fi

if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo ""
    echo "❌ No test files found"
    echo ""
    echo "Generate tests first:"
    echo "  /ut.generate $FEATURE_ID"
    exit 1
fi

echo "Found ${#TEST_FILES[@]} test file(s)"
echo ""

# Check if test command exists
HAS_TEST_SCRIPT=false

if [ -f "${REPO_ROOT}/package.json" ]; then
    if grep -q '"test"' "${REPO_ROOT}/package.json" 2>/dev/null; then
        HAS_TEST_SCRIPT=true
    fi
fi

# Display test command
echo "Test execution:"
if [ "$FRAMEWORK" == "Jest" ] || [ "$FRAMEWORK" == "Vitest" ]; then
    if [ "$HAS_TEST_SCRIPT" == true ]; then
        echo "  Command: npm test"
    else
        if [ "$FRAMEWORK" == "Jest" ]; then
            echo "  Command: npx jest"
        else
            echo "  Command: npx vitest run"
        fi
    fi

    if [ "$RUN_COVERAGE" == true ]; then
        echo "  Coverage: Enabled"
    else
        echo "  Coverage: Disabled"
    fi
elif [ "$FRAMEWORK" == "Pytest" ]; then
    if [ "$RUN_COVERAGE" == true ]; then
        echo "  Command: pytest --cov --verbose"
    else
        echo "  Command: pytest --verbose"
    fi
else
    echo "  Command: Auto-detect and run"
fi

echo ""

# Check if results already exist
if [ -f "$TEST_RESULTS" ]; then
    LAST_RUN=$(stat -c %y "$TEST_RESULTS" 2>/dev/null || stat -f "%Sm" "$TEST_RESULTS" 2>/dev/null || echo "Unknown")
    echo "ℹ️  Previous results exist (last run: ${LAST_RUN})"
    echo "   New results will overwrite: $TEST_RESULTS"
    echo ""
fi

# Display summary
echo "Output: $TEST_RESULTS"
echo ""

# Confirmation prompt
read -p "Execute tests now? (y/n): " choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo "✋ Cancelled"
    exit 0
fi

echo ""

# The AI agent will now execute tests and analyze results
echo "🤖 AI agent will execute tests and analyze results..."
echo "   (The /ut.run command prompt handles test execution and analysis)"
echo ""
echo "✅ Ready for AI agent processing"
echo ""
echo "Next steps for AI agent:"
echo "1. Detect test framework and configuration"
echo "2. Execute test command (npm test, pytest, etc.)"
echo "3. Capture test output (stdout, stderr, exit code)"
echo "4. Parse test results (pass/fail, duration)"

if [ "$RUN_COVERAGE" == true ]; then
    echo "5. Extract coverage metrics (lines, branches, functions)"
else
    echo "5. Skip coverage analysis (--no-coverage flag)"
fi

echo "6. Analyze failures:"
echo "   - Extract failure messages"
echo "   - Identify root causes"
echo "   - Suggest specific fixes with code examples"
echo "7. Generate recommendations:"
echo "   - Priority-ordered action items"
echo "   - Coverage improvement suggestions"
echo "   - Test quality enhancements"
echo "8. Write test-results.md with:"
echo "   - Execution summary"
echo "   - Detailed pass/fail status"
echo "   - Failure analysis with fixes"
echo "   - Coverage report"
echo "   - Actionable next steps"
echo "9. Display summary to terminal"
echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with test execution

exit 0
