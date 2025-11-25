#!/bin/bash
#
# ut-analyze.sh - Bash wrapper for /ut.analyze command
#
# Usage: ut-analyze.sh <feature-id> [--path <code-path>]
# Example: ut-analyze.sh aa-2
#          ut-analyze.sh aa-2 --path src/
#
# This script handles argument parsing and file I/O for the /ut.analyze command.
# All intelligent logic (code analysis, framework detection) is handled by AI agent.


# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}
set -e  # Exit on error

# Parse arguments
FEATURE_ID="$1"
CODE_PATH=""

# Parse optional --path argument
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            CODE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$FEATURE_ID" ]; then
    echo "Error: Feature ID required"
    echo "Usage: $0 <feature-id> [--path <code-path>]"
    echo "Example: $0 aa-2"
    echo "         $0 aa-2 --path src/"
    exit 1
fi

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"

REPO_ROOT=$(get_repo_root)
COVERAGE_REPORT="${FEATURE_DIR}/coverage-report.json"

# Default code path if not specified
if [ -z "$CODE_PATH" ]; then
    # Try common source directories
    if [ -d "${REPO_ROOT}/src" ]; then
        CODE_PATH="${REPO_ROOT}/src"
    elif [ -d "${REPO_ROOT}/lib" ]; then
        CODE_PATH="${REPO_ROOT}/lib"
    elif [ -d "${REPO_ROOT}/app" ]; then
        CODE_PATH="${REPO_ROOT}/app"
    else
        CODE_PATH="$REPO_ROOT"
    fi
fi

# Validate feature directory exists
if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature directory not found: $FEATURE_DIR"
    echo "Please ensure feature $FEATURE_ID exists"
    exit 1
fi

# Validate code path exists
if [ ! -d "$CODE_PATH" ]; then
    echo "❌ Error: Code path not found: $CODE_PATH"
    exit 1
fi

# Display summary
echo ""
echo "🔍 Code Coverage Analysis"
echo "========================"
echo "Feature ID: $FEATURE_ID"
echo "Code Path: $CODE_PATH"
echo "Output: $COVERAGE_REPORT"
echo ""

# Detect programming language (simple heuristic)
echo "🔎 Detecting environment..."

if [ -f "${REPO_ROOT}/package.json" ]; then
    echo "   📦 package.json found - Node.js/JavaScript/TypeScript project"
    LANG_DETECTED="JavaScript/TypeScript"
elif [ -f "${REPO_ROOT}/pyproject.toml" ] || [ -f "${REPO_ROOT}/setup.py" ]; then
    echo "   🐍 Python project files found"
    LANG_DETECTED="Python"
elif [ -f "${REPO_ROOT}/go.mod" ]; then
    echo "   🐹 go.mod found - Go project"
    LANG_DETECTED="Go"
elif [ -f "${REPO_ROOT}/Cargo.toml" ]; then
    echo "   🦀 Cargo.toml found - Rust project"
    LANG_DETECTED="Rust"
else
    echo "   ❓ Could not auto-detect project type"
    LANG_DETECTED="Unknown"
fi

# Count source files (rough estimate)
if [ "$LANG_DETECTED" = "JavaScript/TypeScript" ]; then
    FILE_COUNT=$(find "$CODE_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" ! -name "*.test.*" ! -name "*.spec.*" 2>/dev/null | wc -l)
elif [ "$LANG_DETECTED" = "Python" ]; then
    FILE_COUNT=$(find "$CODE_PATH" -type f -name "*.py" ! -path "*/venv/*" ! -path "*/__pycache__/*" ! -path "*/dist/*" ! -name "test_*" ! -name "*_test.py" 2>/dev/null | wc -l)
else
    FILE_COUNT=$(find "$CODE_PATH" -type f 2>/dev/null | wc -l)
fi

echo "   📁 Found ~$FILE_COUNT source files to analyze"
echo ""

# The AI agent will now analyze the codebase
echo "🤖 AI agent will analyze codebase..."
echo "   (The /ut.analyze command prompt handles all intelligent logic)"
echo ""
echo "✅ Ready for AI agent processing"
echo ""
echo "Next steps for AI agent:"
echo "1. Detect test framework (Jest/Vitest/Pytest/etc.)"
echo "2. Identify all testable units (functions, classes, methods)"
echo "3. Locate existing test files and parse test coverage"
echo "4. Calculate coverage gaps and priority recommendations"
echo "5. Generate coverage-report.json with detailed findings"
echo "6. Write output to $COVERAGE_REPORT"
echo ""

# Note: In actual execution, Claude Code will invoke the slash command
# which reads this script's output and continues with the prompt instructions

exit 0
