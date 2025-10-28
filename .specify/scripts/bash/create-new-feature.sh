#!/usr/bin/env bash

set -e

JSON_MODE=false
TICKET_ID=""
FEATURE_DESCRIPTION=""

# Parse arguments
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 <ticket-id> <feature_description> [--json]"
            echo ""
            echo "Arguments:"
            echo "  <ticket-id>         The ticket ID in format aa-### (e.g., aa-001, aa-123)"
            echo "  <feature_description> Description of the feature"
            echo ""
            echo "Options:"
            echo "  --json             Output in JSON format"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 aa-001 'Add user authentication system'"
            echo "  $0 aa-123 'Implement OAuth2 integration for API' --json"
            exit 0
            ;;
        *)
            # First non-flag argument is ticket ID, rest is description
            if [ -z "$TICKET_ID" ]; then
                TICKET_ID="$arg"
            else
                if [ -n "$FEATURE_DESCRIPTION" ]; then
                    FEATURE_DESCRIPTION="$FEATURE_DESCRIPTION $arg"
                else
                    FEATURE_DESCRIPTION="$arg"
                fi
            fi
            ;;
    esac
    i=$((i + 1))
done

# Validate that both ticket ID and description are provided
if [ -z "$TICKET_ID" ]; then
    echo "ERROR: Missing required argument: <ticket-id>" >&2
    echo "Usage: $0 <ticket-id> <feature_description> [--json]" >&2
    echo "Example: $0 aa-001 'Add user authentication system'" >&2
    exit 1
fi

if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "ERROR: Missing required argument: <feature_description>" >&2
    echo "Usage: $0 <ticket-id> <feature_description> [--json]" >&2
    echo "Example: $0 aa-001 'Add user authentication system'" >&2
    exit 1
fi

# Validate ticket ID format (must be aa-### where ### is a number)
if ! [[ "$TICKET_ID" =~ ^aa-[0-9]+$ ]]; then
    echo "ERROR: Invalid ticket ID format: '$TICKET_ID'" >&2
    echo "Ticket ID must be in format 'aa-###' where ### is a number (e.g., aa-001, aa-123)" >&2
    exit 1
fi

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to check if a ticket ID already exists
check_ticket_exists() {
    local ticket_id="$1"

    # Check if branch already exists (local or remote)
    if [ "$HAS_GIT" = true ]; then
        # Fetch all remotes to get latest branch info (suppress errors if no remotes)
        git fetch --all --prune 2>/dev/null || true

        # Check remote branches
        if git ls-remote --heads origin 2>/dev/null | grep -q "refs/heads/features/${ticket_id}\$"; then
            return 0  # Exists
        fi

        # Check local branches
        if git branch 2>/dev/null | grep -qE "^[* ]*features/${ticket_id}\$"; then
            return 0  # Exists
        fi
    fi

    # Check specs directory
    if [ -d "$SPECS_DIR/${ticket_id}" ]; then
        return 0  # Exists
    fi

    return 1  # Does not exist
}

# Resolve repository root. Prefer git information when available, but fall back
# to searching for repository markers so the workflow still functions in repositories that
# were initialised with --no-git.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/.specify/features"
mkdir -p "$SPECS_DIR"

# Check if ticket already exists
if check_ticket_exists "$TICKET_ID"; then
    echo "ERROR: Ticket ID '$TICKET_ID' already exists" >&2
    echo "Please use a different ticket ID or work on the existing feature" >&2
    exit 1
fi

# Set branch and folder names (no description suffix, just the ticket ID)
BRANCH_NAME="features/$TICKET_ID"
FOLDER_NAME="$TICKET_ID"

if [ "$HAS_GIT" = true ]; then
    git checkout -b "$BRANCH_NAME" master
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

FEATURE_DIR="$SPECS_DIR/$FOLDER_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE="$REPO_ROOT/.specify/templates/spec-template.md"
SPEC_FILE="$FEATURE_DIR/spec.md"
if [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$SPEC_FILE"; else touch "$SPEC_FILE"; fi

# Set the SPECIFY_FEATURE environment variable for the current session
export SPECIFY_FEATURE="$FOLDER_NAME"

if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","TICKET_ID":"%s","FEATURE_DESCRIPTION":"%s"}\n' "$BRANCH_NAME" "$SPEC_FILE" "$TICKET_ID" "$FEATURE_DESCRIPTION"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "TICKET_ID: $TICKET_ID"
    echo "FEATURE_DESCRIPTION: $FEATURE_DESCRIPTION"
    echo "SPECIFY_FEATURE environment variable set to: $FOLDER_NAME"
fi
