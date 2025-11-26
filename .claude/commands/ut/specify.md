# /ut.specify - Create Unit Test Specification

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

## Purpose

Generate a comprehensive test specification document that defines what needs to be tested for a feature. This specification will guide test implementation by identifying testable units, test scenarios, coverage goals, and mocking requirements.

## Input

- **Feature ID**: Required argument (e.g., `pref-2`)
- **Feature Spec**: Reads from `.specify/features/{feature-id}/spec.md`
- **Optional**: Existing test-spec.md for updates

## Output

Creates or updates `.specify/features/{feature-id}/test-spec.md` with:

1. **Metadata**: Feature reference, timestamps, version, status
2. **Test Scenarios**: Prioritized test scenarios with test cases
3. **Coverage Goals**: Target coverage percentage, critical paths, edge cases
4. **Mocking Needs**: External services, databases, file system dependencies
5. **Test Data Requirements**: Input/output examples, fixtures needed
6. **Constraints**: Timeouts, resource limits, environment requirements

## Execution Instructions

### Step 0: Execute Bash Script

**CRITICAL**: This step MUST complete before any other operations.
**NOTE**: Users must create feature branch manually before running this command.

1. **Validate Task ID**:
   - Extract first argument from user input
   - **Check if task ID provided**:
     ```
     If first argument is EMPTY or MISSING:
       ERROR: "Task ID required. Usage: /ut:specify {task-id}"
       STOP - Do NOT proceed
     ```
   - Expected format: `[folder/]prefix-number`
   - Examples (assuming prefix=pref):
     - ✅ `/ut:specify pref-991 create UT for @file.ts` → feature ID: `pref-991`
     - ✅ `/ut:specify AL-991 description` → feature ID: `AL-991`
     - ✅ `/ut:specify test/pref-123 description` → feature ID: `test/pref-123`
     - ❌ `/ut:specify create UT` → ERROR (no task ID)

2. **Execute Script**:

   **IMPORTANT - Cross-platform compatibility**:
   - Use `bash` command explicitly (works on Windows Git Bash, WSL, Linux, macOS)
   - Always quote the script path if it contains spaces
   - Use forward slashes `/` in paths (Git Bash converts automatically)

   ```bash
   bash .specify/scripts/bash/ut/specify.sh <feature-id>
   ```

   Examples:
   ```bash
   # Linux/macOS/Git Bash
   bash .specify/scripts/bash/ut/specify.sh pref-991

   # Works with any feature ID format
   bash .specify/scripts/bash/ut/specify.sh AL-991
   bash .specify/scripts/bash/ut/specify.sh test/pref-123
   ```

   **Windows-specific notes**:
   - Git Bash is required (installed with Git for Windows)
   - Do NOT use `cd /d` (Bash doesn't understand Windows drive syntax)
   - Current directory must be repo root before executing
   - Paths with spaces are handled automatically by Git Bash

3. **Script Operations** (automatic):
   - Validates feature directory exists at `.specify/features/pref-991/`
   - Validates spec.md exists at `.specify/features/pref-991/spec.md`
   - Checks for existing test-spec.md (interactive prompt if found)
   - Outputs summary with feature ID, paths, and mode

4. **Wait for Script Completion**:
   - **DO NOT proceed** until script finishes successfully
   - Script output confirms: "✅ Ready for AI agent processing"
   - All file operations will be in `.specify/features/{feature-id}/`

**Error Handling**:
- If feature directory not found → Script exits with error, stop workflow
- If spec.md not found → Script exits with error, suggest `/speckit.specify`

### Step 1: Validate Prerequisites

After bash script (Step 0) completes successfully, verify:

1. **Feature directory exists**: `.specify/features/{feature-id}/`
2. **Spec file exists**: `.specify/features/{feature-id}/spec.md`
3. **Script output confirmed**: "✅ Ready for AI agent processing"

If any validation fails:
- ERROR: "Prerequisites not met. Ensure Step 0 completed successfully."
- Do NOT proceed to Step 2

### Step 2: Check and Create UT Rules (First-Time Setup)

**IMPORTANT**: Only proceed after Step 0 (bash script) AND Step 1 (prerequisites) complete.

This step ensures project has `ut-rule.md` defining unit testing standards.

**CRITICAL**: Runs ONLY ONCE per project (first time `/ut:specify` called).

#### 2.1 Check for Existing UT Rules

**IMPORTANT**: Check ONLY this specific location:

```bash
{repo-root}/docs/rules/test/ut-rule.md
```

**Check logic**:
- If file exists → **Skip to Step 3** (rules already exist, one-time creation complete)
- If file NOT exists → Continue to Step 2.2 (first-time setup)

**Do NOT search** in other locations. Path is fixed and standardized.

#### 2.2 Detect Framework (If No Rules Found)

**Scan configuration files**:

**From package.json** (JavaScript/TypeScript):
```json
{
  "devDependencies": {
    "vitest": "^3.2.4",  // → Framework: Vitest
    "jest": "^29.7.0",   // → Framework: Jest
    "@angular/cli": "*"  // → Framework: Angular + Jasmine/Karma
  }
}
```

**From pyproject.toml** (Python):
```toml
[tool.poetry.dev-dependencies]
pytest = "^7.4.0"  # → Framework: Pytest
```

**Extract**:
- Framework name (e.g., "Vitest", "Jest", "Pytest")
- Framework version (e.g., "3.2.4")

**IMPORTANT - User Confirmation Required**:

After detection, **MUST** ask user to confirm:

```
Use `AskUserQuestion` tool:

Framework Detection
   Detected: {Framework} {Version} in {config-file}

Question: "Use {Framework} {Version} for UT rules?"
Options:
  [ ] Yes, use {Framework} {Version}
  [ ] No, specify different framework
  [ ] Skip framework detection
```

**WAIT for user response** before proceeding to Step 2.3

#### 2.3 Scan Existing Tests (If Any)

**Search for test files**:
- JavaScript/TypeScript: `**/*.test.{js,ts,tsx}`, `**/*.spec.{js,ts,tsx}`
- Python: `**/test_*.py`, `**/*_test.py`

**If test files found**, analyze patterns:
1. **Naming patterns**:
   - Count "should" pattern usage
   - Count "it/test" pattern usage
2. **Matchers used** (from imports and usage):
   - `toBe`, `toEqual`, `toStrictEqual`, etc.
3. **Mocking patterns**:
   - `vi.mock()`, `jest.mock()`, `@patch`, etc.
4. **File organization**:
   - Co-located vs `__tests__/` vs `tests/`

**IMPORTANT - User Confirmation Required**:

If existing tests found, **MUST** present findings and ask:

```
Use `AskUserQuestion` tool:

Existing Test Analysis
   Found: {count} test files
   Detected patterns:
   - File naming: {*.spec.ts or *.test.ts}
   - Test syntax: {describe/it or test/expect}
   - Matchers: {list of matchers}
   - Organization: {co-located or __tests__/}

Question: "Follow these existing patterns for new tests?"
Options:
  [ ] Yes, use detected patterns
  [ ] No, let me customize
  [ ] Ignore existing tests, start fresh
```

**WAIT for user response** before proceeding to Step 2.4

**If NO existing tests found** → Continue to Step 2.4 with framework defaults

#### 2.4 Gather UT Rules Preferences

**CRITICAL**: User MUST approve ALL decisions. NO auto-generation.

**Process** - Ask user for preferences on multiple settings:

Use `AskUserQuestion` tool with multiple questions (1-4 questions at once):

```
Questions:
1. Naming Convention
   Question: "Which test naming pattern?"
   Header: "Naming"
   Options:
     [ ] "should" pattern - "should return 200 when valid"
     [ ] "it" pattern - "it returns 200 when valid"
   Description for each option explaining use case

2. Coverage Targets
   Question: "Set coverage targets:"
   Header: "Coverage"
   Options:
     [ ] 80%/90%/70% - Recommended: 80% general, 90% critical, 70% edge
     [ ] Custom targets - Specify your own percentages
     [ ] No coverage requirements

3. Mocking Strategy
   Question: "Preferred mocking strategy:"
   Header: "Mocking"
   Options:
     [ ] vi.mock() - Auto-mock imports (recommended for Vitest)
     [ ] vi.spyOn() - Spy on specific methods
     [ ] vi.fn() - Manual mock functions
     [ ] Mixed approach - Use all approaches

4. File Organization
   Question: "Test file organization:"
   Header: "Structure"
   Options:
     [ ] Co-located - Next to source files
     [ ] __tests__/ - Subdirectories
     [ ] tests/ - Separate directory
```

**IMPORTANT**:
- NEVER assume user wants "best practices"
- ALWAYS present options, let user choose
- WAIT for explicit confirmation before generation
- Store ALL user selections for Step 2.5

**After collecting preferences** → Continue to Step 2.5

#### 2.5 Generate UT Rules File and Preview

**Load template**: `.specify/templates/ut-rule-template.md`

**Fill placeholders based on user selections**:

1. **Framework** (from Step 2.2):
   - `[FRAMEWORK_NAME]` → User-confirmed framework
   - `[VERSION]` → User-confirmed version
   - `[IMPORT_EXAMPLE]` → Framework-specific imports

2. **Patterns** (from Step 2.3 or Step 2.4):
   - `[PATTERN]` → User-selected naming pattern
   - `[PATTERN_TYPE]` → User-selected organization
   - `[MOCKING_EXAMPLE]` → User-selected mocking strategy

3. **Coverage** (from Step 2.4):
   - `[PERCENTAGE]` → User-selected thresholds
   - `[CRITICAL_PERCENTAGE]` → Critical path coverage

**Generate preview** (first 20 lines of generated content)

**CRITICAL - Final User Confirmation Required**:

```
Use `AskUserQuestion` tool:

UT Rules Preview

Generated rules based on your selections:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Framework: {Framework} {Version}
Naming: {Pattern}
Coverage: {Thresholds}
Mocking: {Strategy}
Organization: {Structure}
File pattern: {*.test.ts or *.spec.ts}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Preview (first ~30 lines or 30% of file):
[Display generated content preview]
...

Question: "Create ut-rule.md with these settings?"
Header: "Confirm"
Options:
  [ ] Yes, create file - Save to docs/rules/test/ut-rule.md
  [ ] Modify settings - Go back and change options
  [ ] Show full preview - Display complete file content first
```

**WAIT for user response**:
- If "Yes" → Continue to Step 2.6
- If "Modify" → Go back to Step 2.4
- If "Show full preview" → Display entire content, then ask again

#### 2.6 Save UT Rules

**Fixed location**: `{repo-root}/docs/rules/test/ut-rule.md`

**Steps**:
1. Create directory structure if not exists:
   ```bash
   mkdir -p docs/rules/test
   ```

2. Save generated rules to:
   ```
   docs/rules/test/ut-rule.md
   ```

3. Confirm creation:
   ```
   ✅ UT Rules created: docs/rules/test/ut-rule.md

   Framework: Vitest 3.2.4
   Rules defined:
     • Test files: *.test.ts in __tests__/ subdirectories
     • Naming: "should {action}" pattern
     • Matchers: toBe, toEqual, toThrow, toBeCloseTo
     • Coverage: 80% target (90% for critical paths)

   These rules will be applied when generating tests.

   Proceeding to create test specification...
   ```

**IMPORTANT**: Path is fixed, no alternatives. Always create at `docs/rules/test/ut-rule.md`.

### Step 3: Load Test Specification Template

1. Read the template from `.specify/templates/test-spec-template.md`
2. Use this template structure to ensure consistency across all features
3. Template provides:
   - Standardized section headings and format
   - Quality checklist built-in
   - Example structures for test scenarios
   - Guidance comments for each section

### Step 4: Analyze Feature Specification

Read and extract from spec.md:

- **Functional Requirements (FR-*)**: Each requirement becomes a test scenario
- **User Stories**: Each story's acceptance criteria become test cases
- **Edge Cases**: Listed edge cases become specific test scenarios
- **Key Entities**: Entities define data structures to test
- **Success Criteria**: Measurable outcomes become coverage goals

### Step 5: Generate Test Scenarios

For each functional requirement and user story:

1. **Create Test Scenario**:
   - Scenario ID: `TS-{number}` (e.g., TS-001)
   - Description: What aspect of the feature is being tested
   - Priority: Based on user story priority (P1-P6)

2. **Generate Test Cases**:
   - Test ID: `TC-{number}` (e.g., TC-001)
   - Description: Specific test case name
   - Given/When/Then: BDD-style test definition
   - Expected Input/Output: Data structures
   - Edge Cases: Boundary conditions

### Step 6: Identify Coverage Goals

1. **Calculate Target Coverage**:
   - Critical features (P1-P2 user stories): 90%+ coverage
   - Important features (P3-P4): 80%+ coverage
   - Nice-to-have (P5-P6): 70%+ coverage

2. **List Critical Paths**: Happy paths from user stories
3. **List Edge Cases**: From spec.md edge cases section + inferred boundary conditions

### Step 7: Determine Mocking Needs

Analyze functional requirements for:

- **External Services**: APIs, third-party services mentioned
- **Databases**: Data persistence requirements
- **File System**: File I/O operations
- **Time/Date**: Time-dependent logic
- **Network**: HTTP requests, WebSockets

For each dependency:
- Name: What is being mocked
- Type: service | database | filesystem | time | network
- Reason: Why mocking is needed
- Strategy: How to mock (stub, spy, full mock)

### Step 8: Format Output Document

Using the template from `.specify/templates/test-spec-template.md`, populate it with generated content:

1. **Replace placeholders**: Fill in feature name, date, feature-id, etc.
2. **Map requirements**: Link each TS-### to corresponding FR-### from spec.md
3. **Add independent test descriptions**: For each scenario, describe how it can be tested independently
4. **Populate test cases**: Generate TC-### with Given/When/Then format
5. **Include quality checklist**: Auto-generate checklist validation at end of document

The template structure is:

```markdown
# Test Specification: {Feature Name}

**Feature**: {feature-id}
**Created**: {date}
**Version**: 1.0.0
**Status**: Draft

## Source

- Feature Spec: `.specify/features/{feature-id}/spec.md`
- Code Modules: {list source files if known, or "TBD"}

## Test Scenarios

### TS-001: {Scenario Description} (Priority: P1)

**What**: Testing {functional requirement}

#### Test Cases

##### TC-001: {Test case description}

- **Given**: {Initial state}
- **When**: {Action performed}
- **Then**: {Expected outcome}
- **Input**: `{example input data}`
- **Output**: `{expected output data}`
- **Edge Cases**: {boundary conditions}

{Repeat for all test cases in scenario}

{Repeat for all scenarios}

## Coverage Goals

- **Target Coverage**: 80% (adjust based on priorities)
- **Critical Paths**:
  1. {Happy path 1}
  2. {Happy path 2}
- **Edge Cases to Cover**:
  1. {Edge case 1}
  2. {Edge case 2}

## Mocking Requirements

### External Services

- **{Service Name}**: {Mocking strategy and reason}

### Database

- **{Database operations}**: {Mocking strategy}

### File System

- **{File operations}**: {Mocking strategy}

## Test Data Requirements

### Fixtures

- **{Fixture name}**: {Description of test data needed}

### Sample Inputs/Outputs

```{language}
// Example test data structures
```

## Constraints

- **Timeouts**: {Any time-sensitive operations}
- **Environment**: {Special environment requirements}
- **Dependencies**: {Test framework, mocking libraries}

## Notes

{Any additional testing considerations}
```

### Step 9: Generate Quality Checklist Validation

After generating test-spec.md, automatically create a validation checklist at:
`.specify/features/{feature-id}/checklists/test-requirements.md`

This checklist should include:

```markdown
# Test Specification Quality Checklist

**Feature**: {feature-id}
**Created**: {date}
**Status**: Pending Validation

## Completeness

- [ ] All functional requirements (FR-###) have corresponding test scenarios (TS-###)
- [ ] All user stories have test cases covering acceptance criteria
- [ ] Edge cases from spec.md are included in test scenarios
- [ ] All test scenarios have priority assigned (P1/P2/P3)
- [ ] Critical paths are clearly documented

## Quality

- [ ] Mocking needs are identified for all external dependencies
- [ ] Coverage goals are realistic and measurable (70-90% range)
- [ ] Test IDs are unique and sequential (no gaps or duplicates)
- [ ] Given/When/Then format is used consistently across all test cases
- [ ] Sample inputs/outputs are provided for complex data structures

## Clarity

- [ ] Each test scenario has "Maps to" section linking to FR-###
- [ ] Each test scenario has "Independent Test" description
- [ ] No [NEEDS TEST CLARIFICATION] markers remain in the document
- [ ] Mocking strategies are clearly defined

## Validation Result

**Score**: __/13 items completed

**Status**: 
- ✅ Pass: 13/13 items checked
- ⚠️ Needs Review: 10-12/13 items checked
- ❌ Incomplete: <10/13 items checked

**Notes**: [Add validation notes here]
```

### Step 10: Handle Existing Test Spec

If `test-spec.md` already exists:

1. Read existing content
2. Ask user: "Test specification already exists. Options:
   - **Update**: Merge new scenarios with existing (recommended)
   - **Replace**: Create fresh specification
   - **Cancel**: Keep existing unchanged"
3. Wait for user response
4. If Update: Preserve existing test IDs, add new scenarios with next available IDs
5. If Replace: Generate completely new specification

### Step 11: Write Output

1. Create or update `.specify/features/{feature-id}/test-spec.md`
2. Create validation checklist at `.specify/features/{feature-id}/checklists/test-requirements.md`
3. Confirm success with summary:
   ```
   ✅ Test specification created at .specify/features/{feature-id}/test-spec.md
   ✅ Quality checklist created at .specify/features/{feature-id}/checklists/test-requirements.md
   
   Summary:
   - {X} test scenarios generated (TS-001 to TS-{X})
   - {Y} test cases defined (TC-001 to TC-{Y})
   - Target coverage: {Z}%
   - Mocking requirements: {count} dependencies identified
   
   Next step: Run /ut.analyze {feature-id} to identify test coverage gaps
   ```

## Quality Checklist

Before finalizing test-spec.md, verify:

- [ ] All functional requirements have corresponding test scenarios
- [ ] All user stories have test cases covering acceptance criteria
- [ ] Edge cases from spec.md are included
- [ ] Mocking needs are identified for all external dependencies
- [ ] Coverage goals are realistic and measurable
- [ ] Test IDs are unique and sequential
- [ ] Given/When/Then format is used consistently
- [ ] Sample inputs/outputs are provided for complex data structures

## Example Usage

```bash
# Create test specification for feature pref-991
/ut:specify pref-991

# Step 0: Bash script executes
# Checking feature directory...
# ✅ Feature directory found: .specify/features/pref-991/
# ✅ Spec file found: .specify/features/pref-991/spec.md
# Switched to branch 'features/pref-991'
# 📊 Test Specification Generation
# ================================
# Feature ID: pref-991
# Branch: features/pref-991
# ✅ Ready for AI agent processing

# Step 1: Prerequisites validated
# ✅ Feature directory exists
# ✅ Spec file exists
# ✅ Current branch: features/pref-991

# Step 2: Checking for ut-rule.md...
# Looking for: docs/rules/test/ut-rule.md
# → NOT FOUND (first time)
# Detected: Vitest 3.2.4 in package.json
#
# [AI asks user to confirm framework, patterns, preferences...]
# [User selects options via AskUserQuestion prompts...]
#
# ✅ UT Rules created: docs/rules/test/ut-rule.md

# Steps 3-11: Generate test-spec.md
# Analyzing feature specification...
# Generating test scenarios for 6 user stories...
# Identified 24 test cases across 12 scenarios
# ✅ Test specification created at .specify/features/pref-991/test-spec.md
#
# Next step: Run /ut:analyze pref-991 to identify test coverage gaps
```

**Subsequent runs** (ut-rule.md already exists):
```bash
/ut:specify pref-992

# Step 0: Branch created
# Step 1: Prerequisites validated
# Step 2: Check ut-rule.md → FOUND ✓ (skip to Step 3)
# Steps 3-11: Generate test-spec.md directly
# ✅ Test specification created
```

## Error Handling

- **Missing spec.md**: Prompt user to run `/speckit.specify` first
- **Malformed spec.md**: Report specific issues found, ask user to fix
- **Empty spec.md**: Cannot generate test spec, requires functional requirements
- **Write permission issues**: Report error, suggest checking file permissions

## Notes

- This is a **prompt-based workflow** - no custom code execution
- AI agent performs all analysis and generation
- Generated test-spec.md is a **planning document**, not executable tests
- Subsequent commands (`/ut.analyze`, `/ut.plan`, `/ut.generate`) will use this spec
