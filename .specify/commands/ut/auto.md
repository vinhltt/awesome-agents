# /ut:auto - Automated Unit Test Workflow

## Purpose

Run the complete UT workflow automatically: plan -> generate -> run tests. Single command for end-to-end test creation.

---

## Workflow

```
ut:auto
   |
   v
[Check UT Rules] --> [Create if missing]
   |
   v
[Plan] --> test-spec.md, coverage-analysis.md, test-plan.md
   |
   v
[Generate] --> *.test.ts, *.spec.ts, etc.
   |
   v
[Run Tests] --> Report results
```

---

## Output

Creates all artifacts:
- `test-spec.md` - Test scenarios
- `coverage-analysis.md` - Untested code analysis
- `test-plan.md` - Implementation plan
- Test files in project directory

---

## Execution

### Step 0: Run Bash Script

```bash
bash .specify/scripts/bash/ut/auto.sh <feature-id>
```

Parse JSON output -> Store paths and flags

If error -> STOP and report to user

---

### Step 1: Check UT Rules

**Check**: `docs/rules/test/ut-rule.md`

- **Found** -> Continue
- **Not Found** -> Ask user:
  - "UT rules not found. Create now?" (Y/N)
  - If Y: Run `/ut:create-rules` workflow first
  - If N: Continue with framework defaults

---

### Step 2: Execute Plan Phase

Run `/ut:plan` workflow internally:

1. Detect framework (AI)
2. Analyze feature spec
3. Scan codebase for testable units
4. Determine test organization
5. Generate test-spec.md
6. Generate coverage-analysis.md
7. Generate test-plan.md

**On error** -> STOP, report to user

---

### Step 3: Execute Generate Phase

Run `/ut:generate` workflow internally:

1. Load plan and spec
2. Determine test file paths
3. Read source files
4. Generate test structure
5. Implement test cases
6. Implement mocks
7. Create fixtures
8. Write test files

**On error** -> STOP, report to user (plan artifacts preserved)

---

### Step 4: Run Tests

**Detect test command**:

| Framework | Command |
|-----------|---------|
| Vitest | `pnpm test` / `npm test` |
| Jest | `npm test` / `npx jest` |
| Pytest | `pytest` / `python -m pytest` |
| RSpec | `rspec` / `bundle exec rspec` |
| JUnit | `mvn test` / `gradle test` |
| xUnit | `dotnet test` |
| Go | `go test ./...` |

**Run tests** and capture output.

---

### Step 5: Output Summary

```
UT Auto Complete
=================

Feature: {feature-id}
Framework: {Vitest 3.2.4}

Artifacts Created:
  - test-spec.md (12 scenarios, 45 test cases)
  - coverage-analysis.md (8 gaps identified)
  - test-plan.md (15 implementation tasks)

Test Files Generated:
  - utils/__tests__/validator.test.ts (8 tests)
  - composables/__tests__/useCalc.test.ts (5 tests)

Test Results:
  - Total: 13 tests
  - Passed: 12
  - Failed: 1
  - Coverage: 78%

Failed Tests:
  - validator.test.ts:45 "should reject empty string"
    Expected: throw Error
    Received: undefined

Next Steps:
  1. Fix failing test in validator.test.ts:45
  2. Run `npm test` to verify
```

---

## Options

| Flag | Description |
|------|-------------|
| `--skip-run` | Plan + Generate only, skip test execution |
| `--plan-only` | Only run plan phase |
| `--force` | Overwrite existing artifacts |

---

## Error Handling

| Phase | Error | Action |
|-------|-------|--------|
| Plan | spec.md missing | STOP - Run /speckit.specify first |
| Generate | test-plan.md missing | STOP - Plan phase failed |
| Run | Tests fail | Report failures, continue |
| Run | Command not found | Suggest installing test framework |

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
- `ut:plan` - Create test plan only
- `ut:generate` - Generate test files only
