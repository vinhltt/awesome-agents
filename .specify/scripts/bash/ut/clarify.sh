#!/bin/bash
#
# ut-clarify.sh - Bash wrapper for /ut.clarify command
#
# Usage: ut-clarify.sh <feature-id> [options]
# Example: ut-clarify.sh aa-2 --add-file src/validator.js
#          ut-clarify.sh aa-2 --remove-file src/deprecated.js
#          ut-clarify.sh aa-2 --set src/calc.js,src/valid.js
#          ut-clarify.sh aa-2 --list
#          ut-clarify.sh aa-2 --reset
#

# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}
# This script handles argument parsing and file I/O for the /ut.clarify command.
# All intelligent logic (scope management, artifact updates) is handled by AI agent.

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
FEATURE_ID="$1"
ACTION=""
FILES_TO_ADD=()
FILES_TO_REMOVE=()
FILES_TO_SET=""
EXCLUDE_PATTERN=""
LIST_ONLY=false
RESET=false

if [ -z "$FEATURE_ID" ]; then
    echo -e "${RED}Error: Feature ID required${NC}"
    echo ""
    echo "Usage: $0 <feature-id> [options]"
    echo ""
    echo "Options:"
    echo "  --add-file <path>      Add file to test scope"
    echo "  --remove-file <path>   Remove file from test scope"
    echo "  --set <files>          Set explicit file list (comma-separated)"
    echo "  --exclude <pattern>    Add exclusion pattern (glob)"
    echo "  --list                 Show current scope and exit"
    echo "  --reset                Reset to auto-detect mode"
    echo ""
    echo "Examples:"
    echo "  $0 aa-2 --add-file src/validator.js"
    echo "  $0 aa-2 --remove-file src/deprecated.js"
    echo "  $0 aa-2 --set src/calc.js,src/valid.js"
    echo "  $0 aa-2 --exclude 'src/legacy/**'"
    echo "  $0 aa-2 --list"
    echo "  $0 aa-2 --reset"
    exit 1
fi

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --add-file)
            FILES_TO_ADD+=("$2")
            ACTION="add"
            shift 2
            ;;
        --remove-file)
            FILES_TO_REMOVE+=("$2")
            ACTION="remove"
            shift 2
            ;;
        --set)
            FILES_TO_SET="$2"
            ACTION="set"
            shift 2
            ;;
        --exclude)
            EXCLUDE_PATTERN="$2"
            ACTION="exclude"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            ACTION="list"
            shift
            ;;
        --reset)
            RESET=true
            ACTION="reset"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 <feature-id> [options]"
            echo ""
            echo "Options:"
            echo "  --add-file <path>      Add file to test scope"
            echo "  --remove-file <path>   Remove file from test scope"
            echo "  --set <files>          Set explicit file list (comma-separated)"
            echo "  --exclude <pattern>    Add exclusion pattern (glob)"
            echo "  --list                 Show current scope and exit"
            echo "  --reset                Reset to auto-detect mode"
            echo ""
            echo "Examples:"
            echo "  $0 aa-2 --add-file src/validator.js"
            echo "  $0 aa-2 --list"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate at least one action specified
if [ -z "$ACTION" ]; then
    echo -e "${RED}Error: No action specified${NC}"
    echo "Use one of: --add-file, --remove-file, --set, --exclude, --list, --reset"
    echo "Use --help for full usage information"
    exit 1
fi

# Set up paths using common parsing function
parsed=$(parse_feature_id "$FEATURE_ID") || exit 1
IFS='|' read -r FOLDER TICKET FEATURE_DIR BRANCH_NAME <<< "$parsed"

REPO_ROOT=$(get_repo_root)
SCOPE_FILE="${FEATURE_DIR}/.ut-scope.json"
SPEC_FILE="${FEATURE_DIR}/spec.md"
TEST_SPEC_FILE="${FEATURE_DIR}/test-spec.md"
COVERAGE_REPORT="${FEATURE_DIR}/coverage-report.json"

# Validate feature directory exists
if [ ! -d "$FEATURE_DIR" ]; then
    echo -e "${RED}❌ Error: Feature directory not found: $FEATURE_DIR${NC}"
    echo "Please ensure feature $FEATURE_ID exists"
    echo "Run: /speckit.specify $FEATURE_ID first"
    exit 1
fi

# Validate feature spec exists
if [ ! -f "$SPEC_FILE" ]; then
    echo -e "${YELLOW}⚠️  Warning: Feature spec not found: $SPEC_FILE${NC}"
    echo "Consider running: /speckit.specify $FEATURE_ID"
fi

# Create default scope file if doesn't exist
if [ ! -f "$SCOPE_FILE" ]; then
    echo "Creating default scope file..."
    cat > "$SCOPE_FILE" << 'EOF'
{
  "mode": "auto",
  "includes": [],
  "excludes": [
    "**/*.test.js",
    "**/*.spec.js",
    "**/*.test.ts",
    "**/*.spec.ts",
    "test_*.py",
    "*_test.py"
  ],
  "lastUpdated": "",
  "updatedBy": "user"
}
EOF
fi

# Handle --list action (show current scope and exit)
if [ "$LIST_ONLY" = true ]; then
    echo ""
    echo "📋 Test Scope for feature '$FEATURE_ID'"
    echo "========================================"
    echo ""

    # Parse and display scope
    if command -v jq &> /dev/null; then
        MODE=$(jq -r '.mode' "$SCOPE_FILE")
        INCLUDES=$(jq -r '.includes[]' "$SCOPE_FILE" 2>/dev/null || echo "")
        EXCLUDES=$(jq -r '.excludes[]' "$SCOPE_FILE" 2>/dev/null || echo "")
        LAST_UPDATED=$(jq -r '.lastUpdated' "$SCOPE_FILE")

        echo "Mode: $MODE"
        echo ""

        if [ -n "$INCLUDES" ]; then
            echo "Included files:"
            echo "$INCLUDES" | while read -r file; do
                echo "  • $file"
            done
            echo ""
        else
            if [ "$MODE" = "auto" ]; then
                echo "Included files: All (auto-detect mode)"
                echo ""
            fi
        fi

        if [ -n "$EXCLUDES" ]; then
            echo "Excluded patterns:"
            echo "$EXCLUDES" | while read -r pattern; do
                echo "  • $pattern"
            done
            echo ""
        fi

        if [ "$LAST_UPDATED" != "null" ] && [ -n "$LAST_UPDATED" ]; then
            echo "Last updated: $LAST_UPDATED"
        fi
    else
        # Fallback if jq not available
        cat "$SCOPE_FILE"
    fi

    echo ""
    echo "Next steps:"
    echo "  • /ut.analyze $FEATURE_ID  (analyze with current scope)"
    echo "  • /ut.clarify $FEATURE_ID --add-file <path>  (add more files)"
    echo ""
    exit 0
fi

# Handle --reset action
if [ "$RESET" = true ]; then
    echo ""
    echo "🔄 Resetting scope to auto-detect mode..."

    cat > "$SCOPE_FILE" << 'EOF'
{
  "mode": "auto",
  "includes": [],
  "excludes": [
    "**/*.test.js",
    "**/*.spec.js",
    "**/*.test.ts",
    "**/*.spec.ts",
    "test_*.py",
    "*_test.py"
  ],
  "lastUpdated": "",
  "updatedBy": "user"
}
EOF

    # Update timestamp
    if command -v jq &> /dev/null; then
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        jq --arg ts "$TIMESTAMP" '.lastUpdated = $ts' "$SCOPE_FILE" > "${SCOPE_FILE}.tmp"
        mv "${SCOPE_FILE}.tmp" "$SCOPE_FILE"
    fi

    echo -e "${GREEN}✅ Scope reset to auto mode${NC}"
    echo ""
    echo "All project files will be tested (except default excludes)"
    echo ""
    echo "Next steps:"
    echo "  • /ut.analyze $FEATURE_ID  (re-analyze all files)"
    echo "  • /ut.plan $FEATURE_ID     (re-plan tests)"
    echo ""
    exit 0
fi

# Display action summary
echo ""
echo "🔧 Updating test scope for feature '$FEATURE_ID'"
echo "=============================================="
echo ""

# Validate files exist (if adding)
if [ ${#FILES_TO_ADD[@]} -gt 0 ]; then
    echo "Validating files to add..."
    for file in "${FILES_TO_ADD[@]}"; do
        if [ ! -f "$REPO_ROOT/$file" ]; then
            echo -e "${YELLOW}⚠️  Warning: File not found: $file${NC}"
            echo "File will be added to scope anyway (may be created later)"
        else
            echo -e "${GREEN}✓${NC} Found: $file"
        fi
    done
    echo ""
fi

# Prepare data for AI agent
echo "Action: $ACTION"
if [ ${#FILES_TO_ADD[@]} -gt 0 ]; then
    echo "Files to add: ${FILES_TO_ADD[*]}"
fi
if [ ${#FILES_TO_REMOVE[@]} -gt 0 ]; then
    echo "Files to remove: ${FILES_TO_REMOVE[*]}"
fi
if [ -n "$FILES_TO_SET" ]; then
    echo "Setting files to: $FILES_TO_SET"
fi
if [ -n "$EXCLUDE_PATTERN" ]; then
    echo "Exclude pattern: $EXCLUDE_PATTERN"
fi
echo ""

# Create context file for AI agent
CONTEXT_FILE="${FEATURE_DIR}/.ut-clarify-context.txt"
cat > "$CONTEXT_FILE" << EOF
Feature ID: $FEATURE_ID
Action: $ACTION
Repository Root: $REPO_ROOT
Feature Directory: $FEATURE_DIR
Scope File: $SCOPE_FILE

Files to add: ${FILES_TO_ADD[*]}
Files to remove: ${FILES_TO_REMOVE[*]}
Files to set: $FILES_TO_SET
Exclude pattern: $EXCLUDE_PATTERN

Current scope file content:
$(cat "$SCOPE_FILE")

Test spec exists: $([ -f "$TEST_SPEC_FILE" ] && echo "yes" || echo "no")
Coverage report exists: $([ -f "$COVERAGE_REPORT" ] && echo "yes" || echo "no")
EOF

echo "📄 Context prepared for AI agent"
echo ""
echo "⏳ Processing scope update..."
echo "(AI agent will update .ut-scope.json and affected artifacts)"
echo ""

# Note: The actual AI agent processing happens here via Claude Code CLI
# For now, we'll create a placeholder message
echo -e "${YELLOW}⚠️  AI agent integration pending${NC}"
echo ""
echo "Manual steps for now:"
echo "1. Review context file: $CONTEXT_FILE"
echo "2. Manually update $SCOPE_FILE"
echo "3. Update affected artifacts (test-spec.md if exists)"
echo ""
echo "After Phase 00 validation, this will be automated."
echo ""

# Cleanup
rm -f "$CONTEXT_FILE"

exit 0
