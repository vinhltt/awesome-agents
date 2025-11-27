# /ut.run - Execute Tests and Analyze Results

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

Execute generated unit tests and provide detailed analysis of results including pass/fail status, coverage metrics, and actionable suggestions for fixing failures.

## Input

- **Feature ID**: **REQUIRED** argument (e.g., `pref-2`, `AL-991`, `test/pref-123`)
  - Format: `[folder/]prefix-number`
  - Prefix configured in `.specify/.speckit.env`
  - If missing: ERROR "Task ID required. Usage: /ut:run {task-id}"
- **Test Files**: Automatically located based on framework
- **Coverage Report**: Reads `.specify/features/{feature-id}/coverage-report.json` for framework info
- **Test Plan**: Optionally reads `.specify/features/{feature-id}/test-plan.md` for context

## Output

Creates `.specify/features/{feature-id}/test-results.md` with:

1. **Execution Summary**: Pass/fail counts, duration, coverage percentage
2. **Test Results**: Detailed pass/fail status per test suite
3. **Failure Analysis**: Root cause analysis for each failure
4. **Coverage Report**: Line/branch/function coverage metrics
5. **Recommendations**: Specific suggestions to fix failures
6. **Next Steps**: Actionable items for the developer

## Execution Instructions

### Step 0: Validate or Infer Task ID

**CRITICAL**: Handle task_id before any operations.

1. **Parse user input**:
   - Extract first argument from `$ARGUMENTS`
   - Expected format: `[folder/]prefix-number` (e.g., `pref-991`, `AL-991`, `test/pref-123`)

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

   Usage: /ut.run <task-id>
   Example: /ut.run pref-001

   No previous task context found in this conversation.
   ```
   STOP - Do NOT proceed to Step 1

4. **Validate task_id format**:
   - Must match pattern: `[folder/]prefix-number`
   - Prefix must be in `.specify/.speckit.env` SPECKIT_PREFIX_LIST
   - Examples:
     - ✅ `/ut.run pref-991` → task_id: `pref-991`
     - ✅ `/ut.run PREF-991` → task_id: `pref-991` (case-insensitive)
     - ❌ `/ut.run` without context → ERROR (no task ID)

5. **Determine feature directory**:
   - Pattern: `.specify/{folder}/{prefix-number}/`
   - Default folder: `features` (from SPECKIT_DEFAULT_FOLDER)
   - If not found → ERROR, suggest running `/ut.specify` first

**After Validation**:
- Proceed to Step 1 only if task_id valid
- Use task_id to locate feature files

### Step 1: Detect Test Framework

From coverage-report.json:

```json
{
  "environment": {
    "framework": {
      "name": "Jest",
      "version": "29.7.0"
    }
  }
}
```

**Supported Frameworks**:
- **Jest**: `npm test` or `npx jest`
- **Vitest**: `npm test` or `npx vitest run`
- **Pytest**: `pytest` or `python -m pytest`

### Step 2: Locate Test Files

Search for test files in common patterns:

**Jest/Vitest**:
- `**/*.test.{js,ts,jsx,tsx}`
- `**/*.spec.{js,ts,jsx,tsx}`
- `**/__tests__/**/*.{js,ts,jsx,tsx}`

**Pytest**:
- `**/test_*.py`
- `**/*_test.py`
- `tests/**/*.py`

### Step 3: Prepare Test Environment

**Check Dependencies**:

```bash
# For Jest/Vitest
- Check package.json for test script
- Verify node_modules exists
- Check for jest.config.js or vitest.config.ts

# For Pytest
- Check for pytest in requirements.txt
- Verify pytest is installed: pytest --version
- Check for pytest.ini or pyproject.toml
```

**Environment Setup**:
- Set NODE_ENV=test for Jest/Vitest
- Ensure clean state (no cached modules)
- Check for required environment variables

### Step 4: Execute Tests

**Jest/Vitest Execution**:

```bash
# Run with coverage
npm test -- --coverage --verbose

# Or direct execution
npx jest --coverage --verbose --json --outputFile=test-results.json

# Vitest
npx vitest run --coverage --reporter=verbose --reporter=json --outputFile=test-results.json
```

**Pytest Execution**:

```bash
# Run with coverage
pytest --cov --cov-report=term --cov-report=json --verbose --tb=short

# Or with more details
python -m pytest --cov --cov-report=json --verbose -v --tb=line
```

**Capture**:
- Standard output (test names, status)
- Standard error (failures, errors)
- Exit code (0 = all passed, non-zero = failures)
- Execution time
- Coverage data

### Step 5: Parse Test Results

**Jest/Vitest Output Format**:

```json
{
  "numTotalTests": 19,
  "numPassedTests": 17,
  "numFailedTests": 2,
  "numPendingTests": 0,
  "testResults": [
    {
      "name": "calculator.test.ts",
      "status": "passed",
      "duration": 45,
      "assertionResults": [
        {
          "title": "should add two numbers",
          "status": "passed",
          "duration": 5
        },
        {
          "title": "should handle division by zero",
          "status": "failed",
          "failureMessages": ["Expected error to be thrown"],
          "location": { "line": 25, "column": 5 }
        }
      ]
    }
  ]
}
```

**Pytest Output Format**:

```
tests/test_calculator.py::test_add PASSED                           [ 11%]
tests/test_calculator.py::test_divide_by_zero FAILED                [ 22%]

================================= FAILURES =================================
_________________________ test_divide_by_zero __________________________
    def test_divide_by_zero():
>       assert calculator.divide(10, 0) raises ZeroDivisionError
E       AssertionError: Expected ZeroDivisionError

tests/test_calculator.py:25: AssertionError
=========================== short test summary ============================
FAILED tests/test_calculator.py::test_divide_by_zero - AssertionError
========================= 2 passed, 1 failed in 0.50s ======================
```

### Step 6: Analyze Failures

For each failed test:

**Extract**:
1. **Test name** and file location
2. **Failure message** (what went wrong)
3. **Expected vs Actual** values
4. **Stack trace** (where it failed)
5. **Code context** (lines around failure)

**Categorize Failure Type**:
- **Assertion Failure**: Expected value doesn't match actual
- **Error Thrown**: Unexpected exception
- **Timeout**: Test exceeded time limit
- **Missing Mock**: Dependency not properly mocked
- **Setup Issue**: beforeEach/fixture problem

**Example Analysis**:

```markdown
### ❌ FAILURE: test_divide_by_zero

**Location**: `tests/test_calculator.py:25`

**Failure Type**: Assertion Failure

**What Happened**:
The test expected a `ZeroDivisionError` to be raised when dividing by zero, but no error was thrown.

**Expected**:
```python
with pytest.raises(ZeroDivisionError):
    calculator.divide(10, 0)
```

**Actual**:
Function returned `None` instead of raising error

**Root Cause**:
The `divide()` function in `calculator.py` doesn't validate the denominator. It silently returns `None` for division by zero instead of raising an error.

**Fix**:
Update `calculator.py:15-17`:

```python
def divide(a, b):
    if b == 0:
        raise ZeroDivisionError("Cannot divide by zero")
    return a / b
```

**Priority**: High (error handling is critical)
```

### Step 7: Parse Coverage Data

**Jest Coverage Report**:

```json
{
  "total": {
    "lines": { "total": 150, "covered": 120, "pct": 80 },
    "statements": { "total": 160, "covered": 128, "pct": 80 },
    "functions": { "total": 25, "covered": 22, "pct": 88 },
    "branches": { "total": 40, "covered": 30, "pct": 75 }
  },
  "src/calculator.ts": {
    "lines": { "total": 20, "covered": 18, "pct": 90 },
    "uncoveredLines": [15, 16]
  }
}
```

**Pytest Coverage Report**:

```
---------- coverage: platform linux, python 3.10 -----------
Name                    Stmts   Miss  Cover   Missing
-----------------------------------------------------
src/calculator.py          20      2    90%   15-16
src/cart.py                35      5    86%   42-46
-----------------------------------------------------
TOTAL                      55      7    87%
```

**Generate Coverage Summary**:

```markdown
## 📊 Coverage Report

**Overall**: 87% (Target: 80% ✅)

| Module | Lines | Coverage | Status | Missing Lines |
|--------|-------|----------|--------|---------------|
| calculator.py | 20 | 90% | ✅ | 15-16 |
| cart.py | 35 | 86% | ✅ | 42-46 |
| payment.py | 45 | 65% | ⚠️ | 20-25, 38-42 |

**Uncovered Code**:
- `calculator.py:15-16` - Error handling for division by zero
- `cart.py:42-46` - Edge case: empty cart calculation
- `payment.py:20-25` - Timeout handling
- `payment.py:38-42` - Refund logic
```

### Step 8: Generate Test Results Report

Create comprehensive report:

```markdown
# Test Execution Results: {Feature Name}

**Feature**: {feature-id}
**Executed**: {timestamp}
**Framework**: Jest 29.7.0
**Duration**: 2.5 seconds

## 📊 Summary

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests | 19 | - |
| ✅ Passed | 17 | 89% |
| ❌ Failed | 2 | 11% |
| ⏭️ Skipped | 0 | - |
| ⏱️ Duration | 2.5s | - |
| 📈 Coverage | 87% | ✅ (Target: 80%) |

## ✅ Passed Tests (17)

### calculator.test.ts (4/5 passed)
- ✅ should add two numbers correctly
- ✅ should subtract two numbers correctly
- ✅ should multiply two numbers correctly
- ✅ should handle negative numbers
- ❌ should handle division by zero (FAILED)

### cart.test.ts (8/8 passed)
- ✅ should add item to cart
- ✅ should remove item from cart
- ✅ should calculate total correctly
- ✅ should apply discount
- ✅ should handle empty cart
- ✅ should prevent negative quantities
- ✅ should update item quantity
- ✅ should clear cart

### payment.test.ts (5/6 passed)
- ✅ should process payment successfully
- ✅ should handle insufficient funds
- ✅ should validate payment method
- ✅ should generate transaction ID
- ✅ should send confirmation email
- ❌ should handle payment gateway timeout (FAILED)

## ❌ Failed Tests (2)

### 1. FAILURE: should handle division by zero

**File**: `tests/calculator.test.ts:25`
**Suite**: calculator.test.ts
**Type**: Assertion Failure

**Failure Message**:
```
Expected function to throw ZeroDivisionError, but no error was thrown
```

**What Went Wrong**:
The test expected the `divide()` function to raise an error when dividing by zero, but the function returned `undefined` instead.

**Code Context** (calculator.ts:15-17):
```typescript
function divide(a: number, b: number): number {
  return a / b;  // No validation!
}
```

**Root Cause**:
Missing input validation - the function doesn't check if denominator is zero.

**How to Fix**:

Add zero-check before division:

```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Cannot divide by zero');
  }
  return a / b;
}
```

**Priority**: 🔴 High (Critical error handling missing)

---

### 2. FAILURE: should handle payment gateway timeout

**File**: `tests/payment.test.ts:42`
**Suite**: payment.test.ts
**Type**: Timeout Error

**Failure Message**:
```
Timeout - Async callback was not invoked within the 5000ms timeout
```

**What Went Wrong**:
The test waited for the payment gateway mock to respond, but the callback was never invoked, causing the test to timeout.

**Code Context** (payment.test.ts:40-45):
```typescript
it('should handle payment gateway timeout', async () => {
  mockGateway.processPayment.mockImplementation(() => {
    // Mock never resolves or rejects!
  });
  await expect(payment.process()).rejects.toThrow('Timeout');
});
```

**Root Cause**:
The mock implementation doesn't return a Promise. The test expects a rejected Promise but the mock doesn't provide one.

**How to Fix**:

Update mock to reject after delay:

```typescript
it('should handle payment gateway timeout', async () => {
  mockGateway.processPayment.mockImplementation(() => {
    return new Promise((resolve, reject) => {
      setTimeout(() => reject(new Error('Timeout')), 100);
    });
  });
  await expect(payment.process()).rejects.toThrow('Timeout');
});
```

**Priority**: 🟡 Medium (Mock configuration issue, easy fix)

---

## 📈 Coverage Report

**Overall Coverage**: 87% ✅ (Target: 80%)

### By Type
- **Lines**: 87% (120/138)
- **Statements**: 86% (128/149)
- **Functions**: 88% (22/25)
- **Branches**: 75% (30/40)

### By Module

| Module | Lines | Coverage | Status | Uncovered Lines |
|--------|-------|----------|--------|-----------------|
| src/calculator.ts | 20 | 90% | ✅ | 15-16 |
| src/cart.ts | 35 | 95% | ✅ | 42 |
| src/payment.ts | 45 | 78% | ⚠️ | 20-25, 38-42 |
| src/utils.ts | 38 | 92% | ✅ | 28-30 |

### ⚠️ Low Coverage Areas

**payment.ts (78%)**:
- **Lines 20-25**: Timeout handling logic not tested
- **Lines 38-42**: Refund processing not tested
- **Recommendation**: Add tests for timeout and refund scenarios

## 🎯 Recommendations

### Priority 1: Fix Failing Tests (2 items)

1. **Add zero-check to divide() function**
   - File: `src/calculator.ts:15`
   - Action: Add input validation
   - Estimated effort: 2 minutes

2. **Fix payment timeout mock**
   - File: `tests/payment.test.ts:42`
   - Action: Update mock to return rejected Promise
   - Estimated effort: 5 minutes

### Priority 2: Improve Coverage (3 items)

1. **Add timeout test for payment.ts:20-25**
   - Current coverage: 78%
   - Target coverage: 85%
   - Create test case: "should handle gateway timeout after 30s"

2. **Add refund test for payment.ts:38-42**
   - Missing: Refund processing logic
   - Create test case: "should process refund successfully"

3. **Add edge case test for utils.ts:28-30**
   - Missing: Empty array handling
   - Create test case: "should handle empty input array"

### Priority 3: Enhance Test Quality (2 items)

1. **Improve assertion specificity** (from review report)
   - Replace weak assertions like `toBeDefined()` with specific expectations
   - See: review-report.md for details

2. **Add integration tests**
   - Current: Only unit tests
   - Recommended: Add integration test for checkout flow

## 📋 Next Steps

1. ✅ **Fix the 2 failing tests** (Priority 1)
   - Update calculator.ts with zero-check
   - Fix payment timeout mock

2. 🔍 **Re-run tests** after fixes
   ```bash
   npm test
   ```

3. 📊 **Verify coverage** improved
   ```bash
   npm test -- --coverage
   ```

4. 🚀 **Review and commit**
   - Review changes
   - Run full test suite
   - Commit with message: "fix: Add zero-check validation and fix timeout mock"

## 🔧 Commands

**Run tests again**:
```bash
/ut.run pref-2
```

**Review test quality**:
```bash
/ut.review pref-2
```

**Update test spec**:
```bash
/ut.specify pref-2
```
```

### Step 9: Provide Actionable Suggestions

For each issue, provide:

1. **Specific file and line number**
2. **Clear description of the problem**
3. **Root cause analysis**
4. **Concrete fix with code example**
5. **Estimated effort**
6. **Priority level** (High/Medium/Low)

### Step 10: Write Results File

1. Create `.specify/features/{feature-id}/test-results.md`
2. Display concise summary to terminal:

```
✅ Test Execution Complete
========================

Framework: Jest 29.7.0
Duration: 2.5s

Results:
  ✅ Passed: 17/19 (89%)
  ❌ Failed: 2/19 (11%)
  📈 Coverage: 87% (Target: 80% ✅)

Failed Tests:
  1. calculator.test.ts:25 - Missing zero-check
  2. payment.test.ts:42 - Timeout mock not configured

Detailed report: .specify/features/pref-2/test-results.md

Next: Fix 2 failing tests (estimated 7 minutes)
```

### Step 11: Handle Edge Cases

**No test files found**:
```
❌ No tests to run
Run: /ut.generate aa-2
```

**Framework not installed**:
```
⚠️ Jest not found
Install: npm install --save-dev jest
```

**Tests won't execute** (syntax errors):
```
❌ Test execution failed
Syntax error in calculator.test.ts:15
Fix syntax errors and try again
```

**All tests pass**:
```
🎉 All Tests Passed!
===================

Results: 19/19 tests passed
Coverage: 87%
Duration: 2.5s

✅ No issues found

Report: .specify/features/pref-2/test-results.md
```

## Quality Checklist

- [ ] Test framework correctly detected
- [ ] All test files found and executed
- [ ] Pass/fail status accurately captured
- [ ] Coverage metrics extracted
- [ ] Failures analyzed with root causes
- [ ] Specific fixes provided with code examples
- [ ] Priority and effort estimates included
- [ ] Actionable next steps provided
- [ ] Results written to test-results.md
- [ ] Terminal summary displayed

## Example Usage

```bash
# Execute tests for feature aa-2
/ut.run pref-2

# Output:
# Detecting framework... Jest 29.7.0
# Found 3 test files (19 tests)
# Executing tests...
#
# Running: calculator.test.ts ✅ 4/5
# Running: cart.test.ts ✅ 8/8
# Running: payment.test.ts ✅ 5/6
#
# ✅ Test Execution Complete
# Results: 17/19 passed (89%)
# Coverage: 87%
#
# 2 failures detected. See test-results.md
```

## Error Handling

- **Cannot execute tests**: Report command that failed with error message
- **Coverage tool not available**: Run tests without coverage, note limitation
- **Parse error**: Show raw output and note parsing failed
- **Permission denied**: Report file system permission issue

## Notes

- This is a **prompt-based workflow** - AI agent executes and analyzes tests
- Execution is **non-destructive** - only runs tests, doesn't modify code
- Provides **actionable feedback** with specific fixes
- **Prioritized recommendations** help developers focus on critical issues
- **Coverage data** helps identify untested code paths
- Ready for **iterative test improvement** workflow
