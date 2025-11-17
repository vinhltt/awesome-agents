# /ut.review - Review and Validate Generated Tests

## Purpose

Analyze generated test code for quality, completeness, and adherence to best practices. Provide actionable feedback on improvements, missing test cases, and potential issues.

## Input

- **Feature ID**: Required argument (e.g., `aa-2`)
- **Test Files**: Searches for generated test files
- **Test Spec**: Reads `.specify/features/{feature-id}/test-spec.md` for requirements
- **Test Plan**: Reads `.specify/features/{feature-id}/test-plan.md` for structure

## Output

Creates `.specify/features/{feature-id}/review-report.md` with:

1. **Overall Quality Score**: Percentage-based assessment
2. **Completeness Analysis**: Coverage vs requirements
3. **Quality Issues**: Specific problems identified
4. **Best Practice Violations**: Framework conventions not followed
5. **Improvement Recommendations**: Actionable suggestions
6. **Code Examples**: Before/after for improvements

## Review Dimensions

### 1. Completeness (Weight: 30%)
- All test scenarios from test-spec.md covered
- All test cases implemented
- Edge cases included
- Error scenarios tested

### 2. Assertion Quality (Weight: 25%)
- Specific assertions (not just `toBeDefined()`)
- Meaningful error messages
- Appropriate matchers used
- Multiple assertions where needed

### 3. Best Practices (Weight: 20%)
- Framework conventions followed
- Proper test structure (AAA pattern)
- Good test names
- DRY principle (no duplication)

### 4. Mocking (Weight: 15%)
- External dependencies properly mocked
- Mocks isolated from real implementations
- Mock cleanup in teardown
- Mock assertions verify behavior

### 5. Maintainability (Weight: 10%)
- Clear test organization
- Reusable fixtures
- Documentation comments
- Consistent naming

## Execution Instructions

### Step 1: Locate Test Files

Search for generated test files:

**Jest/Vitest**:
- `**/*.test.{js,ts,jsx,tsx}`
- `**/*.spec.{js,ts,jsx,tsx}`
- `**/__tests__/**/*.{js,ts,jsx,tsx}`

**Pytest**:
- `**/test_*.py`
- `**/*_test.py`
- `tests/**/*.py`

### Step 2: Load Reference Documents

Read for comparison:
- **test-spec.md**: Expected test scenarios and cases
- **test-plan.md**: Planned test structure
- **Test files**: Actual implementation

### Step 3: Analyze Completeness

**Check Test Coverage**:

```markdown
## Completeness Analysis

### Test Scenarios Coverage

| Scenario ID | Description | Status | Issues |
|-------------|-------------|--------|--------|
| TS-001 | User authentication | ✅ Complete | None |
| TS-002 | Payment processing | ⚠️ Partial | Missing error case TC-015 |
| TS-003 | Data validation | ❌ Missing | No tests found |

**Coverage**: 15 of 18 test cases implemented (83%)

### Missing Test Cases

1. **TC-015**: Payment gateway timeout scenario
   - **Impact**: High
   - **Recommendation**: Add test for timeout handling

2. **TC-018**: Invalid data format edge case
   - **Impact**: Medium
   - **Recommendation**: Add boundary condition tests
```

### Step 4: Evaluate Assertion Quality

**Good Assertions**:
```typescript
✅ expect(user.email).toBe('john@example.com');
✅ expect(result).toMatchObject({ id: 1, name: 'John' });
✅ expect(calculateTotal([1,2,3])).toBe(6);
```

**Weak Assertions** (flag these):
```typescript
❌ expect(result).toBeDefined();  // Too vague
❌ expect(data).toBeTruthy();     // What specifically should be true?
❌ expect(fn()).not.toThrow();    // Test should verify actual behavior
```

**Report**:
```markdown
## Assertion Quality

**Weak Assertions Found**: 5

### Issues

1. **calculator.test.ts:15**
   ```typescript
   expect(result).toBeDefined();
   ```
   **Problem**: Assertion too vague
   **Recommendation**:
   ```typescript
   expect(result).toBe(8);  // Specific expected value
   ```

2. **payment.test.ts:42**
   ```typescript
   expect(response.success).toBeTruthy();
   ```
   **Problem**: Should use strict equality
   **Recommendation**:
   ```typescript
   expect(response.success).toBe(true);
   ```
```

### Step 5: Check Best Practices

**Framework Conventions**:

✅ **Good**:
```typescript
describe('ShoppingCart', () => {
  let cart: ShoppingCart;

  beforeEach(() => {
    cart = new ShoppingCart();
  });

  describe('addItem()', () => {
    it('should add item to cart successfully', () => {
      // Arrange
      const item = { id: 1, price: 10 };

      // Act
      cart.addItem(item);

      // Assert
      expect(cart.getItems()).toHaveLength(1);
      expect(cart.getTotal()).toBe(10);
    });
  });
});
```

❌ **Issues**:
```typescript
// Missing describe grouping
it('test adding item', () => {  // Vague name
  const c = new ShoppingCart();  // Poor variable name
  c.addItem({id:1,price:10});   // Missing spacing
  expect(c.getItems().length).toBe(1);  // Not using toHaveLength()
});
```

### Step 6: Verify Mocking

**Check for**:

1. **External dependencies mocked**:
   ```typescript
   ✅ jest.mock('./api/payment');  // Good
   ❌ // Direct API call in test - Bad!
   ```

2. **Mock cleanup**:
   ```typescript
   ✅ afterEach(() => {
     jest.clearAllMocks();
   });
   ```

3. **Mock assertions**:
   ```typescript
   ✅ expect(mockFn).toHaveBeenCalledWith(expectedArg);
   ❌ // Mock called but not verified
   ```

### Step 7: Assess Maintainability

**Good Patterns**:
```typescript
// Reusable fixtures
const createValidUser = () => ({
  id: 1,
  name: 'John',
  email: 'john@example.com'
});

// Helper functions
const setupCart = (items: Item[]) => {
  const cart = new ShoppingCart();
  items.forEach(item => cart.addItem(item));
  return cart;
};
```

**Issues to Flag**:
- Duplicated test data
- Long test files (>500 lines)
- Complex setup logic not extracted
- No helper functions

### Step 8: Calculate Quality Score

```typescript
Quality Score =
  (Completeness × 0.30) +
  (AssertionQuality × 0.25) +
  (BestPractices × 0.20) +
  (Mocking × 0.15) +
  (Maintainability × 0.10)
```

**Rating Scale**:
- 90-100%: ⭐⭐⭐⭐⭐ Excellent
- 80-89%: ⭐⭐⭐⭐ Good
- 70-79%: ⭐⭐⭐ Acceptable
- 60-69%: ⭐⭐ Needs Improvement
- <60%: ⭐ Poor

### Step 9: Generate Review Report

```markdown
# Test Review Report: {Feature Name}

**Feature**: {feature-id}
**Reviewed**: {date}
**Test Files**: {count}

## Overall Quality Score: {score}% ⭐⭐⭐⭐

## Summary

- **Completeness**: 83% (15/18 test cases)
- **Assertion Quality**: 85%
- **Best Practices**: 90%
- **Mocking**: 80%
- **Maintainability**: 88%

## ✅ Strengths

1. Good test organization with clear describe blocks
2. Proper use of beforeEach/afterEach for setup
3. External dependencies properly mocked
4. Consistent naming conventions

## ⚠️ Issues Found

### Critical Issues (2)

1. **Missing Test Case: TC-015**
   - **File**: payment.test.ts
   - **Issue**: Payment gateway timeout not tested
   - **Impact**: High - Critical error path uncovered
   - **Fix**: Add test for timeout scenario

2. **No Mock Cleanup**
   - **File**: api.test.ts
   - **Issue**: Mocks not cleared between tests
   - **Impact**: High - Tests may interfere with each other
   - **Fix**: Add `afterEach(() => jest.clearAllMocks())`

### Medium Issues (5)

1. **Weak Assertion** (calculator.test.ts:15)
   - Current: `expect(result).toBeDefined()`
   - Better: `expect(result).toBe(8)`

2. **Vague Test Name** (cart.test.ts:25)
   - Current: "test adding item"
   - Better: "should add item to cart and update total"

{Continue with all issues...}

### Low Issues (3)

{Minor style/formatting issues...}

## 📋 Recommendations

### Priority 1: Critical Fixes

- [ ] Add missing test case TC-015 for timeout handling
- [ ] Implement mock cleanup in api.test.ts
- [ ] Add error scenario tests for TS-003

### Priority 2: Quality Improvements

- [ ] Replace weak assertions with specific expectations
- [ ] Improve test names to be more descriptive
- [ ] Extract duplicated test data into fixtures

### Priority 3: Enhancements

- [ ] Add helper functions for common setup patterns
- [ ] Improve test documentation
- [ ] Consider parameterized tests for similar cases

## 📊 Coverage by Module

| Module | Tests | Coverage | Status |
|--------|-------|----------|--------|
| Calculator | 5 | 95% | ✅ |
| ShoppingCart | 8 | 88% | ✅ |
| Payment | 4 | 60% | ⚠️ |

## 🎯 Next Steps

1. **Address critical issues** (2 items)
2. **Fix medium priority items** (5 items)
3. **Re-run tests** to verify fixes
4. **Run `/ut.run`** to execute tests and check coverage

## Code Examples

### Example 1: Improving Weak Assertion

**Before**:
```typescript
it('should calculate total', () => {
  const result = calculator.add(2, 3);
  expect(result).toBeDefined();
});
```

**After**:
```typescript
it('should calculate total correctly', () => {
  const result = calculator.add(2, 3);
  expect(result).toBe(5);
});
```

### Example 2: Adding Mock Cleanup

**Before**:
```typescript
describe('API Tests', () => {
  it('should call API', () => {
    // Test with mock
  });
});
```

**After**:
```typescript
describe('API Tests', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should call API', () => {
    // Test with mock
  });
});
```
```

### Step 10: Write Output

1. Create `.specify/features/{feature-id}/review-report.md`
2. Display summary:

```
✅ Test Review Complete
=======================

Overall Score: 84% ⭐⭐⭐⭐ (Good)

Issues Found:
  Critical: 2
  Medium: 5
  Low: 3

Recommendations: 10 items

Report saved: .specify/features/aa-2/review-report.md

Next: Fix critical issues and re-run tests
```

## Quality Checklist

- [ ] All test files analyzed
- [ ] Completeness compared against test-spec.md
- [ ] Assertion quality evaluated
- [ ] Best practices checked
- [ ] Mocking strategy reviewed
- [ ] Maintainability assessed
- [ ] Quality score calculated
- [ ] Specific recommendations provided
- [ ] Code examples included
- [ ] Prioritized action items listed

## Example Usage

```bash
# Review generated tests
/ut.review aa-2

# Output:
# Analyzing test files... 3 files found
# Comparing with test-spec.md...
# Evaluating assertion quality...
# Checking best practices...
# Calculating quality score...
#
# ✅ Test Review Complete
# Overall Score: 84% ⭐⭐⭐⭐
#
# Critical issues: 2
# See .specify/features/aa-2/review-report.md
```

## Error Handling

- **No test files found**: "No tests to review. Run `/ut.generate {feature-id}` first"
- **Missing test-spec.md**: Can still review but completeness analysis limited
- **Syntax errors in tests**: Report specific file and line number
- **Framework not recognized**: Review generic best practices only

## Notes

- Review is **automated** but **comprehensive**
- Provides **actionable feedback** with examples
- Focuses on **practical improvements**
- **Prioritized recommendations** (critical → low)
- Ready for **iterative refinement**
