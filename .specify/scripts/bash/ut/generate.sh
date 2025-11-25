#!/bin/bash
#
# ut:generate.sh - Bash wrapper for /ut.generate command
#
# Usage: ut:generate.sh <feature-id> [--dry-run]
# Example: ut:generate.sh aa-2
#          ut:generate.sh aa-2 --dry-run
#
# This script handles argument parsing and file I/O for the /ut.generate command.
# All intelligent logic (code generation) is handled by the AI agent.


# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}
set -e  # Exit on error

# Parse arguments
FEATURE_ID="$1"
DRY_RUN=false

# Parse optional flags
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
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
    echo "Usage: $0 <feature-id> [--dry-run]"
    echo "Example: $0 aa-2"
    exit 1
fi

# Set up paths
REPO_ROOT=$(get_repo_root)

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"

TEST_PLAN="${FEATURE_DIR}/test-plan.md"
TEST_SPEC="${FEATURE_DIR}/test-spec.md"
COVERAGE_REPORT="${FEATURE_DIR}/coverage-report.json"

# Validate feature directory
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    exit 1
fi

# Check required inputs
MISSING_INPUTS=()

if [ ! -f "$TEST_PLAN" ]; then
    MISSING_INPUTS+=("test-plan.md")
fi

if [ ! -f "$TEST_SPEC" ]; then
    MISSING_INPUTS+=("test-spec.md")
fi

if [ ! -f "$COVERAGE_REPORT" ]; then
    MISSING_INPUTS+=("coverage-report.json")
fi

# Handle missing inputs
if [ ${#MISSING_INPUTS[@]} -gt 0 ]; then
    echo "❌ Error: Missing required inputs:"
    for input in "${MISSING_INPUTS[@]}"; do
        echo "   - $input"
    done
    echo ""
    echo "Required workflow:"
    echo "  1. /ut.specify $FEATURE_ID   (creates test-spec.md)"
    echo "  2. /ut.analyze $FEATURE_ID   (creates coverage-report.json)"
    echo "  3. /ut.plan $FEATURE_ID      (creates test-plan.md)"
    echo "  4. /ut.generate $FEATURE_ID  (generates test files)"
    exit 1
fi

# Display summary
echo ""
echo "🔧 Test Code Generation"
echo "======================="
echo "Feature ID: $FEATURE_ID"

if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (no files will be written)"
else
    echo "Mode: GENERATION (files will be created)"
fi

echo ""
echo "Inputs:"
echo "  ✓ Test Plan: $TEST_PLAN"
echo "  ✓ Test Spec: $TEST_SPEC"
echo "  ✓ Coverage Report: $COVERAGE_REPORT"
echo ""

# Extract framework info
if command -v jq &> /dev/null && [ -f "$COVERAGE_REPORT" ]; then
    FRAMEWORK=$(jq -r '.environment.framework.name // "Unknown"' "$COVERAGE_REPORT" 2>/dev/null)
    FRAMEWORK_VERSION=$(jq -r '.environment.framework.version // ""' "$COVERAGE_REPORT" 2>/dev/null)

    if [ "$FRAMEWORK" != "Unknown" ] && [ "$FRAMEWORK" != "null" ]; then
        echo "Framework: $FRAMEWORK"
        if [ -n "$FRAMEWORK_VERSION" ] && [ "$FRAMEWORK_VERSION" != "null" ]; then
            echo "Version: $FRAMEWORK_VERSION"
        fi
    fi
fi

# Count test scenarios from test-spec.md
if [ -f "$TEST_SPEC" ]; then
    SCENARIO_COUNT=$(grep -c "^### TS-" "$TEST_SPEC" 2>/dev/null || echo "0")
    if [ "$SCENARIO_COUNT" -gt 0 ]; then
        echo "Test Scenarios: $SCENARIO_COUNT"
    fi
fi

echo ""

# Warning for first-time generation
if [ "$DRY_RUN" = false ]; then
    echo "⚠️  WARNING: This will create test files in your project."
    echo ""
    read -p "Continue with test generation? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "✋ Cancelled"
        exit 0
    fi
    echo ""
fi

# The AI agent will now generate test files
echo "🤖 AI agent will generate test code..."
echo "   (The /ut.generate command prompt handles all intelligent logic)"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN MODE - Preview Only"
    echo ""
    echo "Next steps for AI agent (preview):"
else
    echo "✅ Ready for AI agent processing"
    echo ""
    echo "Next steps for AI agent:"
fi

echo "1. Read test-plan.md for test structure"
echo "2. Read test-spec.md for test cases"
echo "3. Analyze source code to be tested"
echo "4. Detect framework syntax (Jest/Vitest/Pytest)"
echo "5. Generate test files with:"
echo "   - Setup/teardown code"
echo "   - Test cases with assertions"
echo "   - Mock implementations"
echo "   - Test data/fixtures"
echo "6. Write test files to project directory"

if [ "$DRY_RUN" = false ]; then
    echo "7. Report generation summary"
fi

echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with the prompt instructions

exit 0
