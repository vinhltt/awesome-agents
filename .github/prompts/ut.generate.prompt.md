# /ut.generate - Generate Unit Test Code

## Purpose

Generate executable unit test code based on the test implementation plan. Creates test files with test cases, assertions, mocks, and fixtures following project conventions and framework syntax.

## Input

- **Feature ID**: **REQUIRED** argument (e.g., `aa-2`, `AL-991`, `test/aa-123`)
  - Format: `[folder/]prefix-number`
  - Prefix configured in `.specify/.speckit.env`
  - If missing: ERROR "Task ID required. Usage: /ut:generate {task-id}"
- **Test Plan**: Reads from `.specify/features/{feature-id}/test-plan.md`
- **Test Spec**: Reads from `.specify/features/{feature-id}/test-spec.md`
- **Coverage Report**: Reads from `.specify/features/{feature-id}/coverage-report.json`
- **Source Code**: Analyzes actual source files to generate accurate tests

## Output

Creates test files in project directory:
- Jest/Vitest: `*.test.{js|ts}` or `*.spec.{js|ts}`
- Pytest: `test_*.py` or `*_test.py`

With complete test suites including:
- Test setup/teardown
- Test cases with assertions
- Mock implementations
- Test data/fixtures
- Documentation comments

## Execution Instructions

### Step 0: Validate Task ID

**CRITICAL**: Check task ID argument FIRST before any operations.

1. **Parse user input**:
   - Extract first argument from command
   - Expected format: `[folder/]prefix-number` (e.g., `aa-991`, `AL-991`, `test/aa-123`)

2. **Check if task ID provided**:
   ```
   If first argument is EMPTY or MISSING:
     ERROR: "Task ID required. Usage: /ut:generate {task-id}"
     STOP - Do NOT proceed to Step 1
   ```

3. **Validate task ID format**:
   - Must match pattern: `[folder/]prefix-number`
   - Prefix must be in `.specify/.speckit.env` SPECKIT_PREFIX_LIST
   - If invalid: ERROR "Invalid task ID format: '{input}'"

**Examples**:
- ✅ CORRECT: `/ut:generate aa-991`
- ✅ CORRECT: `/ut:generate AL-991`
- ❌ WRONG: `/ut:generate` (no task ID)

### Step 1: Load and Validate Inputs

1. **Check test-plan.md exists**: Contains test structure and task breakdown
2. **Check test-spec.md exists**: Contains test scenarios and expected outcomes
3. **Check coverage-report.json exists**: Contains framework info

If missing → Provide guidance on running prerequisite commands

### Step 2: Read Test Organization Pattern

**CRITICAL**: Read test file organization pattern from test-plan.md

1. **Load test-plan.md**
2. **Find "Test Organization Decision" section**:
   ```markdown
   ## Test Organization Decision

   **Pattern**: Directory-based with `__tests__/` subdirectories
   **Structure**: `{source-dir}/__tests__/{filename}.test.ts`
   **Detected from**: ...
   ```

3. **Extract pattern information**:
   - **Pattern type**: directory | co-located | separate-project
   - **Structure template**: Exact file path pattern (e.g., `/tests/**/*.test.ts` or `{source-dir}/__tests__/*.test.ts`)
   - **Naming convention**: `*.test.ts` vs `test_*.py` etc.

4. **Use this pattern** to determine test file paths in Step 5

**Examples**:

**Pattern 1: Root-level `/tests/` directory (Nuxt/Vue convention)**:
```
Structure: /tests/**/*.test.ts
Source: composables/useCalculator.ts
Test file: /tests/composables/useCalculator.test.ts  ← Create here
```

**Pattern 2: `__tests__/` subdirectories (Jest/Vitest convention)**:
```
Structure: {source-dir}/__tests__/{filename}.test.ts
Source: composables/useCalculator.ts
Test file: composables/__tests__/useCalculator.test.ts  ← Create here
```

**Pattern 3: Co-located (Angular convention)**:
```
Structure: {source-dir}/{filename}.spec.ts
Source: composables/useCalculator.ts
Test file: composables/useCalculator.spec.ts  ← Create here
```

**If "Test Organization Decision" section is missing**:
- ❌ STOP and report error
- Tell user to run `/ut.plan {feature-id}` first
- Pattern decision is MANDATORY for correct test placement

### Step 3: Determine Target Framework

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
- **Jest**: JavaScript/TypeScript (most common)
- **Vitest**: JavaScript/TypeScript (Vite projects)
- **Pytest**: Python

### Step 4: Read Source Code

For each test suite in test-plan.md:

1. **Locate source file**: Read the actual code to be tested
2. **Extract structure**:
   - Function signatures
   - Class definitions and methods
   - Parameter types
   - Return types
3. **Identify dependencies**: Imports, external calls, database access

### Step 5: Determine Test File Paths

Using the pattern from Step 2, determine where to create each test file:

1. **Get source file path** from test-plan.md (e.g., `composables/useCalculator.ts`)
2. **Apply pattern template** from Step 2:
   - If `/tests/**/*.test.ts` → `/tests/composables/useCalculator.test.ts`
   - If `{source-dir}/__tests__/*.test.ts` → `composables/__tests__/useCalculator.test.ts`
   - If `{source-dir}/*.spec.ts` → `composables/useCalculator.spec.ts`

3. **Create parent directories** if they don't exist
4. **Verify write permissions** before attempting file creation

### Step 6: Generate Test File Structure

**For Jest/Vitest**:

```typescript
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals'; // or 'vitest'
import { ClassName } from '../src/module-name';
import { dependency } from '../src/dependency';

// Mock external dependencies
jest.mock('../src/dependency'); // or vi.mock()

describe('ClassName', () => {
  let instance: ClassName;

  beforeEach(() => {
    // Setup: runs before each test
    instance = new ClassName();
  });

  afterEach(() => {
    // Teardown: runs after each test
    jest.clearAllMocks();
  });

  describe('methodName()', () => {
    it('should handle happy path case', () => {
      // Arrange
      const input = { /* test data */ };

      // Act
      const result = instance.methodName(input);

      // Assert
      expect(result).toBeDefined();
      expect(result.property).toBe(expectedValue);
    });

    it('should handle edge case', () => {
      // Test implementation
    });

    it('should throw error for invalid input', () => {
      expect(() => instance.methodName(invalidInput)).toThrow('Error message');
    });
  });
});
```

**For Pytest**:

```python
import pytest
from src.module_name import ClassName
from unittest.mock import Mock, patch

class TestClassName:
    @pytest.fixture
    def instance(self):
        """Fixture: Create instance before each test"""
        return ClassName()

    def test_method_name_happy_path(self, instance):
        """Test methodName with valid input"""
        # Arrange
        input_data = { "key": "value" }

        # Act
        result = instance.method_name(input_data)

        # Assert
        assert result is not None
        assert result.property == expected_value

    def test_method_name_edge_case(self, instance):
        """Test methodName with edge case"""
        # Test implementation
        pass

    def test_method_name_invalid_input(self, instance):
        """Test methodName raises error for invalid input"""
        with pytest.raises(ValueError):
            instance.method_name(invalid_input)
```

### Step 7: Generate Test Cases from Test Spec

For each test case in test-spec.md:

```markdown
##### TC-001: Should calculate total correctly

- **Given**: Shopping cart with 3 items
- **When**: calculateTotal() is called
- **Then**: Returns sum of all item prices
- **Input**: `[{price: 10}, {price: 20}, {price: 30}]`
- **Output**: `60`
```

Generate corresponding test:

```typescript
it('should calculate total correctly', () => {
  // Arrange - from "Given"
  const cart = new ShoppingCart();
  cart.addItem({ id: 1, price: 10 });
  cart.addItem({ id: 2, price: 20 });
  cart.addItem({ id: 3, price: 30 });

  // Act - from "When"
  const total = cart.calculateTotal();

  // Assert - from "Then"
  expect(total).toBe(60);
});
```

### Step 8: Implement Mocking

Based on test-plan.md mocking strategy:

**External API Mock**:
```typescript
// At top of file
jest.mock('./api/payment', () => ({
  processPayment: jest.fn()
}));

// In test
import { processPayment } from './api/payment';

it('should process payment successfully', async () => {
  // Setup mock behavior
  (processPayment as jest.Mock).mockResolvedValue({
    success: true,
    transactionId: 'TX-123'
  });

  // Test code
  const result = await checkout.process();

  // Verify mock was called
  expect(processPayment).toHaveBeenCalledWith({
    amount: 100,
    currency: 'USD'
  });
  expect(result.success).toBe(true);
});
```

**Database Mock**:
```typescript
const mockDb = {
  query: jest.fn(),
  insert: jest.fn(),
  update: jest.fn()
};

jest.mock('./database', () => mockDb);
```

**Pytest Mocking**:
```python
@patch('src.module.external_api_call')
def test_with_mocked_api(mock_api, instance):
    """Test with mocked external API"""
    # Setup mock
    mock_api.return_value = {"status": "success"}

    # Test
    result = instance.method_that_calls_api()

    # Verify
    assert result.status == "success"
    mock_api.assert_called_once()
```

### Step 9: Add Test Data and Fixtures

**Jest/Vitest Fixtures**:
```typescript
const validUser = {
  id: 1,
  name: 'John Doe',
  email: 'john@example.com',
  role: 'admin'
};

const invalidUser = {
  id: -1,
  name: '',
  email: 'invalid-email'
};
```

**Pytest Fixtures**:
```python
@pytest.fixture
def valid_user():
    return {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "admin"
    }

@pytest.fixture
def database_connection():
    """Fixture with setup and teardown"""
    conn = create_test_database()
    yield conn
    conn.close()
```

### Step 10: Handle Async Code

**Jest/Vitest Async Tests**:
```typescript
it('should fetch data asynchronously', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
});

it('should handle async errors', async () => {
  await expect(failingAsyncFunction()).rejects.toThrow('Error');
});
```

**Pytest Async Tests**:
```python
@pytest.mark.asyncio
async def test_async_fetch():
    """Test async function"""
    data = await fetch_data()
    assert data is not None
```

### Step 11: Add Documentation Comments

Add descriptive comments to tests:

```typescript
/**
 * Test suite for ShoppingCart class
 *
 * Tests cover:
 * - Adding/removing items
 * - Calculating totals
 * - Applying discounts
 * - Edge cases (empty cart, negative prices)
 */
describe('ShoppingCart', () => {
  /**
   * Test: Calculate total correctly
   *
   * Verifies that calculateTotal() returns the sum of all item prices
   * when the cart contains multiple items.
   *
   * Related: TC-001 from test-spec.md
   */
  it('should calculate total correctly', () => {
    // Test implementation
  });
});
```

### Step 10: Generate Complete Test Files

For each test suite in test-plan.md, create complete file:

1. **Imports**: Framework imports, source imports, mock imports
2. **Mocks Setup**: Mock declarations
3. **Test Suite**: describe() block
4. **Setup/Teardown**: beforeEach(), afterEach()
5. **Test Cases**: All it() blocks with assertions
6. **Helpers**: Shared test utilities

**File Organization**:
```
tests/
├── unit/
│   ├── calculator.test.ts        ✅ Generated
│   ├── cart.test.ts              ✅ Generated
│   └── payment.test.ts           ✅ Generated
├── integration/
│   └── checkout.test.ts          ✅ Generated
└── fixtures/
    ├── users.ts                  ✅ Generated
    └── products.ts               ✅ Generated
```

### Step 11: Validate Generated Code

Before writing files:

1. **Syntax Check**: Ensure valid JavaScript/TypeScript/Python
2. **Import Validation**: Check that all imports exist
3. **Mock Completeness**: All external dependencies mocked
4. **Assertion Quality**: Meaningful assertions, not just `toBeDefined()`
5. **Edge Cases**: Boundary conditions covered

### Step 12: Write Test Files

1. **Create directories** if they don't exist
2. **Write test files** with proper formatting
3. **Create fixture files** if needed
4. **Update test configuration** if necessary

### Step 13: Report Generation Summary

Display comprehensive summary:

```
✅ Test Files Generated
========================

Framework: Jest 29.7.0
Test Directory: __tests__/

Files Created:
  ✓ calculator.test.ts (5 test cases, 45 lines)
  ✓ cart.test.ts (8 test cases, 120 lines)
  ✓ payment.test.ts (6 test cases, 85 lines)
  ✓ fixtures/users.ts (test data)

Total Test Cases: 19
Total Lines: 250
Coverage Target: 80%

Mocks Implemented:
  - Payment API (full mock)
  - Database (repository mock)
  - File system (stub)

Next Steps:
1. Run tests: npm test (or pytest)
2. Check coverage: npm run test:coverage
3. Review quality: /ut.review aa-2
```

### Step 14: Handle Edge Cases

**Missing source files**:
- Cannot generate tests without source code
- Report: "Source file not found: {path}"
- Skip that test suite, continue with others

**Type information missing** (TypeScript):
- Generate tests with `any` types
- Add TODO comments to add proper types

**Complex mocking scenarios**:
- Generate basic mock structure
- Add TODO comments for manual refinement

**Framework not installed**:
- Detect from package.json / requirements.txt
- Warn: "Jest not installed. Run: npm install --save-dev jest"
- Still generate tests (ready for installation)

## Quality Checklist

- [ ] All test cases from test-spec.md implemented
- [ ] Mocks properly isolate external dependencies
- [ ] Assertions are meaningful and specific
- [ ] Edge cases and error scenarios covered
- [ ] Test code follows framework conventions
- [ ] Imports are correct and complete
- [ ] Setup/teardown properly manages state
- [ ] Generated code is syntactically valid
- [ ] Documentation comments added
- [ ] Fixtures created for reusable test data

## Example Usage

```bash
# Generate test files for feature aa-2
/ut.generate aa-2

# Output:
# Reading test plan... ✓
# Detected framework: Jest 29.7.0
# Analyzing source code... 3 files
# Generating test files...
#   - calculator.test.ts (5 tests)
#   - cart.test.ts (8 tests)
#   - payment.test.ts (6 tests)
# Creating fixtures... ✓
# Implementing mocks... ✓
#
# ✅ Generated 3 test files with 19 test cases
# Total lines: 250
#
# Next: Run 'npm test' to execute tests
```

## Error Handling

- **Missing test plan**: "Run `/ut.plan {feature-id}` first"
- **Source file not found**: Skip test suite, report warning
- **Invalid syntax in generated code**: Report error, provide diagnostic
- **Write permission denied**: Report file path with issue
- **Framework mismatch**: Warn if plan suggests different framework than detected

## Notes

- This is a **prompt-based workflow** - AI agent generates test code
- Generated tests are **syntactically correct** and **executable**
- Mocks properly **isolate** units under test
- Tests follow **framework best practices**
- Code generation uses **actual source code** as reference
- **Human review recommended** before committing (use `/ut.review`)
