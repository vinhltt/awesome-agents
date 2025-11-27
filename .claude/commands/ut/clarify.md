# Command: /ut.clarify

## ⛔ CRITICAL: Error Handling

**If ANY script returns an error, you MUST:**
1. **STOP immediately** - Do NOT attempt workarounds or auto-fixes
2. **Report the error** - Show the exact error message to the user
3. **Wait for user** - Ask user how to proceed before taking any action

**DO NOT:**
- Try alternative approaches when scripts fail
- Create branches manually when script validation fails
- Guess or assume what the user wants after an error
- Continue with partial results

---

**Purpose**: Add, remove, or update files in the unit test scope for a feature.

**Command Pattern**: `/ut.clarify <feature-id> [options]`

**Analogy**: Similar to `/speckit.clarify` but for test scope instead of requirements.

---

## Overview

This command helps developers control which files should be included in unit testing for a specific feature. It's useful when:
- You initially specified tests but forgot to include a file
- You want to test files incrementally (one at a time)
- You need to exclude certain files from test generation
- You want to add new files to an existing test suite

---

## Input Requirements

### Required Arguments
- `<feature-id>`: **REQUIRED** argument (e.g., `pref-2`, `AL-991`, `test/pref-123`)
  - Format: `[folder/]prefix-number`
  - Prefix configured in `.specify/.speckit.env`
  - If missing: ERROR "Task ID required. Usage: /ut:clarify {task-id}"

### Optional Flags
- `--add-file <path>`: Add a file to the test scope
- `--remove-file <path>`: Remove a file from the test scope
- `--set <file1,file2,...>`: Set explicit file list (replaces current scope)
- `--list`: Display current scope and exit
- `--reset`: Reset to auto-detect mode (all files)
- `--exclude <pattern>`: Add exclusion pattern (glob)

### Examples (assuming prefix=pref)
```bash
# Add a single file
/ut.clarify pref-2 --add-file src/validator.js

# Add multiple files
/ut.clarify pref-2 --add-file src/validator.js --add-file src/formatter.js

# Remove a file
/ut.clarify pref-2 --remove-file src/deprecated.js

# Set explicit scope (replaces everything)
/ut.clarify pref-2 --set src/calculator.js,src/validator.js

# Exclude pattern
/ut.clarify pref-2 --exclude "src/**/*.config.js"

# Show current scope
/ut.clarify pref-2 --list

# Reset to auto-detect all files
/ut.clarify pref-2 --reset
```

---

## Workflow Steps

### Step 0: Validate or Infer Task ID

**CRITICAL**: Handle task_id before any operations.

1. **Parse user input**:
   - Extract first argument from `$ARGUMENTS`
   - Expected format: `[folder/]prefix-number` (e.g., `pref-991`, `AL-991`, `test/pref-123`)
   - Remaining arguments are options (e.g., `--add-file`, `--list`)

2. **Check if task_id provided**:

   **If task_id provided and valid** (matches pattern `[folder/]prefix-number`):
   - Convert to lowercase (case-insensitive)
   - → Proceed to Step 1 with this task_id

   **If task_id missing or invalid**:
   - → Proceed to inference (step 3)

3. **Infer from conversation context** (only if task_id missing):
   - Search this conversation for:
     - Previous `/speckit.*` or `/ut.*` command executions with task_id
     - Task_id patterns mentioned (e.g., "pref-001", "MRR-123", "aa-2")
     - Output mentioning "Feature pref-001" or similar

   **If context found** (e.g., "pref-001"):
   - Use **AskUserQuestion** tool to confirm:
     ```json
     {
       "questions": [{
         "question": "No task_id provided. Use detected context 'pref-001'?",
         "header": "Task ID",
         "options": [
           {"label": "Yes, use pref-001", "description": "Proceed with the detected task"},
           {"label": "No, specify another", "description": "I'll provide a different task_id"}
         ],
         "multiSelect": false
       }]
     }
     ```
   - If user selects "Yes" → task_id = inferred value (lowercase), proceed to Step 1
   - If user selects "No" → Show usage, STOP

   **If NO context found**:
   ```
   ❌ Error: task_id is required

   Usage: /ut.clarify <task-id> [options]
   Example: /ut.clarify pref-001 --add-file src/utils.ts

   No previous task context found in this conversation.
   ```
   STOP - Do NOT proceed to Step 1

4. **Validate task_id format**:
   - Must match pattern: `[folder/]prefix-number`
   - Prefix must be in `.specify/.speckit.env` SPECKIT_PREFIX_LIST
   - Examples:
     - ✅ `/ut.clarify pref-991 --add-file src/utils.ts` → task_id: `pref-991`
     - ✅ `/ut.clarify PREF-991 --list` → task_id: `pref-991` (case-insensitive)
     - ❌ `/ut.clarify --add-file src/utils.ts` without context → ERROR (no task ID)

5. **Determine feature directory**:
   - Pattern: `.specify/{folder}/{prefix-number}/`
   - Default folder: `features` (from SPECKIT_DEFAULT_FOLDER)
   - If not found → ERROR, suggest running `/ut.specify` first

**After Validation**:
- Proceed to Step 1 only if task_id valid
- Use task_id to locate feature files

### Step 1: Validate Inputs

**Actions**:
1. Verify feature directory exists: `.specify/features/{feature-id}/`
2. Verify feature spec exists: `.specify/features/{feature-id}/spec.md`
3. Validate file paths (if --add-file or --set)
   - Check files exist in project
   - Use relative paths from project root
   - Warn if file doesn't exist (but still allow - maybe it will be created)

**Error Handling**:
```
Error: Feature 'pref-2' not found
→ Run /speckit.specify pref-2 first

Error: File 'src/missing.js' does not exist
→ Continue anyway? [y/N]
```

---

### Step 2: Load Current Scope

**Actions**:
1. Check if `.specify/features/{feature-id}/.ut-scope.json` exists
2. If exists: Load and parse JSON
3. If not exists: Create default scope:

```json
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
  "lastUpdated": "2025-11-15T20:00:00Z",
  "updatedBy": "user"
}
```

**Scope Structure**:
- `mode`: "auto" (scan all) or "manual" (explicit list)
- `includes`: Array of file paths (empty = all files if mode=auto)
- `excludes`: Array of glob patterns to exclude
- `lastUpdated`: ISO timestamp
- `updatedBy`: User identifier (for audit)

---

### Step 3: Process User Action

Based on flag provided:

#### Action: `--add-file <path>`

```javascript
// Pseudocode
if (scope.mode === "auto") {
  // Switch to manual mode
  scope.mode = "manual";
  scope.includes = [path];
} else {
  // Add to includes if not already there
  if (!scope.includes.includes(path)) {
    scope.includes.push(path);
  }
}
```

**Behavior**:
- First `--add-file` switches from auto → manual mode
- Subsequent adds append to includes array
- Duplicates are ignored

---

#### Action: `--remove-file <path>`

```javascript
// Pseudocode
if (scope.mode === "auto") {
  // Add to excludes
  scope.excludes.push(path);
} else {
  // Remove from includes
  scope.includes = scope.includes.filter(f => f !== path);

  // If includes becomes empty, switch back to auto
  if (scope.includes.length === 0) {
    scope.mode = "auto";
  }
}
```

**Behavior**:
- In auto mode: add to excludes
- In manual mode: remove from includes
- If includes empty after removal → switch to auto

---

#### Action: `--set <file1,file2,...>`

```javascript
// Pseudocode
scope.mode = "manual";
scope.includes = files.split(',').map(f => f.trim());
```

**Behavior**:
- REPLACES current scope entirely
- Always switches to manual mode
- Comma-separated list

---

#### Action: `--exclude <pattern>`

```javascript
// Pseudocode
if (!scope.excludes.includes(pattern)) {
  scope.excludes.push(pattern);
}
```

**Behavior**:
- Add glob pattern to excludes
- Works in both auto and manual mode
- Supports wildcards: `**/*.config.js`, `src/legacy/**`

---

#### Action: `--reset`

```javascript
// Pseudocode
scope.mode = "auto";
scope.includes = [];
scope.excludes = [default test file patterns];
```

**Behavior**:
- Reset to auto-detect mode
- Clear manual includes
- Keep default test file excludes

---

#### Action: `--list`

**Behavior**:
- Display current scope configuration
- Exit without making changes
- Show:
  - Current mode (auto/manual)
  - Included files count
  - Excluded patterns
  - Last updated timestamp

**Output Format**:
```
Test Scope for feature 'pref-2'

Mode: manual
Included files (2):
  • src/calculator.js
  • src/validator.js

Excluded patterns (6):
  • **/*.test.js
  • **/*.spec.js
  • **/*.test.ts
  • **/*.spec.ts
  • test_*.py
  • *_test.py

Last updated: 2025-11-15 20:00:00
Updated by: user

Next steps:
  • /ut.analyze pref-2  (re-analyze with new scope)
  • /ut.plan pref-2     (re-plan tests)
```

---

### Step 4: Update Scope File

**Actions**:
1. Update `lastUpdated` timestamp (ISO 8601 format)
2. Update `updatedBy` (use git user.name or "user")
3. Write to `.specify/features/{feature-id}/.ut-scope.json`
4. Pretty-print JSON (2-space indent)

**File Location**: `.specify/features/{feature-id}/.ut-scope.json`

**Example Output**:
```json
{
  "mode": "manual",
  "includes": [
    "src/calculator.js",
    "src/validator.js"
  ],
  "excludes": [
    "**/*.test.js",
    "**/*.spec.js",
    "**/*.test.ts",
    "**/*.spec.ts",
    "test_*.py",
    "*_test.py"
  ],
  "lastUpdated": "2025-11-15T20:30:15Z",
  "updatedBy": "user"
}
```

---

### Step 5: Update Affected Artifacts

**If test-spec.md exists**:

**Actions**:
1. Read current test-spec.md
2. If files were added:
   - Add new test scenarios for added files
   - Follow existing structure/format
   - Analyze added files to identify testable units
3. If files were removed:
   - Remove test scenarios for those files
   - Keep other scenarios intact
4. Update test-spec.md with changes

**Example Update**:
```markdown
# Test Specification (UPDATED)

## Files in Scope
- src/calculator.js
- src/validator.js (ADDED)

## Test Scenarios

### TS-001: Calculator Operations
... (existing)

### TS-002: Input Validation (NEW)
Test validator.js functionality:
- TC-001: Valid input acceptance
- TC-002: Invalid input rejection
- TC-003: Type checking
```

---

**If coverage-report.json exists**:

**Warning to user**:
```
⚠️  Scope changed. Coverage report may be outdated.

Recommendation:
  Run /ut.analyze aa-2 to update coverage with new scope
```

**Do NOT auto-rerun /ut.analyze** (user may not want it yet)

---

**If test-plan.md exists**:

**Warning to user**:
```
⚠️  Scope changed. Test plan may be outdated.

Recommendation:
  1. Run /ut.analyze aa-2 (update coverage)
  2. Run /ut.plan aa-2 (update test plan)
```

---

### Step 6: Display Summary

**Output Format**:
```
✅ Test scope updated for feature 'pref-2'

Changes:
  • Mode: manual
  • Added files: 1
    - src/validator.js
  • Removed files: 0
  • Total files in scope: 2

Updated artifacts:
  ✅ .ut-scope.json created
  ✅ test-spec.md updated (added validator scenarios)
  ⚠️  coverage-report.json may be outdated

Next steps:
  1. Review updated test-spec.md
  2. Run /ut.analyze pref-2 (update coverage for new files)
  3. Run /ut.plan pref-2 (re-plan with new scope)

Or continue workflow:
  /ut.analyze pref-2 && /ut.plan pref-2
```

**If `--list` flag**:
- Show scope without making changes
- Exit

---

## Quality Checklist

Before completing this command, verify:

- [ ] `.ut-scope.json` file created/updated successfully
- [ ] JSON is valid and parseable
- [ ] File paths are relative to project root
- [ ] `mode` is either "auto" or "manual"
- [ ] `includes` array has no duplicates
- [ ] `lastUpdated` timestamp is current (ISO 8601)
- [ ] If files added: test-spec.md updated with new scenarios
- [ ] If files removed: test-spec.md cleaned up
- [ ] User receives clear summary of changes
- [ ] Next steps are actionable and clear

---

## Error Handling

### Error 1: Feature Not Found
```
Error: Feature 'pref-2' does not exist

Solution:
  1. Check feature ID spelling
  2. Run /speckit.specify pref-2 first
  3. Or use /speckit.status to list available features
```

---

### Error 2: File Does Not Exist
```
Warning: File 'src/missing.js' not found in project

Continue adding to scope anyway? [y/N]
```

**Behavior**:
- Allow adding non-existent files (might be created later)
- Warn user clearly
- Require confirmation

---

### Error 3: Invalid Scope JSON
```
Error: Corrupted .ut-scope.json file

Solution:
  1. Backup current file: .ut-scope.json.bak
  2. Reset scope: /ut.clarify pref-2 --reset
  3. Re-add files manually
```

**Behavior**:
- Detect JSON parse errors
- Create backup of corrupted file
- Offer to reset to defaults

---

### Error 4: No Action Specified
```
Error: No action specified

Usage:
  /ut.clarify <feature-id> [options]

Options:
  --add-file <path>      Add file to scope
  --remove-file <path>   Remove file from scope
  --set <files>          Set explicit file list
  --list                 Show current scope
  --reset                Reset to auto mode
  --exclude <pattern>    Add exclusion pattern

Examples:
  /ut.clarify pref-2 --add-file src/validator.js
  /ut.clarify pref-2 --list
```

---

## Edge Cases

### Edge Case 1: First `--add-file` on Auto Mode

**Scenario**: Scope is in auto mode, user adds first file

**Behavior**:
```
Current: mode=auto (all files)
Action: --add-file src/calculator.js
Result: mode=manual, includes=[src/calculator.js]

⚠️  Mode switched from auto to manual
    Only src/calculator.js will be tested now
    Other files are excluded unless explicitly added

Continue? [y/N]
```

**Rationale**: Make mode switch explicit and clear to user

---

### Edge Case 2: Removing All Files in Manual Mode

**Scenario**: Manual mode with 2 files, user removes both

**Behavior**:
```
Current: mode=manual, includes=[calc.js, valid.js]
Action: --remove-file calc.js, --remove-file valid.js
Result: mode=auto, includes=[]

✅ All files removed. Switched back to auto mode.
   All project files will be tested (except excludes)
```

**Rationale**: Empty manual scope is meaningless → revert to auto

---

### Edge Case 3: Conflicting Actions

**Scenario**: User provides both `--add-file` and `--remove-file` for same file

**Behavior**:
```bash
/ut.clarify aa-2 --add-file src/calc.js --remove-file src/calc.js

Error: Conflicting actions for 'src/calc.js'
  • --add-file: include file
  • --remove-file: exclude file

Choose one action per file.
```

---

### Edge Case 4: Duplicate Files

**Scenario**: User adds same file multiple times

**Behavior**:
```bash
/ut.clarify aa-2 --add-file src/calc.js --add-file src/calc.js

⚠️  File 'src/calc.js' already in scope
    Skipping duplicate

Scope unchanged.
```

---

## Integration with Other Commands

### `/ut.analyze` Integration

**Behavior**: `/ut.analyze` checks `.ut-scope.json` and only analyzes scoped files

```javascript
// In /ut.analyze workflow
if (scopeFile exists) {
  if (scope.mode === "auto") {
    files = scanAllFiles(excludes: scope.excludes);
  } else {
    files = scope.includes.filter(fileExists);
  }
} else {
  files = scanAllFiles(); // Default behavior
}
```

---

### `/ut.specify` Integration

**Behavior**: `/ut.specify` considers scope when generating test scenarios

```javascript
// In /ut.specify workflow
if (scopeFile exists && scope.mode === "manual") {
  testableFiles = scope.includes;
} else {
  testableFiles = extractFromSpec(); // Auto-detect
}
```

---

### `/ut.plan` Integration

**Behavior**: `/ut.plan` only plans tests for scoped files

```javascript
// In /ut.plan workflow
if (scopeFile exists) {
  planFor = scope.includes (if manual) or allFiles (if auto);
}
```

---

### `/ut.generate` Integration

**Behavior**: `/ut.generate` only generates tests for scoped files

```javascript
// In /ut.generate workflow
if (scopeFile exists) {
  generateFor = filterByScope(plannedFiles, scope);
}
```

---

## Examples

### Example 1: Incremental Testing

**Scenario**: Large feature with 10 files, want to test one at a time

```bash
# Start with one file
/ut.specify pref-2
/ut.clarify pref-2 --set src/calculator.js
/ut.analyze pref-2
/ut.plan pref-2
/ut.generate pref-2
/ut.run pref-2

# Tests pass, add next file
/ut.clarify pref-2 --add-file src/validator.js
/ut.analyze pref-2
/ut.plan pref-2
/ut.generate pref-2
/ut.run pref-2

# Continue incrementally...
```

---

### Example 2: Forgot a File

**Scenario**: Already ran workflow, forgot to include validator.js

```bash
# Original workflow
/ut.specify pref-2
/ut.analyze pref-2   # Only found calculator.js
/ut.plan pref-2
/ut.generate pref-2

# Realize: need validator.js too
/ut.clarify pref-2 --add-file src/validator.js

# Re-run from analyze
/ut.analyze pref-2   # Now includes validator.js
/ut.plan pref-2      # Plan updated
/ut.generate pref-2  # Generate for validator.js
```

---

### Example 3: Exclude Legacy Files

**Scenario**: Project has legacy code that shouldn't be tested

```bash
/ut.clarify pref-2 --exclude "src/legacy/**/*.js"
/ut.clarify pref-2 --exclude "src/**/*.deprecated.js"

/ut.analyze pref-2  # Skips excluded files
```

---

### Example 4: Check Current Scope

**Scenario**: Unsure what's currently in scope

```bash
/ut.clarify pref-2 --list

# Output:
# Mode: manual
# Included: src/calculator.js, src/validator.js
# Excluded: **/*.test.js, src/legacy/**
```

---

### Example 5: Reset Everything

**Scenario**: Manual scope got messy, start over

```bash
/ut.clarify pref-2 --reset

# Output:
# ✅ Scope reset to auto mode
# All project files will be tested (except test files)
```

---

## Success Criteria

Command succeeds when:

1. ✅ `.ut-scope.json` file valid and updated
2. ✅ Scope accurately reflects user's intent
3. ✅ Conflicting actions detected and prevented
4. ✅ User receives clear feedback on changes
5. ✅ Next steps are actionable
6. ✅ Affected artifacts flagged for update
7. ✅ No data loss (files not accidentally excluded)

---

## Testing Checklist

Before marking this command complete, test:

- [ ] `--add-file` on auto mode (switches to manual)
- [ ] `--add-file` on manual mode (appends to list)
- [ ] `--remove-file` on auto mode (adds to excludes)
- [ ] `--remove-file` on manual mode (removes from includes)
- [ ] `--set` with multiple files (replaces scope)
- [ ] `--exclude` with glob patterns
- [ ] `--reset` (reverts to auto)
- [ ] `--list` (displays without changing)
- [ ] Multiple actions in one command
- [ ] Duplicate file handling
- [ ] Non-existent file handling
- [ ] Empty scope handling (auto mode fallback)
- [ ] JSON formatting (valid, pretty-printed)
- [ ] Integration with /ut.analyze (respects scope)

---

## Performance Considerations

- **Scope file size**: Should be < 1KB for typical projects
- **Command execution**: < 2 seconds
- **File existence checks**: Use fast file system API
- **JSON parsing**: Handle gracefully if file is large

---

## Future Enhancements

Potential improvements for v2:

1. **Interactive mode**: `/ ut.clarify aa-2 --interactive`
   - Show list of files
   - User selects with checkboxes
   - Confirm and save

2. **Scope templates**: `--template=unit-only`
   - Pre-defined scope patterns
   - E.g., "only-src", "exclude-config", etc.

3. **Diff view**: Show before/after scope changes
   ```
   - src/old-file.js
   + src/new-file.js
   ```

4. **Undo/history**: `--undo` to revert last change
   - Keep history of scope changes
   - Allow rollback

5. **Import from .gitignore**: `--from-gitignore`
   - Use exclude patterns from .gitignore

---

## Notes

- This command is **optional** - workflow works without it
- Default behavior (no scope file) is to test all files
- Scope persists across workflow commands
- Scope file should be committed to Git (team-shared)
- Manual mode gives more control, auto mode is more convenient

---

**Command Status**: Ready for implementation
**Priority**: Medium (nice-to-have for v1, essential for v1.1)
**Estimated Effort**: 6-8 hours (prompt + script + testing)
