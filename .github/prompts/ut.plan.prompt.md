# /ut.plan - Generate Test Implementation Plan

## Purpose

Create a structured test implementation plan that defines test file organization, suite structure, mocking strategy, and step-by-step implementation tasks based on test specification and coverage analysis.

## Input

- **Feature ID**: **REQUIRED** argument (e.g., `aa-2`, `AL-991`, `test/aa-123`)
  - Format: `[folder/]prefix-number`
  - Prefix configured in `.specify/.speckit.env`
  - If missing: ERROR "Task ID required. Usage: /ut:plan {task-id}"
- **Test Spec**: Reads from `.specify/features/{feature-id}/test-spec.md`
- **Coverage Report**: Reads from `.specify/features/{feature-id}/coverage-report.json`

## Output

Creates `.specify/features/{feature-id}/test-plan.md` with:

1. **Test Structure**: Directory organization, naming conventions
2. **Test Suites**: File locations, test hierarchy
3. **Mocking Strategy**: What to mock, how to mock
4. **Implementation Tasks**: Priority-ordered task list
5. **Execution Order**: Dependencies and sequencing

## Execution Instructions

### Step 0: Validate Task ID

**CRITICAL**: Check task ID argument FIRST before any operations.

1. **Parse user input**:
   - Extract first argument from command
   - Expected format: `[folder/]prefix-number` (e.g., `aa-991`, `AL-991`, `test/aa-123`)

2. **Check if task ID provided**:
   ```
   If first argument is EMPTY or MISSING:
     ERROR: "Task ID required. Usage: /ut:plan {task-id}"
     STOP - Do NOT proceed to Step 1
   ```

3. **Validate task ID format**:
   - Must match pattern: `[folder/]prefix-number`
   - Prefix must be in `.specify/.speckit.env` SPECKIT_PREFIX_LIST
   - If invalid: ERROR "Invalid task ID format: '{input}'"

**Examples**:
- ✅ CORRECT: `/ut:plan aa-991`
- ✅ CORRECT: `/ut:plan AL-991`
- ✅ CORRECT: `/ut:plan test/aa-123`
- ❌ WRONG: `/ut:plan` (no task ID)
- ❌ WRONG: `/ut:plan create plan` (not a task ID)

### Step 1: Load Input Artifacts

1. **Validate inputs exist**:
   - test-spec.md: Test scenarios and coverage goals
   - coverage-report.json: Untested code and framework detection

2. **If missing**:
   - test-spec.md → "Run `/ut.specify {feature-id}` first"
   - coverage-report.json → "Run `/ut.analyze {feature-id}` first"

### Step 2: Determine Test Structure

Based on coverage-report.json framework detection:

**For Jest/Vitest**:
```
Option 1: Co-located tests
src/
├── calculator.ts
├── calculator.test.ts
├── cart.ts
└── cart.test.ts

Option 2: Separate __tests__ directory
src/
├── calculator.ts
├── cart.ts
└── __tests__/
    ├── calculator.test.ts
    └── cart.test.ts
```

**For Pytest**:
```
Option 1: tests/ directory (recommended)
tests/
├── unit/
│   ├── test_calculator.py
│   └── test_cart.py
└── integration/
    └── test_checkout.py

Option 2: Co-located
src/
├── calculator.py
├── test_calculator.py
├── cart.py
└── test_cart.py
```

**Decision Logic**:
- Pattern detection handled in Step 2.5 below
- This step shows examples only
- Actual decision made after scanning existing tests

### Step 2.5: Detect Test Organization Pattern (NEW - Framework-Aware)

**Purpose**: Auto-detect existing test pattern OR recommend framework-specific convention

#### 2.5.1 Scan for Existing Tests

**Search locations**:
1. **Common test directories**:
   - `/test/`, `/tests/`, `/__tests__/`, `/spec/`
   - `{ProjectName}.Tests/` (dotnet)
   - `{ProjectName}Test/` (Java)

2. **Co-located patterns**:
   - `*.test.{js,ts,tsx,jsx}`, `*.spec.{js,ts,tsx,jsx}`
   - `test_*.py`, `*_test.py`
   - `*.spec.ts` (Angular)

3. **Analyze found tests**:
```javascript
{
  "existingTests": {
    "found": true,
    "patterns": [
      {
        "type": "co-located",
        "count": 24,
        "percentage": 89,
        "examples": ["src/calculator.test.ts", "src/validator.test.ts"]
      },
      {
        "type": "directory",
        "path": "__tests__/",
        "count": 3,
        "percentage": 11,
        "examples": ["__tests__/utils.test.ts"]
      }
    ],
    "dominantPattern": "co-located" // if percentage > 70%
  }
}
```

#### 2.5.2 Decision Logic

**Case 1: Dominant Pattern Found (>70%)**
```
✓ Following existing project convention: Co-located tests (*.test.ts)
  Pattern detected: 24 files (89%) use this structure
  Proceeding with co-located organization...
```
→ **Use automatically**, no user prompt needed

**Case 2: Split Pattern (30-70%)**
```
⚠️ Multiple test patterns detected in project:
  - Co-located (*.test.ts): 14 files (58%)
  - Directory (__tests__/): 10 files (42%)

Recommended: Co-located (slightly dominant pattern)

Options:
  1. Use co-located pattern [Enter]
  2. Use __tests__/ directory
  3. Custom pattern (specify)

Choice:
```
→ **Prompt user** for decision

**Case 3: No Tests Found + Known Framework**
```
No existing tests found.

Detected framework: Nuxt 4.2.1

Recommended convention for Nuxt:
  Pattern: Directory-based
  Structure: /tests/**/*.test.ts
  Rationale: Official Nuxt documentation recommendation

Options:
  1. Use recommended convention [Enter]
  2. Specify custom pattern
  3. Research alternatives (30s)

Choice:
```
→ **MANDATORY**: Use `AskUserQuestion` tool to prompt user with framework recommendation
→ Show framework convention from database (2.5.3) with rationale
→ Provide options: Recommended pattern, Alternative patterns, Custom
→ Wait for user decision before proceeding

**Case 4: No Tests + Unknown/Ambiguous Framework**
```
No existing tests found.
Framework: {framework} (no standard test convention)

Common patterns for {framework}:
  1. Co-located tests (*.test.ts) - Easy navigation
  2. /tests/ directory - Clean separation
  3. __tests__/ subdirectories - Jest/Vitest convention

Preferred test organization:
```
→ **Ask user directly**

#### 2.5.3 Framework Convention Database

**Angular**:
- Pattern: Co-located
- Files: `*.spec.ts`
- Rationale: Official Angular CLI convention (ng generate component creates .spec.ts)

**Nuxt/Vue**:
- Pattern: Directory
- Files: `/tests/**/*.test.{js,ts}`
- Alternative: `/test/` or `__tests__/`
- Rationale: Nuxt docs recommend `/tests/` directory

**React**:
- Pattern: Directory or Co-located (community split)
- Files: `__tests__/*.test.{js,tsx}` OR `*.test.{js,tsx}`
- Rationale: No official standard, React doesn't enforce pattern
- Recommendation: `__tests__/` for cleaner src/

**Next.js**:
- Pattern: Same as React (inherits)
- Files: `__tests__/*.test.{js,tsx}` OR `*.test.{js,tsx}`
- Note: Check if using App Router vs Pages Router

**dotnet**:
- Pattern: Separate test project
- Files: `{ProjectName}.Tests/`
- Structure: Mirror src/ structure inside Tests project
- Rationale: Official .NET convention, enforced by tooling

**Python/Pytest**:
- Pattern: Directory
- Files: `/tests/test_*.py` OR `/tests/*_test.py`
- Rationale: Pytest discovery convention
- Alternative: `pytest.ini` can customize discovery

**Go**:
- Pattern: Co-located
- Files: `*_test.go`
- Rationale: Go testing package convention

**Java (Maven/Gradle)**:
- Pattern: Separate directory
- Files: `src/test/java/` (mirrors `src/main/java/`)
- Rationale: Maven standard directory layout

#### 2.5.4 Save Pattern Decision

**Add to test-plan.md**:
```markdown
## Test Organization Decision

**Pattern**: {chosen-pattern}
**Structure**: {file-structure}
**Detected from**: {existing-tests | framework-convention | user-preference}
**Confidence**: {high | medium | low}

### Rationale
{why-this-pattern-was-chosen}

### Directory Structure
{detailed structure diagram}
```

**Example output**:
```markdown
## Test Organization Decision

**Pattern**: Co-located tests
**Structure**: `{source-dir}/{filename}.test.ts`
**Detected from**: Existing project tests (89% using this pattern)
**Confidence**: High

### Rationale
Project already uses co-located tests extensively (24 out of 27 test files).
Following existing convention for consistency.

### Directory Structure
```
composables/
├── useCalculator.ts
├── useCalculator.test.ts  ← test file
utils/
├── validator.ts
└── validator.test.ts      ← test file
```

#### 2.5.5 Special Cases

**Monorepo Detection**:
- Check for `pnpm-workspace.yaml`, `lerna.json`, `nx.json`
- If monorepo: Each package may have different pattern
- Ask user: "Detected monorepo. Apply pattern to all packages or configure per package?"

---

### Step 2.6: Load UT Rules (If Available)

**Purpose**: Apply project-wide testing standards from `ut-rule.md`

**IMPORTANT**: This step applies rules that override defaults but does NOT override user decisions from previous steps

#### 2.6.1 Check for UT Rules File

Look for `ut-rule.md` in:
1. `/tests/ut-rule.md`
2. `/docs/ut-rule.md`
3. `/.specify/ut-rule.md`

**If NOT found** → Skip to Step 3 (use framework defaults)
**If found** → Continue to Step 2.6.2

#### 2.6.2 Read and Extract Rules

**Load file** and extract:

1. **Naming Conventions**:
   - Test file pattern (e.g., `*.test.ts`)
   - Test case naming (e.g., "should {action}")
   - Describe block pattern

2. **Framework-Specific Syntax**:
   - Import statement
   - Preferred matchers (toBe, toEqual, toStrictEqual, etc.)
   - Error assertion style (toThrow, pytest.raises)

3. **Test Structure**:
   - Preferred pattern (AAA, Given-When-Then)
   - Comments policy
   - Assertions per test

4. **Mocking Strategy**:
   - External APIs (vi.mock, jest.mock, @patch)
   - Database (in-memory, mocks)
   - File system strategy
   - Time/date mocking

5. **Coverage Requirements**:
   - Overall target (e.g., 80%)
   - Critical paths target (e.g., 90%)
   - Priority-based targets

**Example extraction**:
```javascript
{
  "naming": {
    "testFile": "*.test.ts",
    "testCase": "should {action} {when condition}",
    "describeBlock": "Component/function name"
  },
  "matchers": {
    "primitives": "toBe()",
    "objects": "toEqual()",
    "decimals": "toBeCloseTo(value, precision)",
    "errors": "toThrow('exact message')"
  },
  "structure": {
    "pattern": "AAA",
    "commentsPolicy": "Only for complex setup",
    "assertionsPerTest": "Prefer one"
  },
  "mocking": {
    "externalApis": "vi.mock() at file top",
    "database": "In-memory SQLite",
    "time": "vi.useFakeTimers()"
  },
  "coverage": {
    "overall": "80%",
    "critical": "90%",
    "p1": "95%",
    "p2": "85%"
  }
}
```

#### 2.6.3 Apply Rules to Test Plan

**Integrate rules into test-plan.md generation**:

1. **Naming section**:
   ```markdown
   ## Test Structure

   **File Naming**: {from ut-rule.md}
   **Test Case Pattern**: {from ut-rule.md}

   Example:
   ```typescript
   // File: composables/__tests__/useCalculator.test.ts
   describe('useCalculator', () => {
     it('should return sum when given two valid numbers', () => {
       // AAA pattern (from ut-rule.md)
       // Arrange
       const a = 5, b = 3
       // Act
       const result = add(a, b)
       // Assert
       expect(result).toBe(8)  // ← Matcher from ut-rule.md
     })
   })
   ```
   ```

2. **Coverage goals** (merge with test-spec.md goals):
   ```markdown
   ## Coverage Goals

   **From ut-rule.md**:
   - Overall: {overall_target}
   - Critical paths (P1): {p1_target}
   - Important (P2): {p2_target}

   **From test-spec.md**:
   - Feature-specific goals: {feature_coverage}

   **Final targets** (stricter of the two):
   - Overall: MAX(ut-rule, test-spec)
   - Per-priority: MAX(ut-rule, test-spec)
   ```

3. **Mocking strategy**:
   ```markdown
   ## Mocking Strategy

   **Project standards** (from ut-rule.md):
   - External APIs: {strategy}
   - Database: {strategy}
   - Time/Date: {strategy}

   **Feature-specific** (from test-spec.md):
   - {specific_mocks_for_this_feature}
   ```

4. **Test case templates** (use rules for generation):
   ```markdown
   ## Implementation Tasks

   ### Task 1: Create test file
   - File: {path from Step 2.5}
   - Naming: {pattern from ut-rule.md}
   - Structure: {pattern from ut-rule.md}
   - Matchers: {preferred matchers from ut-rule.md}

   Example test case (following ut-rule.md):
   ```typescript
   import { {imports from ut-rule.md} } from 'vitest'

   it('{naming pattern from ut-rule.md}', () => {
     // {structure pattern from ut-rule.md}
     // Arrange
     ...
     // Act
     ...
     // Assert
     expect(result).{matcher from ut-rule.md}(expected)
   })
   ```
   ```

#### 2.6.4 Note Rules in Test Plan

**Add section to test-plan.md**:
```markdown
## UT Rules Applied

**Source**: /tests/ut-rule.md
**Version**: {version from ut-rule.md}

**Rules enforced**:
- ✅ Naming: {pattern}
- ✅ Structure: {AAA/Given-When-Then}
- ✅ Matchers: {preferred matchers}
- ✅ Mocking: {strategies}
- ✅ Coverage: {targets}

**Reference**: See /tests/ut-rule.md for complete rules

**Note**: All generated tests MUST follow these rules for consistency.
```

#### 2.6.5 Conflict Resolution

**If ut-rule.md conflicts with test-spec.md or user decisions**:

**Priority order** (highest to lowest):
1. **User decisions from Step 2.5** (test organization pattern chosen by user)
2. **ut-rule.md** (project-wide standards)
3. **test-spec.md** (feature-specific requirements)
4. **Framework defaults**

**Example conflict**:
- ut-rule.md says: "Coverage: 80%"
- test-spec.md says: "Coverage: 85%" (higher)
- **Resolution**: Use 85% (stricter requirement wins)

**Example non-conflict**:
- ut-rule.md says: "Use toBe() for primitives"
- test-spec.md silent on matchers
- **Resolution**: Use toBe() from ut-rule.md

**Migration Scenario**:
- Old tests: `/test/` directory
- New tests: `__tests__/` directory
- Action: Recommend completing migration OR staying with old pattern
- Warn: "Inconsistent patterns detected. Consider standardizing."

**No Source Files**:
- If no `.js/.ts/.py` files found in expected locations
- Warn: "No source files detected. Test plan may be incomplete."
- Ask: "Specify source directory?"

### Step 3: Define Test Suites

For each test scenario from test-spec.md:

```markdown
### Test Suite: {Scenario Description}

**File**: `{test-file-path}`
**Source**: `{source-file-path}`
**Priority**: {P1-P6}

#### Test Cases

1. **{Test ID}**: {Test description}
   - Type: unit | integration
   - Setup: {Required fixtures/mocks}
   - Assertions: {Expected outcomes}

2. **{Test ID}**: {Test description}
   ...
```

**File Naming**:
- Jest/Vitest: `{source-name}.test.{ext}`
- Pytest: `test_{source-name}.py`

### Step 4: Plan Mocking Strategy

Based on test-spec.md mocking needs and coverage-report.json dependencies:

```markdown
## Mocking Strategy

### External Services

**{Service Name}** (e.g., "Payment API")
- **Location**: Used in `src/payment.ts`
- **Mock Type**: Full mock
- **Library**: `jest.mock()` or `vi.mock()`
- **Implementation**:
  ```typescript
  jest.mock('./api/payment', () => ({
    processPayment: jest.fn()
  }));
  ```
- **Test Data**: Sample success/failure responses

### Database

**{Database operations}**
- **Location**: Used in `src/repository.ts`
- **Mock Type**: In-memory mock
- **Strategy**: Mock repository layer, not actual DB
- **Implementation**: Create mock repository class

### File System

**{File operations}**
- **Mock Type**: Stub with fixtures
- **Implementation**: Use `fs-extra` mock or virtual filesystem
```

### Step 5: Create Implementation Tasks

Generate priority-ordered task list:

```markdown
## Implementation Tasks

### Phase 1: Setup (Priority: Critical)

- [ ] Install test framework dependencies if missing
- [ ] Create test directory structure
- [ ] Set up test configuration (jest.config.js, pytest.ini)
- [ ] Create shared fixtures directory

### Phase 2: High Priority Tests (P1-P2)

- [ ] **Task 1**: Create test file for {critical-component}
  - File: `{test-file-path}`
  - Coverage goal: 90%
  - Test cases: TC-001, TC-002, TC-003
  - Mocks needed: {list}

- [ ] **Task 2**: Implement tests for {another-critical-component}
  ...

### Phase 3: Medium Priority Tests (P3-P4)

- [ ] **Task 5**: Create test file for {component}
  ...

### Phase 4: Edge Cases & Integration

- [ ] **Task 10**: Add edge case tests for boundary conditions
- [ ] **Task 11**: Create integration tests for {workflow}

### Phase 5: Validation

- [ ] Run full test suite
- [ ] Verify coverage meets goals (80%+)
- [ ] Review test quality with `/ut.review`
```

### Step 6: Define Execution Order

```markdown
## Execution Order

### Dependencies

1. **Setup tasks must complete first**
2. **High priority tests** can run in parallel (no dependencies)
3. **Integration tests** depend on unit tests
4. **Edge case tests** depend on happy path tests

### Parallel Opportunities

Can implement simultaneously:
- Test file A + Test file B (different source files)
- Unit tests + Mocking infrastructure
- Documentation + Test implementation

Must implement sequentially:
- Setup → Test implementation
- Mocks → Tests using those mocks
- Unit tests → Integration tests
```

### Step 7: Add Test Data Requirements

```markdown
## Test Data & Fixtures

### Shared Fixtures

Create `fixtures/` directory with:

**users.json**:
```json
{
  "validUser": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "invalidUser": {
    "id": -1,
    "name": "",
    "email": "invalid-email"
  }
}
```

**database-seed.ts**: Mock database data

### Test Helpers

Create `helpers/` directory with:

**test-utils.ts**: Shared test utilities
**mock-factories.ts**: Mock data generators
```

### Step 8: Format Complete Test Plan

Generate Markdown document:

```markdown
# Test Implementation Plan: {Feature Name}

**Feature**: {feature-id}
**Created**: {date}
**Based On**:
- Test Spec: `.specify/features/{feature-id}/test-spec.md`
- Coverage Report: `.specify/features/{feature-id}/coverage-report.json`

**Status**: Draft

## Test Organization Decision

**Pattern**: {chosen-pattern}
**Structure**: {file-structure}
**Detected from**: {existing-tests | framework-convention | user-preference}
**Confidence**: {high | medium | low}

### Rationale
{why-this-pattern-was-chosen}

### Directory Structure
{detailed structure diagram}

## Test Structure

**Root Directory**: `{tests/ or src/__tests__/}`
**Organization**: {by_feature | by_type | by_module}
**Naming Convention**: `{pattern}`

**Framework**: {Jest 29.7.0 | Pytest 7.4.0 | etc.}
**Config File**: `{jest.config.js | pytest.ini}`

## Test Suites

{Generated test suite definitions}

## Mocking Strategy

{Generated mocking plans}

## Test Data & Fixtures

{Generated fixture specifications}

## Implementation Tasks

{Generated task list with priorities}

## Execution Order

{Dependencies and sequencing}

## Coverage Goals

- **Target**: 80% overall coverage
- **Critical paths**: 90%+ coverage
- **Edge cases**: All scenarios covered

## Success Criteria

- [ ] All test files created
- [ ] All test cases implemented
- [ ] Coverage goals met
- [ ] Tests pass consistently
- [ ] Mocks properly isolate dependencies

## Notes

{Additional considerations, risks, assumptions}
```

### Step 9: Handle Edge Cases

**Missing test-spec.md**:
- Cannot generate plan without test scenarios
- Prompt: "Run `/ut.specify {feature-id}` to create test specification first"

**Missing coverage-report.json**:
- Can generate basic plan from test-spec alone
- Warn: "Coverage report missing. Framework detection and priority recommendations unavailable."
- Suggest: "Run `/ut.analyze {feature-id}` for better planning"

**No framework detected**:
- Provide framework recommendations based on language
- Include setup instructions for recommended framework

### Step 10: Write Output

1. Create `.specify/features/{feature-id}/test-plan.md`
2. Display summary:

```
✅ Test Implementation Plan Created
====================================

Test Structure: __tests__/ directory
Framework: Jest 29.7.0
Test Suites: 8 files
Total Tasks: 25

Priority Breakdown:
  Critical (Setup): 4 tasks
  High (P1-P2): 10 tasks
  Medium (P3-P4): 8 tasks
  Low (Edge cases): 3 tasks

Estimated Effort: 15-20 hours

Next step: Run /ut.generate {feature-id} to create test files
```

## Quality Checklist

- [ ] All test scenarios from test-spec.md included
- [ ] High-priority gaps from coverage report addressed
- [ ] Mocking strategy defined for all external dependencies
- [ ] Test file paths follow framework conventions
- [ ] Tasks are priority-ordered and actionable
- [ ] Execution order respects dependencies
- [ ] Fixture/test data requirements specified
- [ ] Coverage goals realistic and measurable

## Example Usage

```bash
# Generate test implementation plan
/ut.plan aa-2

# Output:
# Loading test specification... ✓
# Loading coverage report... ✓
# Detected framework: Jest 29.7.0
# Analyzing test scenarios... 12 scenarios
# Planning test structure... __tests__/ directory
# Generating implementation tasks... 25 tasks
#
# ✅ Test plan created: .specify/features/aa-2/test-plan.md
#
# Next step: Run /ut.generate aa-2 to create test files
```

## Error Handling

- **Missing inputs**: Clear guidance on which command to run first
- **Framework conflict**: If spec suggests different framework than detected, ask user which to use
- **No source files**: Cannot plan tests without code to test
- **Invalid paths**: Report specific path issues

## Notes

- This is a **prompt-based workflow** - AI agent handles planning logic
- Generated plan is **human-reviewable** - developer can modify before generation
- Plan focuses on **actionable tasks** - each task can be executed independently
- Execution order allows **parallel implementation** where possible
