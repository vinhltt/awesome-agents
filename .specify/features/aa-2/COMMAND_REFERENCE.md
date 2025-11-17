# UT Workflow Command Reference

Quick reference guide for the Unit Test Generation Command Flow.

---

## 🎯 Command Overview

| Command | Purpose | Input | Output |
|---------|---------|-------|--------|
| `/ut.specify` | Create test specification | spec.md | test-spec.md |
| `/ut.analyze` | Analyze code for test gaps | Source code | coverage-report.json |
| `/ut.plan` | Generate test implementation plan | test-spec.md + coverage-report.json | test-plan.md |
| `/ut.generate` | Generate test code | test-plan.md | Test files (*.test.*, test_*.py) |
| `/ut.review` | Review test quality | Test files | review-report.md |
| `/ut.run` | Execute tests and analyze | Test files | test-results.md |
| `/speckit.status` | Check workflow progress | Feature artifacts | Terminal output |

---

## 📋 Command Details

### `/ut.specify <feature-id>`

**Purpose**: Create test specification from feature spec

**Prerequisites**:
- Feature spec must exist: `.specify/features/<feature-id>/spec.md`

**What It Does**:
1. Reads feature specification
2. Extracts functional requirements
3. Generates test scenarios (Given/When/Then format)
4. Identifies coverage goals
5. Plans initial mocking strategy

**Output**: `.specify/features/<feature-id>/test-spec.md`

**Example**:
```bash
/ut.specify aa-2
```

**Output Structure**:
```markdown
# Test Specification

## Test Scenarios
### TS-001: User Authentication
- Scenario description
- Coverage requirements
- Mocking needs

#### Test Cases
##### TC-001: Valid login
- Given: Valid credentials
- When: User submits login form
- Then: User is authenticated
```

---

### `/ut.analyze <feature-id> [--path <code-path>]`

**Purpose**: Analyze codebase for test gaps and framework detection

**Prerequisites**:
- Source code exists in project

**Options**:
- `--path <path>`: Specify custom code location (default: auto-detect src/, lib/, app/)

**What It Does**:
1. Detects programming language
2. Identifies test framework (Jest/Vitest/Pytest)
3. Locates source files and testable units
4. Finds existing tests
5. Calculates coverage gaps
6. Prioritizes untested code

**Output**: `.specify/features/<feature-id>/coverage-report.json`

**Example**:
```bash
/ut.analyze aa-2
/ut.analyze aa-2 --path src/components
```

**Output Structure** (JSON):
```json
{
  "environment": {
    "framework": { "name": "Jest", "version": "29.7.0" }
  },
  "analysis": {
    "filesAnalyzed": 12,
    "testableUnits": 45,
    "existingTests": 10,
    "untested": 35
  },
  "gaps": [
    { "file": "calculator.ts", "priority": "high", "reason": "Core logic" }
  ]
}
```

---

### `/ut.plan <feature-id>`

**Purpose**: Generate test implementation plan

**Prerequisites**:
- `test-spec.md` exists (from `/ut.specify`)
- `coverage-report.json` exists (from `/ut.analyze`)

**What It Does**:
1. Reads test spec and coverage report
2. Determines test file structure
3. Defines test suite organization
4. Plans mocking strategy for dependencies
5. Generates priority-ordered implementation tasks

**Output**: `.specify/features/<feature-id>/test-plan.md`

**Example**:
```bash
/ut.plan aa-2
```

**Output Structure**:
```markdown
# Test Implementation Plan

## Test File Structure
- tests/unit/calculator.test.ts
- tests/unit/cart.test.ts
- tests/integration/checkout.test.ts

## Test Suites
### Suite 1: Calculator Tests
- Location: tests/unit/calculator.test.ts
- Test cases: TC-001 to TC-005
- Setup: beforeEach creates instance
- Mocking: None required

## Mocking Strategy
- Payment API: Full mock with jest.mock()
- Database: Repository pattern mock
```

---

### `/ut.generate <feature-id> [--dry-run]`

**Purpose**: Generate executable test code

**Prerequisites**:
- `test-plan.md` exists (from `/ut.plan`)
- `test-spec.md` exists (from `/ut.specify`)
- `coverage-report.json` exists (from `/ut.analyze`)

**Options**:
- `--dry-run`: Preview generation without writing files

**What It Does**:
1. Reads test plan and spec
2. Analyzes source code to test
3. Generates test files with proper framework syntax
4. Implements setup/teardown code
5. Creates test cases with assertions
6. Implements mock implementations
7. Adds test data and fixtures

**Output**: Test files in project directory
- Jest/Vitest: `*.test.{js,ts,jsx,tsx}` or `*.spec.*`
- Pytest: `test_*.py` or `*_test.py`

**Example**:
```bash
/ut.generate aa-2
/ut.generate aa-2 --dry-run
```

**Generated File Example** (Jest):
```typescript
import { Calculator } from '../src/calculator';

describe('Calculator', () => {
  let calculator: Calculator;

  beforeEach(() => {
    calculator = new Calculator();
  });

  it('should add two numbers correctly', () => {
    const result = calculator.add(2, 3);
    expect(result).toBe(5);
  });
});
```

---

### `/ut.review <feature-id>`

**Purpose**: Review test quality and provide feedback

**Prerequisites**:
- Test files exist (from `/ut.generate` or manual creation)
- Optional: `test-spec.md` for completeness comparison

**What It Does**:
1. Locates all test files
2. Compares against test-spec.md (if exists)
3. Evaluates assertion quality
4. Checks best practices compliance
5. Verifies mocking strategy
6. Assesses maintainability
7. Calculates weighted quality score

**Output**: `.specify/features/<feature-id>/review-report.md`

**Quality Dimensions**:
- **Completeness** (30%): All test cases covered
- **Assertion Quality** (25%): Specific assertions
- **Best Practices** (20%): Framework conventions
- **Mocking** (15%): Dependency isolation
- **Maintainability** (10%): Code organization

**Example**:
```bash
/ut.review aa-2
```

**Output Structure**:
```markdown
# Test Review Report

Overall Quality Score: 84% ⭐⭐⭐⭐

## Issues Found
### Critical (2)
1. Missing test case TC-015
2. No mock cleanup in api.test.ts

### Medium (5)
1. Weak assertion: expect(result).toBeDefined()
   Better: expect(result).toBe(8)

## Recommendations
- Fix critical issues first
- Replace weak assertions
- Add mock cleanup
```

---

### `/ut.run <feature-id> [--no-coverage]`

**Purpose**: Execute tests and analyze results

**Prerequisites**:
- Test files exist (from `/ut.generate` or manual creation)
- Test framework installed (npm/pip dependencies)

**Options**:
- `--no-coverage`: Skip coverage collection (faster)

**What It Does**:
1. Detects test framework
2. Executes test command (npm test, pytest, etc.)
3. Captures output (stdout, stderr, exit code)
4. Parses test results (pass/fail, duration)
5. Extracts coverage metrics
6. Analyzes each failure with root cause
7. Suggests specific fixes with code examples

**Output**: `.specify/features/<feature-id>/test-results.md`

**Example**:
```bash
/ut.run aa-2
/ut.run aa-2 --no-coverage
```

**Output Structure**:
```markdown
# Test Execution Results

Summary:
  ✅ Passed: 17/19 (89%)
  ❌ Failed: 2/19 (11%)
  📈 Coverage: 87%

## Failed Tests

### 1. should handle division by zero
Location: calculator.test.ts:25

Root Cause: Missing input validation

How to Fix:
```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Cannot divide by zero');
  }
  return a / b;
}
```

Priority: 🔴 High

## Coverage Report
Overall: 87% (Target: 80% ✅)

## Next Steps
1. Fix 2 failing tests (estimated 7 minutes)
2. Re-run tests
```

---

### `/speckit.status [feature-id]`

**Purpose**: Check workflow progress for any feature

**Prerequisites**: None

**Usage**:
```bash
/speckit.status aa-2    # Check specific feature
/speckit.status         # List all features
```

**What It Does**:
1. Detects active workflows (SpecKit + UT)
2. Analyzes artifact status and timestamps
3. Calculates progress percentages
4. Determines current workflow state
5. Suggests specific next commands

**Output**: Terminal display (no file)

**Example Output**:
```
╔══════════════════════════════════════════════════════╗
║  SpecKit Status: Feature aa-2                        ║
╚══════════════════════════════════════════════════════╝

📋 SpecKit Default Workflow
  Tasks: 31/49 (63%) [███████████████░░░░░░░░]

🧪 UT Workflow
  Pipeline: 4/6 steps (67%) [████████████████░░░░░░]

  1. ✅ Test Specification (1 day ago)
  2. ✅ Code Analysis (1 day ago)
  3. ✅ Implementation Plan (1 day ago)
  4. ✅ Test Generation (1 hour ago)
  5. ⏸️ Test Review - Next: /ut.review aa-2
  6. ⏸️ Test Execution - Next: /ut.run aa-2

🎯 Next Actions:
  → /ut.review aa-2
  → /ut.run aa-2
```

---

## 🔄 Common Workflows

### Workflow 1: Complete UT Pipeline

```bash
/ut.specify aa-2      # Create test spec
/ut.analyze aa-2      # Analyze code
/ut.plan aa-2         # Plan implementation
/ut.generate aa-2     # Generate tests
/ut.review aa-2       # Review quality
/ut.run aa-2          # Execute tests

# Check status anytime
/speckit.status aa-2
```

### Workflow 2: TDD Approach

```bash
# 1. Define tests first
/ut.specify aa-2
/ut.analyze aa-2
/ut.plan aa-2
/ut.generate aa-2

# 2. Implement feature (manual)
# ...

# 3. Run tests
/ut.run aa-2
```

### Workflow 3: Post-Implementation Testing

```bash
# Code already exists
/ut.analyze aa-2      # Find what needs tests
/ut.plan aa-2         # Plan test structure
/ut.generate aa-2     # Generate tests
/ut.run aa-2          # Execute
```

### Workflow 4: Incremental Testing

```bash
# Phase 1: Specify and analyze
/ut.specify aa-2
/ut.analyze aa-2
/speckit.status aa-2

# Phase 2: Generate some tests
/ut.plan aa-2
/ut.generate aa-2

# Phase 3: Review and fix
/ut.review aa-2
# (Fix issues manually)

# Phase 4: Execute
/ut.run aa-2
```

---

## 🎯 Best Practices

### 1. Always Start with Specification
```bash
# Good
/ut.specify aa-2      # Define what to test
/ut.analyze aa-2      # Then analyze code

# Not recommended
/ut.generate aa-2     # Will fail - missing inputs
```

### 2. Check Status Regularly
```bash
# After each command
/speckit.status aa-2
```

### 3. Review Before Running
```bash
/ut.generate aa-2     # Generate tests
/ut.review aa-2       # Check quality first
# Fix any issues
/ut.run aa-2          # Then execute
```

### 4. Use Dry Run for Preview
```bash
/ut.generate aa-2 --dry-run    # Preview generation
# Review plan
/ut.generate aa-2              # Actually generate
```

### 5. Iterate Based on Results
```bash
/ut.run aa-2          # Run tests
# Fix failures (see test-results.md)
/ut.run aa-2          # Re-run
/ut.review aa-2       # Review if quality improves
```

---

## 📂 File Locations

### Input Files (You Create)
- `.specify/features/<feature-id>/spec.md` - Feature specification

### Generated Workflow Artifacts
- `.specify/features/<feature-id>/test-spec.md` - Test specification
- `.specify/features/<feature-id>/coverage-report.json` - Coverage analysis
- `.specify/features/<feature-id>/test-plan.md` - Implementation plan
- `.specify/features/<feature-id>/review-report.md` - Quality review
- `.specify/features/<feature-id>/test-results.md` - Execution results

### Generated Test Files
- **Jest/Vitest**: `tests/**/*.test.{js,ts}` or `**/__tests__/*.{js,ts}`
- **Pytest**: `tests/**/test_*.py`

---

## 🆘 Troubleshooting

### "Feature not found"
```bash
# Check if feature directory exists
ls .specify/features/aa-2

# If not, create specification first
/speckit.specify aa-2
```

### "Missing required inputs"
```bash
# Each command shows which prerequisites are missing
# Run suggested commands first

# Example:
/ut.plan aa-2
# Output: Missing test-spec.md
#         Run: /ut.specify aa-2

/ut.specify aa-2      # Fix the issue
/ut.plan aa-2         # Try again
```

### "No test files found"
```bash
# Generate tests first
/ut.generate aa-2

# Or check if tests are in unexpected location
/ut.analyze aa-2 --path custom/path
```

### "Framework not detected"
```bash
# Check package.json or requirements.txt exists
ls package.json
ls requirements.txt

# Manually analyze specific path
/ut.analyze aa-2 --path src
```

---

## 💡 Tips

1. **Use `/speckit.status` frequently** - It shows exactly what to do next
2. **Don't skip `/ut.review`** - Catches quality issues early
3. **Fix failures incrementally** - Run `/ut.run` after each fix
4. **Use `--dry-run`** - Preview before generating files
5. **Check command prompts** - Each `.claude/commands/ut/*.md` has detailed examples
6. **Read artifact files** - They contain valuable context and guidance

---

## 📚 Further Reading

- **Implementation Summary**: `.specify/features/aa-2/IMPLEMENTATION_SUMMARY.md`
- **Feature Spec**: `.specify/features/aa-2/spec.md`
- **Implementation Plan**: `.specify/features/aa-2/plan.md`
- **Task Breakdown**: `.specify/features/aa-2/tasks.md`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-14
