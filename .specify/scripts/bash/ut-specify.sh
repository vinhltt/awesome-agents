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
source "$SCRIPT_DIR/common-env.sh" 2>/dev/null || {
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

# Set up paths using environment configuration
REPO_ROOT=$(get_repo_root)

# Parse feature ID to get folder and ticket
if [[ "$FEATURE_ID" == */* ]]; then
    # Contains folder: hotfix/aa-2
    FOLDER="${FEATURE_ID%%/*}"
    TICKET="${FEATURE_ID#*/}"
else
    # No folder, use default: aa-2
    FOLDER="$SPECKIT_DEFAULT_FOLDER"
    TICKET="$FEATURE_ID"
fi

FEATURE_DIR="${REPO_ROOT}/${SPECKIT_SPECS_ROOT}/${FOLDER}/${TICKET}"
SPEC_FILE="${FEATURE_DIR}/spec.md"
TEST_SPEC_FILE="${FEATURE_DIR}/test-spec.md"

# Check if we're in a git repository
HAS_GIT=false
if git rev-parse --show-toplevel >/dev/null 2>&1; then
    HAS_GIT=true
fi

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

# Create test branch if git is available
if [ "$HAS_GIT" = true ]; then
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$SPECKIT_MAIN_BRANCH")
    TEST_BRANCH_NAME="test/${FOLDER}/${TICKET}"

    # Check if already on a test branch
    if [[ "$CURRENT_BRANCH" =~ ^test/ ]]; then
        echo "ℹ️  Already on test branch: $CURRENT_BRANCH"
    else
        # Check if test branch already exists
        if git show-ref --verify --quiet "refs/heads/$TEST_BRANCH_NAME"; then
            echo "ℹ️  Test branch exists: $TEST_BRANCH_NAME"
            echo ""
            read -p "Switch to existing test branch? (y/N): " switch_branch
            if [[ "$switch_branch" =~ ^[Yy]$ ]]; then
                git checkout "$TEST_BRANCH_NAME"
                echo "✅ Switched to $TEST_BRANCH_NAME"
            else
                echo "ℹ️  Staying on current branch: $CURRENT_BRANCH"
            fi
        else
            # Create new test branch from main
            echo "🌿 Creating test branch: $TEST_BRANCH_NAME from $SPECKIT_MAIN_BRANCH"
            git checkout -b "$TEST_BRANCH_NAME" "$SPECKIT_MAIN_BRANCH"
            echo "✅ Test branch created and checked out"
        fi
    fi
    echo ""
else
    echo "⚠️  Warning: Git repository not detected; skipped test branch creation"
    echo ""
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
if [ "$HAS_GIT" = true ]; then
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    echo "Branch: $CURRENT_BRANCH"
fi
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
