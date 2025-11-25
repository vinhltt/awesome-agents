#!/usr/bin/env bash
# Common functions and variables for all scripts

# Source environment configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-env.sh" 2>/dev/null || {
    echo "ERROR: Failed to load common-env.sh" >&2
    exit 1
}

# Note: get_repo_root() is now provided by common-env.sh

# Get current branch, with fallback for non-git repositories
get_current_branch() {
    # First check if SPECIFY_FEATURE environment variable is set
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi

    # Then check git if available
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi

    # For non-git repos, try to find the latest feature directory
    local repo_root=$(get_repo_root)
    local specs_dir="$repo_root/$SPECKIT_SPECS_ROOT/$SPECKIT_DEFAULT_FOLDER"

    if [[ -d "$specs_dir" ]]; then
        local latest_feature=""
        local highest=0

        # Build dynamic regex from allowed prefixes
        local prefix_pattern="(${SPECKIT_PREFIX_LIST//,/|})"

        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                local dirname=$(basename "$dir")
                # Match any allowed prefix with numbers
                if [[ "$dirname" =~ ^${prefix_pattern}-([0-9]+)$ ]]; then
                    local number=${BASH_REMATCH[2]}
                    number=$((10#$number))
                    if [[ "$number" -gt "$highest" ]]; then
                        highest=$number
                        latest_feature=$dirname
                    fi
                fi
            fi
        done

        if [[ -n "$latest_feature" ]]; then
            echo "$latest_feature"
            return
        fi
    fi

    echo "$SPECKIT_MAIN_BRANCH"  # Final fallback to configured main branch
}

# Check if we have git available
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

check_feature_branch() {
    local branch="$1"
    local has_git_repo="$2"

    # For non-git repos, we can't enforce branch naming but still provide output
    if [[ "$has_git_repo" != "true" ]]; then
        echo "[specify] Warning: Git repository not detected; skipped branch validation" >&2
        return 0
    fi

    # Build dynamic regex from allowed prefixes and folders
    local prefix_pattern="(${SPECKIT_PREFIX_LIST//,/|})"
    local branch_pattern="^[a-z]+/${prefix_pattern}-[0-9]+$"

    if [[ ! "$branch" =~ $branch_pattern ]]; then
        echo "ERROR: Not on a feature branch. Current branch: $branch" >&2
        echo "Feature branches should be named like: $SPECKIT_DEFAULT_FOLDER/prefix-number" >&2
        echo "Allowed prefixes: $SPECKIT_PREFIX_LIST" >&2
        return 1
    fi

    return 0
}

get_feature_dir() {
    local repo_root="$1"
    local ticket_id="$2"

    # Parse the branch/ticket to get folder and ticket ID
    # If ticket_id contains /, it's folder/ticket format
    if [[ "$ticket_id" == */* ]]; then
        local folder="${ticket_id%%/*}"
        local ticket="${ticket_id#*/}"
        echo "$repo_root/$SPECKIT_SPECS_ROOT/$folder/$ticket"
    else
        # Use default folder
        echo "$repo_root/$SPECKIT_SPECS_ROOT/$SPECKIT_DEFAULT_FOLDER/$ticket_id"
    fi
}

# Find feature directory - now simpler with exact ticket ID match
find_feature_dir_by_prefix() {
    local repo_root="$1"
    local branch_name="$2"

    # Extract folder and ticket ID from branch name (folder/prefix-number)
    if [[ "$branch_name" =~ ^([a-z]+)/(.+)$ ]]; then
        local folder="${BASH_REMATCH[1]}"
        local ticket_id="${BASH_REMATCH[2]}"
        echo "$repo_root/$SPECKIT_SPECS_ROOT/$folder/$ticket_id"
    else
        # Fallback: assume it's just the ticket ID with default folder
        echo "$repo_root/$SPECKIT_SPECS_ROOT/$SPECKIT_DEFAULT_FOLDER/$branch_name"
    fi
}

get_feature_paths() {
    local repo_root=$(get_repo_root)
    local current_branch=$(get_current_branch)
    local has_git_repo="false"

    if has_git; then
        has_git_repo="true"
    fi

    # Use prefix-based lookup to support multiple branches per spec
    local feature_dir=$(find_feature_dir_by_prefix "$repo_root" "$current_branch")

    cat <<EOF
REPO_ROOT='$repo_root'
CURRENT_BRANCH='$current_branch'
HAS_GIT='$has_git_repo'
FEATURE_DIR='$feature_dir'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
EOF
}

check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

# Create or switch to a feature branch
# Usage: create_or_switch_branch <branch-name> [--force]
# Options:
#   --force: Create new branch without interactive prompts (for /speckit.specify)
# Returns: 0 on success, 1 if user declined to switch
create_or_switch_branch() {
    local branch_name="$1"
    local force_mode=false

    if [[ "$2" == "--force" ]]; then
        force_mode=true
    fi

    # Check if git is available
    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        echo "⚠️  Warning: Git repository not detected; skipped branch creation" >&2
        return 0
    fi

    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$SPECKIT_MAIN_BRANCH")

    # If force mode, just create the branch
    if $force_mode; then
        git checkout -b "$branch_name" "$SPECKIT_MAIN_BRANCH" 2>/dev/null || {
            echo "ERROR: Failed to create branch $branch_name" >&2
            return 1
        }
        return 0
    fi

    # Interactive mode (for /ut:specify)
    # Check if already on a feature branch
    if [[ "$current_branch" =~ ^features/|^test/|^hotfix/ ]]; then
        echo "ℹ️  Already on feature branch: $current_branch"
        return 0
    fi

    # Check if feature branch already exists
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "ℹ️  Feature branch exists: $branch_name"
        echo ""
        read -p "Switch to existing feature branch? (y/N): " switch_branch
        if [[ "$switch_branch" =~ ^[Yy]$ ]]; then
            git checkout "$branch_name"
            echo "✅ Switched to $branch_name"
            return 0
        else
            echo "ℹ️  Staying on current branch: $current_branch"
            return 1
        fi
    else
        # Create new feature branch from main
        echo "🌿 Creating feature branch: $branch_name from $SPECKIT_MAIN_BRANCH"
        git checkout -b "$branch_name" "$SPECKIT_MAIN_BRANCH"
        echo "✅ Feature branch created and checked out"
        return 0
    fi
}

