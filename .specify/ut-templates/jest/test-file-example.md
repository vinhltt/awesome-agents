# Jest Test File Example

## Basic Test File Structure

```javascript
// calculator.test.js
import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import { Calculator } from '../src/calculator';

describe('Calculator', () => {
  let calculator;

  beforeEach(() => {
    // Setup: Create fresh instance before each test
    calculator = new Calculator();
  });

  afterEach(() => {
    // Teardown: Clean up after each test
    calculator = null;
  });

  describe('add()', () => {
    it('should add two positive numbers correctly', () => {
      // Arrange
      const a = 5;
      const b = 3;

      // Act
      const result = calculator.add(a, b);

      // Assert
      expect(result).toBe(8);
    });

    it('should handle negative numbers', () => {
      expect(calculator.add(-5, 3)).toBe(-2);
      expect(calculator.add(-5, -3)).toBe(-8);
    });

    it('should handle zero', () => {
      expect(calculator.add(0, 5)).toBe(5);
      expect(calculator.add(5, 0)).toBe(5);
      expect(calculator.add(0, 0)).toBe(0);
    });
  });

  describe('divide()', () => {
    it('should divide two numbers correctly', () => {
      expect(calculator.divide(10, 2)).toBe(5);
    });

    it('should throw error when dividing by zero', () => {
      expect(() => calculator.divide(10, 0)).toThrow('Division by zero');
    });

    it('should handle decimal results', () => {
      expect(calculator.divide(10, 3)).toBeCloseTo(3.333, 2);
    });
  });
});
```

## Key Patterns

### 1. Test Organization
- **describe()**: Group related tests
- **it()**: Individual test case
- **Nested describe()**: Sub-groups for methods/features

### 2. Setup & Teardown
- **beforeEach()**: Runs before each test
- **afterEach()**: Runs after each test
- **beforeAll()**: Runs once before all tests
- **afterAll()**: Runs once after all tests

### 3. Arrange-Act-Assert Pattern
```javascript
it('should perform action', () => {
  // Arrange: Set up test data
  const input = createTestData();

  // Act: Execute the function under test
  const result = functionUnderTest(input);

  // Assert: Verify the result
  expect(result).toBe(expectedValue);
});
```

### 4. Common Assertions
```javascript
// Equality
expect(value).toBe(5);              // Strict equality (===)
expect(value).toEqual({a: 1});      // Deep equality
expect(value).not.toBe(null);       // Negation

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3);
expect(value).toBeLessThan(5);
expect(value).toBeCloseTo(0.3, 1);  // Floating point

// Strings
expect(string).toMatch(/pattern/);
expect(string).toContain('substring');

// Arrays and iterables
expect(array).toContain(item);
expect(array).toHaveLength(3);

// Exceptions
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(Error);
expect(() => fn()).toThrow('error message');
```

### 5. Async Testing
```javascript
// Using async/await
it('should handle async operations', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
});

// Using promises
it('should resolve promise', () => {
  return fetchData().then(data => {
    expect(data).toBeDefined();
  });
});

// Using expect().resolves
it('should resolve with value', async () => {
  await expect(fetchData()).resolves.toBe('value');
});

// Using expect().rejects
it('should reject with error', async () => {
  await expect(fetchData()).rejects.toThrow('Error');
});
```

## File Naming Conventions

- **Unit tests**: `filename.test.js` or `filename.spec.js`
- **Integration tests**: `filename.integration.test.js`
- **Location**: Usually `__tests__/` directory or alongside source files

## Test Organization Best Practices

1. **One describe per class/module**
2. **One describe per method/function** (nested)
3. **Test one thing per it()**
4. **Use descriptive test names** that explain the expected behavior
5. **Keep tests independent** - each test should work in isolation
