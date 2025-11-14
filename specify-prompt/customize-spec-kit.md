# Prompt: Customize GitHub Spec Kit Implementation

**Objective:** Update Spec Kit to support flexible folder/prefix-based branching and spec organization.

**Background:** Default Spec Kit creates features as `specs/001-feature-name` on branches `001-feature-name`. This customization adds folder organization and prefix validation while removing semantic naming from branches/folders.

---

## 1. Customization Parameters

| Key | Value | Description |
| :--- | :--- | :--- |
| `[prefix-list]` | [`aa`] | Allowed prefixes for validation |
| `[default-folder]` | `features` | Default folder when not specified |
| `[main-branch]` | `master` | Base branch for all features |
| `[specs-root]` | `.specify` | Root directory for all specs |

---

## 2. Command Format Changes

### Default Spec Kit Behavior:
```bash
/speckit.specify "Build photo album app"
# Creates: branch "001-photo-albums", spec at "specs/001-photo-albums/"
```

### New Custom Behavior:

**Format:** `/speckit.specify [folder]/[prefix]-### "description"` or `/speckit.specify [prefix]-### "description"`

**Examples:**
```bash
# With custom folder
/speckit.specify hotfix/aa-123 "Fix critical bug"
# → branch: hotfix/aa-123
# → spec: .specify/hotfix/aa-123/

# Using default folder
/speckit.specify aa-456 "New feature"
# → branch: features/aa-456
# → spec: .specify/features/aa-456/

# Different prefix
/speckit.specify bbb-789 "Another task"
# → branch: features/bbb-789
# → spec: .specify/features/bbb-789/
```

**Rules:**
- `[folder]/` is optional. If omitted, uses `[default-folder]`
- `[prefix]` must be in `[prefix-list]` (case-sensitive)
- `###` is any positive integer (1+ digits, no limit)
- No semantic names in branch/folder (only `[folder]/[prefix]-###`)
- Branch base is always `[main-branch]`

**Validation:**
- Validate format: `^([a-z]+/)?([a-z]+)-([0-9]+)$`
- Extract folder (or use default), prefix, number
- Verify prefix in `[prefix-list]`
- Error if invalid: list allowed prefixes

---

## 3. Implementation Scope

### Core Scripts - ALL BASH FILES MUST BE UPDATED (`.specify/scripts/bash/`):

**CRITICAL:** Review and update ALL bash scripts below. Each script likely references the old format.

1. **`create-new-feature.sh`** (PRIMARY)
   - Parse `[folder]/[prefix]-###` format (extract folder, prefix, number)
   - Validate prefix against `[prefix-list]`
   - Create branch: `[folder]/[prefix]-###` from `[main-branch]`
   - Create spec directory: `[specs-root]/[folder]/[prefix]-###/`
   - Update all variable assignments and path constructions

2. **`common.sh`**
   - Update helper functions for branch name resolution
   - Update helper functions for spec path resolution
   - Update any functions that parse or construct feature identifiers

3. **`setup-plan.sh`**
   - Update spec file path resolution to handle `[specs-root]/[folder]/[prefix]-###/`
   - Update any feature name parsing logic

4. **`check-prerequisites.sh`**
   - Update branch name validation patterns
   - Update directory structure checks

5. **`update-agent-context.sh`**
   - Update file path references
   - Update command examples and documentation references

### Templates (`.specify/templates/`):
- Update all `*-template.md` files: remove references to semantic naming, update path examples

### Agent Commands (update usage examples in all):
- **`.agents/commands/speckit.*.md`**
- **`.claude/commands/speckit.*.md`**
- **`.codex/prompts/speckit.*.md`**
- **`.gemini/commands/speckit.*.toml`**
- **`.github/prompts/speckit.*.prompt.md`**
- **`.cursor/commands/speckit.*.md`**

**Focus:** `speckit.specify.*` files need most changes (command syntax). Others need example updates only.