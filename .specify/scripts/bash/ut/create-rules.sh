#!/bin/bash
#
# create-rules.sh - Validate environment for /ut:create-rules command
#
# Usage: create-rules.sh
#
# This script validates environment and outputs paths.
# Framework detection and test scanning handled by AI via prompt.

set -e

# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}

# Get repository root
REPO_ROOT=$(get_repo_root)

# Define output paths
RULES_DIR="$REPO_ROOT/docs/rules/test"
RULES_FILE="$RULES_DIR/ut-rule.md"
TEMPLATE_FILE="$REPO_ROOT/.specify/templates/ut-rule-template.md"

# Check if speckit root exists
if [ ! -d "$REPO_ROOT/.specify" ]; then
    echo "ERROR: .specify directory not found" >&2
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "ERROR: Template not found: $TEMPLATE_FILE" >&2
    exit 1
fi

# Check existing rules
EXISTING_RULES=""
MODE="create"
if [ -f "$RULES_FILE" ]; then
    EXISTING_RULES="$RULES_FILE"
    MODE="exists"
fi

# Create rules directory
mkdir -p "$RULES_DIR"

# Output JSON for AI
cat <<EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "RULES_DIR": "$RULES_DIR",
  "RULES_FILE": "$RULES_FILE",
  "TEMPLATE_FILE": "$TEMPLATE_FILE",
  "EXISTING_RULES": "$EXISTING_RULES",
  "MODE": "$MODE"
}
EOF
