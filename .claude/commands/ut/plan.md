# /ut.plan - Generate Test Implementation Plan

## Purpose

Create a structured test implementation plan that defines test file organization, suite structure, mocking strategy, and step-by-step implementation tasks based on test specification and coverage analysis.

## Input

- **Feature ID**: Required argument (e.g., `aa-2`)
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
- If existing tests found → Use same pattern
- If no tests → Recommend framework convention:
  - Jest/Vitest: `__tests__/` directory
  - Pytest: `tests/unit/` directory

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
