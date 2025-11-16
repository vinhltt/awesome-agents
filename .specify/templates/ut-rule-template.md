# Unit Test Rules - [PROJECT NAME]

**Framework**: [FRAMEWORK_NAME] [VERSION]
**Created**: [DATE]
**Last Updated**: [DATE]
**Status**: Active

---

## Purpose

<!--
  This document defines the unit testing standards and conventions for this project.
  All tests written for this project MUST follow these rules to ensure consistency,
  maintainability, and quality.

  IMPORTANT: This file is referenced by `/ut.plan` and `/ut.generate` commands.
  Any changes here will affect how future tests are generated.
-->

This document establishes:
- ✅ How to write unit tests (naming, structure, patterns)
- ✅ Which testing tools and matchers to use
- ✅ Team conventions for mocking and assertions
- ✅ Quality gates and coverage requirements

---

## Test File Organization *(mandatory)*

<!--
  ACTION REQUIRED: Define where test files should be located.
  This section was determined by the test organization pattern detection in `/ut.plan`.
-->

### Pattern
**Selected Pattern**: [PATTERN_TYPE]
- `directory-root`: Tests in `/tests/` directory at project root
- `directory-subdirs`: Tests in `__tests__/` subdirectories next to source
- `co-located`: Tests next to source files with `.test.*` or `.spec.*` extension
- `separate-project`: Tests in separate test project (e.g., `{Project}.Tests/`)

### Structure
```
[EXAMPLE_STRUCTURE]

Example:
/tests/
  ├── composables/
  │   └── useCalculator.test.ts
  └── utils/
      └── validator.test.ts
```

**Rationale**: [WHY_THIS_PATTERN - e.g., "Nuxt official convention", "Existing project pattern", "Team preference"]

---

## Naming Conventions *(mandatory)*

<!--
  IMPORTANT: Consistent naming makes tests easier to understand and maintain.
  All test cases MUST follow these patterns.
-->

### Test Files
- **Pattern**: [PATTERN - e.g., `*.test.ts`, `*.spec.ts`, `test_*.py`]
- **Example**: `useCalculator.test.ts`, `validator.test.ts`
- **DO NOT use**: [ANTI_PATTERNS - e.g., `*.tests.ts`, `test-*.ts`]

### Describe Blocks
- **Pattern**: [PATTERN - e.g., "Component/function name", "Class name"]
- **Example**:
  ```typescript
  describe('useCalculator', () => { ... })
  describe('UserService', () => { ... })
  ```

### Test Cases (it/test blocks)
- **Pattern**: [PATTERN - e.g., `"should {action} {when condition}"`, `"should {expected behavior}"`]
- **Examples**:
  - ✅ GOOD: `"should return sum when given two valid numbers"`
  - ✅ GOOD: `"should throw error when dividing by zero"`
  - ❌ BAD: `"test add function"` (too vague)
  - ❌ BAD: `"it works"` (not descriptive)

### Variables and Constants
- **Test data**: [CONVENTION - e.g., `validInput`, `invalidEmail`, `mockUser`]
- **Mocks**: [CONVENTION - e.g., `mockApiService`, `mockDatabase`]
- **Fixtures**: [CONVENTION - e.g., `userFixture`, `sampleProducts`]

---

## Test Structure & Patterns *(mandatory)*

<!--
  ACTION REQUIRED: Define the standard structure for test cases.
  This ensures all tests are written consistently across the project.
-->

### Preferred Pattern
**Selected**: [PATTERN_NAME - e.g., "AAA (Arrange-Act-Assert)", "Given-When-Then", "Setup-Exercise-Verify"]

**Template**:
```typescript
it('should [expected behavior]', () => {
  // Arrange: Setup test data and preconditions
  const input = { ... };
  const expected = { ... };

  // Act: Execute the code being tested
  const result = functionUnderTest(input);

  // Assert: Verify the outcome
  expect(result).toBe(expected);
});
```

### Comments Policy
- **When to comment**: [GUIDELINE - e.g., "Only for complex setup", "Never for obvious assertions"]
- **Example**:
  ```typescript
  // ✅ GOOD: Comment explaining WHY
  // Mock Date.now() to return fixed timestamp for consistent test results
  vi.spyOn(Date, 'now').mockReturnValue(1234567890);

  // ❌ BAD: Comment stating the WHAT (obvious from code)
  // Set x to 5
  const x = 5;
  ```

### Assertions Per Test
**Policy**: [PREFERENCE - e.g., "Prefer one assertion per test", "Multiple assertions allowed if testing same behavior"]

**Rationale**: [REASON - e.g., "Makes failures easier to diagnose", "Keeps tests focused"]

---

## Framework-Specific Syntax *(mandatory)*

<!--
  IMPORTANT: This section defines which matchers and APIs to use.
  Following these conventions ensures tests are consistent and idiomatic.
-->

### Import Statement
```typescript
[IMPORT_EXAMPLE]

// Example for Vitest:
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

// Example for Jest:
import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals'

// Example for Pytest:
import pytest
from unittest.mock import Mock, patch
```

### Matchers & Assertions

#### Equality
- **Primitives** (numbers, strings, booleans): [MATCHER - e.g., `toBe()`, `assert x == y`]
  ```typescript
  expect(result).toBe(5)
  ```
- **Objects/Arrays**: [MATCHER - e.g., `toEqual()`, `toStrictEqual()`, `assert x == y`]
  ```typescript
  expect(user).toEqual({ id: 1, name: 'John' })
  ```
- **Prefer**: [GUIDANCE - e.g., "`toStrictEqual()` over `toEqual()` for stricter checks"]

#### Decimals/Floats
- **Matcher**: [MATCHER - e.g., `toBeCloseTo(value, precision)`, `pytest.approx()`]
  ```typescript
  expect(result).toBeCloseTo(8.7, 1)  // 8.7 ± 0.1
  ```
- **Precision**: [DEFAULT - e.g., "2 decimal places unless specified"]

#### Truthiness
- **Avoid**: [MATCHERS - e.g., `toBeDefined()`, `toBeTruthy()`, `toBeFalsy()`]
- **Use instead**: [ALTERNATIVES - e.g., "Explicit checks like `toBe(true)`, `toEqual(expectedValue)`"]
- **Rationale**: [REASON - e.g., "Too weak, don't catch unexpected values"]

#### Errors/Exceptions
- **Matcher**: [MATCHER - e.g., `toThrow('exact message')`, `pytest.raises(ErrorType)`]
  ```typescript
  expect(() => divide(10, 0)).toThrow('Division by zero')
  ```
- **Message matching**: [POLICY - e.g., "Use exact message match", "Regex allowed for dynamic messages"]

#### Arrays & Collections
- **Contains**: [MATCHER - e.g., `toContain()`, `in operator`]
- **Length**: [MATCHER - e.g., `toHaveLength()`, `len()` assertion]
- **Subset**: [MATCHER - e.g., `toMatchObject()`, `subset check`]

#### Async/Promises
- **Syntax**: [PATTERN - e.g., `async/await`, `.resolves`, `.rejects`]
  ```typescript
  await expect(asyncFunction()).resolves.toBe(value)
  await expect(asyncFunction()).rejects.toThrow(Error)
  ```

### Lifecycle Hooks
```typescript
[LIFECYCLE_EXAMPLE]

// Example for Vitest/Jest:
beforeEach(() => {
  // Setup before each test
});

afterEach(() => {
  // Cleanup after each test
  vi.clearAllMocks();
});

// Example for Pytest:
@pytest.fixture
def setup_data():
    # Setup
    yield data
    # Teardown
```

---

## Mocking Strategy *(mandatory)*

<!--
  ACTION REQUIRED: Define how external dependencies should be mocked.
  Consistent mocking makes tests isolated, fast, and reliable.
-->

### External APIs / Services
- **Strategy**: [APPROACH - e.g., "Full mock with `vi.mock()`", "Use MSW for HTTP mocking"]
- **Location**: [WHERE - e.g., "At top of test file", "In setup function"]
- **Example**:
  ```typescript
  [MOCKING_EXAMPLE]

  // Example for Vitest:
  vi.mock('./api/payment', () => ({
    processPayment: vi.fn()
  }));

  // In test:
  import { processPayment } from './api/payment';
  (processPayment as Mock).mockResolvedValue({ success: true });
  ```

### Database
- **Strategy**: [APPROACH - e.g., "In-memory database", "Mock repository layer", "Use test database"]
- **Rationale**: [REASON - e.g., "Tests should not depend on external DB state"]
- **Example**:
  ```typescript
  [DATABASE_MOCK_EXAMPLE]
  ```

### File System
- **Strategy**: [APPROACH - e.g., "Mock fs module", "Use virtual filesystem", "Use temp directory"]
- **Cleanup**: [POLICY - e.g., "Always clean up in afterEach()"]

### Time & Date
- **Strategy**: [APPROACH - e.g., "Use `vi.useFakeTimers()`", "Mock `Date.now()`"]
- **Example**:
  ```typescript
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-01-01'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });
  ```

### Third-Party Libraries
- **Policy**: [APPROACH - e.g., "Mock at module level", "Use library's test utilities if available"]
- **Common libraries**:
  - [LIBRARY_1]: [HOW_TO_MOCK]
  - [LIBRARY_2]: [HOW_TO_MOCK]

---

## Edge Cases & Error Handling *(mandatory)*

<!--
  IMPORTANT: Edge cases reveal bugs that happy path tests miss.
  Prioritize these edge cases in all tests.
-->

### Priority Order
1. **[PRIORITY_1]** - [DESCRIPTION - e.g., "Error conditions (null, undefined, invalid input)"]
2. **[PRIORITY_2]** - [DESCRIPTION - e.g., "Boundary values (min, max, zero)"]
3. **[PRIORITY_3]** - [DESCRIPTION - e.g., "Type quirks (NaN, Infinity, empty arrays)"]

### Common Edge Cases to Always Test

#### Null/Undefined Handling
```typescript
// Always test:
- null input
- undefined input
- Missing required fields
```

#### Boundary Values
```typescript
// Always test:
- Zero
- Negative numbers
- Maximum/minimum values
- Empty arrays/objects
- Very large numbers (> Number.MAX_SAFE_INTEGER)
```

#### Type-Specific Edge Cases
- **Numbers**: [CASES - e.g., "NaN, Infinity, -Infinity, 0, -0"]
- **Strings**: [CASES - e.g., "Empty string, whitespace-only, very long strings"]
- **Arrays**: [CASES - e.g., "Empty array, single element, very large arrays"]
- **Objects**: [CASES - e.g., "Empty object, circular references, null prototype"]

### Error Conditions
**Must test**:
- Invalid input types
- Out-of-range values
- Missing dependencies
- Network failures (for async operations)
- Race conditions (for concurrent code)

---

## Coverage Requirements *(mandatory)*

<!--
  ACTION REQUIRED: Set realistic coverage goals based on project criticality.
  These gates will be enforced by CI/CD or test review process.
-->

### Target Coverage
- **Overall Target**: [PERCENTAGE - e.g., "80%"]
- **Critical Paths**: [PERCENTAGE - e.g., "90%+"]
- **New Code**: [PERCENTAGE - e.g., "85%+ for new features"]

### By Priority
| Priority | Coverage Target | Rationale |
|----------|----------------|-----------|
| **P1** (Critical) | [TARGET - e.g., "95%+"] | [REASON - e.g., "Core business logic"] |
| **P2** (Important) | [TARGET - e.g., "85%+"] | [REASON - e.g., "Important features"] |
| **P3** (Supporting) | [TARGET - e.g., "75%+"] | [REASON - e.g., "Utility functions"] |

### Excluded from Coverage
- Configuration files (e.g., `*.config.ts`)
- Type definitions (e.g., `*.d.ts`, `types.ts`)
- [OTHER_EXCLUSIONS - e.g., "Generated code", "Third-party integrations"]

### Coverage Reports
- **Tool**: [TOOL - e.g., "Vitest coverage with c8", "Jest coverage", "pytest-cov"]
- **Reporters**: [FORMATS - e.g., "lcov, text, html"]
- **Location**: [PATH - e.g., "`/coverage/` directory (gitignored)"]

---

## Test Data & Fixtures *(recommended)*

<!--
  OPTIONAL: Define standards for test data management.
  Include if project has complex test data requirements.
-->

### Fixtures Location
- **Path**: [LOCATION - e.g., "`/tests/fixtures/`", "`__fixtures__/`"]
- **Format**: [FORMAT - e.g., "JSON files", "TypeScript objects", "Python dataclasses"]

### Naming Convention
- **Pattern**: [PATTERN - e.g., "`{entity}Fixture.ts`", "`sample_{entity}.json`"]
- **Examples**:
  - `userFixture.ts` - Sample user objects
  - `productFixture.ts` - Sample product data

### Reusability
- **Shared fixtures**: [WHERE - e.g., "In `/tests/fixtures/common/`"]
- **Feature-specific**: [WHERE - e.g., "In same directory as test file"]

---

## Performance & Timeouts *(recommended)*

<!--
  OPTIONAL: Include if project has performance requirements for tests.
-->

### Test Execution Time
- **Individual test**: [LIMIT - e.g., "< 100ms"]
- **Full suite**: [LIMIT - e.g., "< 10 seconds"]
- **Async operations**: [TIMEOUT - e.g., "5 seconds max"]

### Timeout Configuration
```typescript
[TIMEOUT_EXAMPLE]

// Example for Vitest:
vi.setTimeout(5000);

// Example for Jest:
jest.setTimeout(5000);
```

---

## Continuous Integration *(recommended)*

<!--
  OPTIONAL: Define how tests run in CI/CD pipeline.
-->

### Pre-commit Hooks
- **Run tests**: [WHEN - e.g., "On staged files only", "Full suite"]
- **Coverage check**: [POLICY - e.g., "Fail if coverage drops below threshold"]

### Pull Request Requirements
- **All tests pass**: [REQUIRED - "Yes" or "No"]
- **Coverage threshold**: [THRESHOLD - e.g., "No decrease in overall coverage"]
- **New code coverage**: [THRESHOLD - e.g., "85%+ for new files"]

---

## Quality Checklist

<!--
  Use this checklist to validate tests follow the rules.
  This can be used during code review or automated linting.
-->

### Before Committing Tests
- [ ] Test file follows naming convention
- [ ] All test cases use "should" pattern (or defined pattern)
- [ ] AAA pattern (or defined pattern) is followed
- [ ] No weak assertions (`toBeDefined`, `toBeTruthy`)
- [ ] Edge cases are tested (null, boundary values)
- [ ] Error cases have explicit assertions
- [ ] Mocks are cleared in `afterEach()`
- [ ] No hardcoded values (use constants/fixtures)
- [ ] Async tests use `async/await` consistently
- [ ] Coverage meets threshold for new code

### Code Review Checklist
- [ ] Tests are independent (can run in any order)
- [ ] No flaky tests (consistent results)
- [ ] Test names clearly describe behavior
- [ ] Mocking strategy follows project rules
- [ ] No test pollution (state leaking between tests)

---

## Examples

<!--
  Provide concrete examples following all the rules above.
  These serve as templates for developers writing new tests.
-->

### Example 1: Simple Function Test
```typescript
[SIMPLE_EXAMPLE]

// Example for Vitest:
import { describe, it, expect } from 'vitest'
import { add } from './calculator'

describe('add', () => {
  it('should return sum when given two positive numbers', () => {
    // Arrange
    const a = 5
    const b = 3

    // Act
    const result = add(a, b)

    // Assert
    expect(result).toBe(8)
  })

  it('should handle negative numbers', () => {
    expect(add(-5, -3)).toBe(-8)
  })

  it('should handle decimal numbers', () => {
    expect(add(5.5, 3.2)).toBeCloseTo(8.7, 1)
  })
})
```

### Example 2: Error Handling Test
```typescript
[ERROR_EXAMPLE]

// Example for Vitest:
import { describe, it, expect } from 'vitest'
import { divide } from './calculator'

describe('divide', () => {
  it('should throw error when dividing by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero')
  })

  it('should return quotient for valid division', () => {
    expect(divide(10, 2)).toBe(5)
  })
})
```

### Example 3: Async Test with Mocking
```typescript
[ASYNC_MOCK_EXAMPLE]

// Example for Vitest:
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fetchUser } from './userService'

vi.mock('./api/client')

describe('fetchUser', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should return user data when API call succeeds', async () => {
    // Arrange
    const mockUser = { id: 1, name: 'John' }
    const mockClient = await import('./api/client')
    mockClient.get.mockResolvedValue({ data: mockUser })

    // Act
    const result = await fetchUser(1)

    // Assert
    expect(result).toEqual(mockUser)
    expect(mockClient.get).toHaveBeenCalledWith('/users/1')
  })

  it('should throw error when API call fails', async () => {
    // Arrange
    const mockClient = await import('./api/client')
    mockClient.get.mockRejectedValue(new Error('Network error'))

    // Act & Assert
    await expect(fetchUser(1)).rejects.toThrow('Network error')
  })
})
```

---

## Enforcement

<!--
  How these rules are enforced in the development workflow.
-->

### Automated Checks
- **Linter**: [TOOL - e.g., "ESLint with testing plugin"]
- **Pre-commit**: [CHECKS - e.g., "Run tests, check coverage"]
- **CI/CD**: [GATES - e.g., "Fail build if tests fail or coverage drops"]

### Manual Review
- **Code review**: Reviewer checks compliance with rules
- **Test review**: Tests must be approved by [REVIEWER - e.g., "tech lead", "QA team"]

---

## Exceptions & Waivers

<!--
  Sometimes rules need to be broken for good reasons.
  Document the process for getting approval.
-->

### When Exceptions Allowed
- [SCENARIO_1 - e.g., "Legacy code requiring major refactor"]
- [SCENARIO_2 - e.g., "Third-party library integration with no mocking support"]

### Approval Process
1. [STEP_1 - e.g., "Document reason in PR description"]
2. [STEP_2 - e.g., "Get approval from tech lead"]
3. [STEP_3 - e.g., "Add TODO comment in code with ticket number"]

---

## Updates & Versioning

<!--
  How this document evolves over time.
-->

### Updating Rules
- **Who**: [WHO - e.g., "Tech lead, team consensus"]
- **Process**: [HOW - e.g., "Propose change in team meeting, vote, update doc"]
- **Communication**: [HOW - e.g., "Announce in team chat, send email"]

### Version History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | [DATE] | Initial version | [AUTHOR] |
| [VERSION] | [DATE] | [CHANGES] | [AUTHOR] |

---

## References

<!--
  Links to external resources and documentation.
-->

### Framework Documentation
- **[FRAMEWORK]**: [LINK - e.g., "https://vitest.dev/guide/"]
- **Testing Library**: [LINK]

### Project-Specific Docs
- **UT Workflow**: [LINK - e.g., "See `/ut.specify`, `/ut.plan`, `/ut.generate` commands"]
- **Test Spec Template**: [LINK - e.g., "`.specify/templates/test-spec-template.md`"]

### Best Practices
- [RESOURCE_1 - e.g., "Kent C. Dodds - Testing Best Practices"]
- [RESOURCE_2 - e.g., "Martin Fowler - Unit Testing"]

---

**Rules Version**: 1.0
**Last Review**: [DATE]
**Next Review**: [DATE - e.g., "Quarterly, or when framework updates"]
