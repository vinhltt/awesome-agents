#!/bin/bash
#
# ut-plan.sh - Bash wrapper for /ut.plan command
#
# Usage: ut-plan.sh <feature-id>
# Example: ut-plan.sh aa-2
#
# This script handles argument parsing and file I/O for the /ut.plan command.
# All intelligent logic is handled by the AI agent through the slash command prompt.

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

# Case-insensitive: convert feature ID to lowercase
FEATURE_ID=$(echo "$FEATURE_ID" | tr '[:upper:]' '[:lower:]')

# Set up paths using environment configuration
REPO_ROOT=$(get_repo_root)

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"
TEST_SPEC_FILE="${FEATURE_DIR}/test-spec.md"
COVERAGE_REPORT="${FEATURE_DIR}/coverage-report.json"
TEST_PLAN_FILE="${FEATURE_DIR}/test-plan.md"

# Validate feature directory exists
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    echo "Please ensure feature $FEATURE_ID exists"
    exit 1
fi

# Check for required inputs
MISSING_INPUTS=()

if [ ! -f "$TEST_SPEC_FILE" ]; then
    MISSING_INPUTS+=("test-spec.md")
fi

if [ ! -f "$COVERAGE_REPORT" ]; then
    MISSING_INPUTS+=("coverage-report.json")
fi

# Handle missing inputs
if [ ${#MISSING_INPUTS[@]} -gt 0 ]; then
    echo "⚠️  Missing required inputs:"
    for input in "${MISSING_INPUTS[@]}"; do
        echo "   - $input"
    done
    echo ""

    if [[ " ${MISSING_INPUTS[@]} " =~ " test-spec.md " ]]; then
        echo "📝 Run: /ut.specify $FEATURE_ID"
    fi

    if [[ " ${MISSING_INPUTS[@]} " =~ " coverage-report.json " ]]; then
        echo "🔍 Run: /ut.analyze $FEATURE_ID"
    fi

    echo ""
    read -p "Continue anyway? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "✋ Cancelled"
        exit 0
    fi

    echo "⚠️  Warning: Plan may be incomplete without all inputs"
    echo ""
fi

# Check if test plan already exists
if [ -f "$TEST_PLAN_FILE" ]; then
    echo "⚠️  Test plan already exists: $TEST_PLAN_FILE"
    echo ""
    read -p "Overwrite existing plan? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "✋ Cancelled. Existing plan unchanged."
        exit 0
    fi
    # Backup existing
    cp "$TEST_PLAN_FILE" "${TEST_PLAN_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "   Backup created: ${TEST_PLAN_FILE}.backup.*"
    echo ""
fi

# Display summary
echo "📋 Test Implementation Plan Generation"
echo "======================================"
echo "Feature ID: $FEATURE_ID"
echo ""
echo "Inputs:"
if [ -f "$TEST_SPEC_FILE" ]; then
    echo "  ✓ Test Spec: $TEST_SPEC_FILE"
else
    echo "  ✗ Test Spec: Missing"
fi

if [ -f "$COVERAGE_REPORT" ]; then
    echo "  ✓ Coverage Report: $COVERAGE_REPORT"

    # Try to extract framework info from coverage report
    if command -v jq &> /dev/null; then
        FRAMEWORK=$(jq -r '.environment.framework.name // "Unknown"' "$COVERAGE_REPORT" 2>/dev/null)
        if [ "$FRAMEWORK" != "Unknown" ] && [ "$FRAMEWORK" != "null" ]; then
            echo "     Framework detected: $FRAMEWORK"
        fi
    fi
else
    echo "  ✗ Coverage Report: Missing"
fi

echo ""
echo "Output: $TEST_PLAN_FILE"
echo ""

# The AI agent will now process the inputs and generate test-plan.md
echo "🤖 AI agent will generate test implementation plan..."
echo "   (The /ut.plan command prompt handles all intelligent logic)"
echo ""
echo "✅ Ready for AI agent processing"
echo ""
echo "Next steps for AI agent:"
echo "1. Read test-spec.md for test scenarios"
echo "2. Read coverage-report.json for framework and gaps"
echo "3. Determine test structure and naming conventions"
echo "4. Define test suites for each scenario"
echo "5. Plan mocking strategy for dependencies"
echo "6. Generate priority-ordered implementation tasks"
echo "7. Write complete test plan to $TEST_PLAN_FILE"
echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with the prompt instructions

exit 0
