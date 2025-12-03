# /ut:plan - Create Unit Test Plan

## Purpose

Generate comprehensive test plan including test specification, coverage analysis, and implementation tasks. **Consolidates** the functionality of specify, analyze, and clarify into ONE command.

---

## Usage

```bash
/ut:plan {feature-id}           # Create new plan
/ut:plan {feature-id} --review  # Review and update existing plan
/ut:plan {feature-id} --force   # Overwrite without asking
```

---

## Output

Creates in `.specify/features/{feature-id}/`:

1. **test-spec.md** - Test scenarios and cases
2. **coverage-analysis.md** - Untested code and gaps
3. **test-plan.md** - Implementation tasks and structure

---

## Execution

### Step 0: Run Bash Script

```bash
bash .specify/scripts/bash/ut/plan.sh <feature-id>
```

Parse JSON output -> Store `FEATURE_DIR`, `SPEC_FILE`, `MODE`

If error -> STOP and report to user

---

### Step 1: Load UT Rules (If Available)

**Check**: `docs/rules/test/ut-rule.md`

- **Found** -> Read and apply rules (naming, coverage, mocking)
- **Not Found** -> Ask: "Run `/ut:create-rules` first?" or continue with defaults

---

### Step 2: Detect Framework (AI)

**Scan config files using Read tool**:

| File | Framework |
|------|-----------|
| `package.json` -> devDependencies | vitest, jest, mocha, jasmine |
| `pyproject.toml` / `requirements.txt` | pytest, unittest |
| `Gemfile` | rspec, minitest |
| `pom.xml` / `build.gradle` | junit, testng |
| `composer.json` | phpunit, pest |
| `*.csproj` | xunit, nunit, mstest |
| `go.mod` | go test, testify |

**Confirm with user** via AskUserQuestion if unsure.

---

### Step 3: Analyze Feature Spec

**Read**: `.specify/features/{feature-id}/spec.md`

**Extract**:
- Functional requirements (FR-*) -> Test scenarios
- User stories -> Test cases
- Edge cases -> Boundary tests
- Success criteria -> Coverage goals

---

### Step 4: Scan Codebase for Testable Units (AI)

**Use Glob tool to find source files**:
```
src/**/*.{ts,js,tsx,jsx}
lib/**/*.py
app/**/*.rb
**/*.go
```

**For each file, identify**:
- Functions (exported/public)
- Classes and methods
- Complexity level (simple/medium/complex)

**Use Grep to find existing tests**:
```
**/*.test.{ts,js}
**/*.spec.{ts,js}
**/test_*.py
**/*_test.go
```

**Calculate**:
- Total testable units
- Units with tests
- Units without tests (gaps)
- Priority (high for public APIs)

---

### Step 5: Determine Test Organization (AI)

**Scan existing tests** for patterns:
- File naming: `*.test.ts` or `*.spec.ts`
- Location: co-located, `__tests__/`, `tests/`
- Style: describe/it, test(), pytest

**Decision logic**:
- **>70% pattern found** -> Use automatically
- **Mixed patterns** -> Ask user preference
- **No tests found** -> Recommend framework convention

**Ask user** via AskUserQuestion if needed:
- Test file location
- Naming convention
- Test style preference

---

### Step 6: Generate Test Specification

**Create** `.specify/features/{feature-id}/test-spec.md`:

```markdown
# Test Specification: {Feature Name}

**Feature**: {feature-id}
**Created**: {date}
**Framework**: {detected-framework}

## Test Scenarios

### TS-001: {Scenario from FR-001}

**Maps to**: FR-001
**Priority**: P1

#### Test Cases

##### TC-001: {Happy path}
- **Given**: {setup}
- **When**: {action}
- **Then**: {expected}

##### TC-002: {Error case}
...

## Coverage Goals

- Target: {from ut-rule.md or 80%}
- Critical paths: {list}
- Edge cases: {list}

## Mocking Requirements

- External APIs: {strategy}
- Database: {strategy}
- File system: {strategy}
```

---

### Step 7: Generate Coverage Analysis

**Create** `.specify/features/{feature-id}/coverage-analysis.md`:

```markdown
# Coverage Analysis: {Feature Name}

**Analyzed**: {date}
**Framework**: {name} {version}

## Summary

| Metric | Value |
|--------|-------|
| Total Files | {n} |
| Total Units | {n} |
| Tested | {n} ({%}) |
| Untested | {n} ({%}) |

## High Priority Gaps

1. **{function}** - `{file}:{line}`
   - Type: {function/class/method}
   - Reason: Public API, no tests

2. ...

## Existing Test Patterns

- Naming: {*.test.ts}
- Location: {__tests__/}
- Mocking: {vi.mock}
```

---

### Step 8: Generate Test Plan

**Create** `.specify/features/{feature-id}/test-plan.md`:

```markdown
# Test Implementation Plan: {Feature Name}

**Feature**: {feature-id}
**Created**: {date}

## Test Organization

**Pattern**: {co-located | __tests__/ | tests/}
**File naming**: {*.test.ts | *.spec.ts}
**Source**: {existing-tests | framework-convention | user-preference}

## Test Suites

### Suite 1: {Component}

**File**: `{path/component.test.ts}`
**Tests**: TC-001, TC-002, TC-003

### Suite 2: ...

## Mocking Strategy

### External Services
- **{Service}**: vi.mock() / jest.mock()

### Database
- Strategy: {in-memory | mock repository}

## Implementation Tasks

### Phase 1: Setup
- [ ] Create test directory structure
- [ ] Set up test configuration

### Phase 2: High Priority (P1-P2)
- [ ] Create tests for {critical-component}
- [ ] Create tests for {another-critical}

### Phase 3: Medium Priority (P3-P4)
- [ ] Create tests for {component}

### Phase 4: Validation
- [ ] Run full test suite
- [ ] Verify coverage goals

## Next Step

Run `/ut:generate {feature-id}` to create test files
```

---

### Step 9: Output Summary

```
Test Plan Created
===================

Framework: {name} {version}
Test Scenarios: {n} scenarios, {n} test cases
Coverage Gaps: {n} untested units ({n} high priority)

Files created:
  - .specify/features/{id}/test-spec.md
  - .specify/features/{id}/coverage-analysis.md
  - .specify/features/{id}/test-plan.md

Implementation Tasks: {n} total
  - Setup: {n}
  - High Priority: {n}
  - Medium Priority: {n}

Next: /ut:generate {feature-id}
```

---

## Review Mode (`--review`)

When plan already exists and needs correction:

### Step R1: Load Existing Artifacts

**Read** all existing files:
- `test-spec.md` - Current test scenarios
- `coverage-analysis.md` - Current coverage gaps
- `test-plan.md` - Current implementation plan

### Step R2: Ask What to Review

**Use AskUserQuestion**:
- Test scenarios incorrect?
- Coverage gaps missing?
- Test organization wrong?
- Mocking strategy needs change?

### Step R3: Targeted Updates

Based on user feedback:
1. **Re-analyze** only the problematic section
2. **Preserve** correct parts
3. **Update** only what's wrong

### Step R4: Diff Preview

Show changes before saving:
```diff
- Old: Test file in __tests__/
+ New: Test file co-located with source
```

Confirm → Update files

---

## Scope Modification

If user needs to modify scope after initial plan:

**Add file**: Update test-spec.md with new scenarios
**Remove file**: Mark scenarios as "excluded"
**Reset**: Regenerate from spec.md

Use AskUserQuestion to handle scope changes interactively.

---

## Error Handling

| Error | Solution |
|-------|----------|
| spec.md not found | Run `/speckit.specify {feature-id}` first |
| No source files | Ask user for source directory |
| No framework detected | Ask user to select framework |

---

## Supported Frameworks

| Language | Frameworks |
|----------|------------|
| JavaScript/TypeScript | Vitest, Jest, Mocha, Jasmine |
| Python | Pytest, unittest |
| Ruby | RSpec, Minitest |
| Java | JUnit, TestNG |
| PHP | PHPUnit, Pest |
| .NET | xUnit, NUnit, MSTest |
| Go | testing, testify |

---

## Related

- `ut:create-rules` - One-time project setup
- `ut:generate` - Generate test files from plan
- `ut:auto` - Automated test workflow
