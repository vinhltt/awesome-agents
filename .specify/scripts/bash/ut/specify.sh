#!/bin/bash
#
# ut-specify.sh - Bash wrapper for /ut.specify command
#
# Usage: ut-specify.sh <feature-id>
# Example: ut-specify.sh aa-2
#
# This script handles argument parsing and file I/O for the /ut.specify command.
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

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"

SPEC_FILE="${FEATURE_DIR}/spec.md"
TEST_SPEC_FILE="${FEATURE_DIR}/test-spec.md"

# Validate feature directory exists
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    echo "Please ensure feature $FEATURE_ID exists"
    exit 1
fi

# Validate feature spec exists
if [ ! -f "$SPEC_FILE" ]; then
    echo "❌ Error: Feature specification not found: $SPEC_FILE"
    echo "Please run: /speckit.specify $FEATURE_ID"
    exit 1
fi

# Check if test spec already exists
if [ -f "$TEST_SPEC_FILE" ]; then
    echo "⚠️  Test specification already exists: $TEST_SPEC_FILE"
    echo ""
    echo "Options:"
    echo "  1) Update - Merge new scenarios with existing"
    echo "  2) Replace - Create fresh specification"
    echo "  3) Cancel - Keep existing unchanged"
    echo ""
    read -p "Choose option (1/2/3): " choice

    case $choice in
        1)
            echo "📝 Updating existing test specification..."
            MODE="update"
            ;;
        2)
            echo "🔄 Replacing test specification..."
            # Backup existing
            cp "$TEST_SPEC_FILE" "${TEST_SPEC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
            echo "   Backup created: ${TEST_SPEC_FILE}.backup.*"
            MODE="replace"
            ;;
        3)
            echo "✋ Cancelled. Existing specification unchanged."
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Cancelled."
            exit 1
            ;;
    esac
else
    MODE="create"
fi

# Display summary
echo ""
echo "📊 Test Specification Generation"
echo "================================"
echo "Feature ID: $FEATURE_ID"
echo "Feature Spec: $SPEC_FILE"
echo "Output: $TEST_SPEC_FILE"
echo "Mode: $MODE"
echo ""

# The AI agent will now process the feature spec and generate test-spec.md
# This script just handles the file I/O - the intelligent work happens in the slash command prompt

echo "🤖 AI agent is analyzing feature specification..."
echo "   (The /ut.specify command prompt handles all intelligent logic)"
echo ""
echo "✅ Ready for AI agent processing"
echo ""
echo "Next steps for AI agent:"
echo "1. Read and analyze $SPEC_FILE"
echo "2. Extract functional requirements and user stories"
echo "3. Generate test scenarios and test cases"
echo "4. Identify coverage goals and mocking needs"
echo "5. Write output to $TEST_SPEC_FILE"
echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with the prompt instructions

exit 0
