# Jest Test Case Patterns

## 1. Happy Path Testing

Test the expected, successful execution path.

```javascript
describe('UserService.createUser()', () => {
  it('should create user with valid data', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com',
      age: 30
    };

    const user = await userService.createUser(userData);

    expect(user).toMatchObject({
      id: expect.any(String),
      name: 'John Doe',
      email: 'john@example.com',
      age: 30,
      createdAt: expect.any(Date)
    });
  });
});
```

## 2. Edge Case Testing

Test boundary conditions and edge cases.

```javascript
describe('StringValidator.validateLength()', () => {
  it('should accept string at minimum length', () => {
    expect(validator.validateLength('ab', 2, 10)).toBe(true);
  });

  it('should accept string at maximum length', () => {
    expect(validator.validateLength('1234567890', 2, 10)).toBe(true);
  });

  it('should reject string below minimum length', () => {
    expect(validator.validateLength('a', 2, 10)).toBe(false);
  });

  it('should reject string above maximum length', () => {
    expect(validator.validateLength('12345678901', 2, 10)).toBe(false);
  });

  it('should handle empty string', () => {
    expect(validator.validateLength('', 2, 10)).toBe(false);
  });
});
```

## 3. Error Handling Testing

Test how code handles errors and exceptional conditions.

```javascript
describe('FileReader.readFile()', () => {
  it('should throw error for non-existent file', async () => {
    await expect(
      fileReader.readFile('/nonexistent/file.txt')
    ).rejects.toThrow('File not found');
  });

  it('should throw error for invalid file path', async () => {
    await expect(
      fileReader.readFile(null)
    ).rejects.toThrow('Invalid file path');
  });

  it('should handle permission denied error', async () => {
    await expect(
      fileReader.readFile('/root/protected.txt')
    ).rejects.toThrow('Permission denied');
  });
});
```

## 4. State-Based Testing

Test that object state changes correctly.

```javascript
describe('ShoppingCart', () => {
  let cart;

  beforeEach(() => {
    cart = new ShoppingCart();
  });

  it('should start empty', () => {
    expect(cart.getItemCount()).toBe(0);
    expect(cart.getTotal()).toBe(0);
  });

  it('should add items correctly', () => {
    cart.addItem({ id: 1, name: 'Book', price: 10 });

    expect(cart.getItemCount()).toBe(1);
    expect(cart.getTotal()).toBe(10);
  });

  it('should remove items correctly', () => {
    cart.addItem({ id: 1, name: 'Book', price: 10 });
    cart.removeItem(1);

    expect(cart.getItemCount()).toBe(0);
    expect(cart.getTotal()).toBe(0);
  });

  it('should update quantity correctly', () => {
    cart.addItem({ id: 1, name: 'Book', price: 10 });
    cart.updateQuantity(1, 3);

    expect(cart.getItemCount()).toBe(3);
    expect(cart.getTotal()).toBe(30);
  });
});
```

## 5. Parameterized Testing (Table-Driven Tests)

Test multiple inputs with same logic using test.each().

```javascript
describe('Calculator.multiply()', () => {
  it.each([
    [2, 3, 6],
    [0, 5, 0],
    [-2, 3, -6],
    [-2, -3, 6],
    [1.5, 2, 3]
  ])('should multiply %p and %p to get %p', (a, b, expected) => {
    expect(calculator.multiply(a, b)).toBe(expected);
  });
});

// With descriptive names
describe('EmailValidator.isValid()', () => {
  it.each([
    { email: 'test@example.com', valid: true, reason: 'standard email' },
    { email: 'user+tag@example.com', valid: true, reason: 'email with plus' },
    { email: 'invalid@', valid: false, reason: 'missing domain' },
    { email: '@example.com', valid: false, reason: 'missing local part' },
    { email: 'no-at-sign.com', valid: false, reason: 'missing @ symbol' }
  ])('should return $valid for $reason: $email', ({ email, valid }) => {
    expect(validator.isValid(email)).toBe(valid);
  });
});
```

## 6. Snapshot Testing

Test that component output doesn't change unexpectedly.

```javascript
describe('UserProfile component', () => {
  it('should match snapshot for logged-in user', () => {
    const user = { name: 'John', role: 'admin' };
    const component = renderUserProfile(user);

    expect(component).toMatchSnapshot();
  });

  it('should match snapshot for guest user', () => {
    const component = renderUserProfile(null);

    expect(component).toMatchSnapshot();
  });
});
```

## 7. Timeout Testing

Test time-sensitive operations.

```javascript
describe('Cache', () => {
  it('should expire items after timeout', async () => {
    cache.set('key', 'value', { ttl: 100 }); // 100ms TTL

    expect(cache.get('key')).toBe('value');

    await new Promise(resolve => setTimeout(resolve, 150));

    expect(cache.get('key')).toBeUndefined();
  }, 200); // Increase test timeout
});
```

## 8. Callback Testing

Test functions that accept callbacks.

```javascript
describe('EventEmitter', () => {
  it('should call callback when event is emitted', () => {
    const callback = jest.fn();
    emitter.on('test', callback);

    emitter.emit('test', 'data');

    expect(callback).toHaveBeenCalledWith('data');
    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('should call multiple listeners', () => {
    const callback1 = jest.fn();
    const callback2 = jest.fn();

    emitter.on('test', callback1);
    emitter.on('test', callback2);
    emitter.emit('test');

    expect(callback1).toHaveBeenCalled();
    expect(callback2).toHaveBeenCalled();
  });
});
```

## 9. Conditional Testing

Skip or run tests based on conditions.

```javascript
// Skip test
it.skip('should do something (not implemented yet)', () => {
  // Test code
});

// Only run this test
it.only('should focus on this test', () => {
  // Only this test will run
});

// Conditional test
const runOnlyInCI = process.env.CI ? it : it.skip;

runOnlyInCI('should run only in CI environment', () => {
  // Test code
});
```

## 10. Testing Private Methods (via Public Interface)

```javascript
describe('UserValidator (private methods tested via public interface)', () => {
  it('should validate user correctly (tests private isEmailValid)', () => {
    // Don't test private isEmailValid() directly
    // Test it through public validate() method
    const result = validator.validate({
      email: 'invalid-email'
    });

    expect(result.valid).toBe(false);
    expect(result.errors).toContain('Invalid email format');
  });
});
```

## Test Naming Conventions

### Good Test Names (Descriptive & Specific)
```javascript
it('should return 400 when email is missing')
it('should increment counter when button is clicked')
it('should throw ValidationError for negative age')
it('should cache result for 5 minutes after first call')
```

### Bad Test Names (Vague)
```javascript
it('works')  // Too vague
it('test email')  // Not descriptive
it('should handle edge case')  // Which edge case?
```

## Test Organization

```javascript
describe('Component/Module Name', () => {
  // Test suite setup
  beforeAll(() => {
    // One-time setup
  });

  afterAll(() => {
    // One-time teardown
  });

  describe('method/function name', () => {
    // Method-specific setup
    beforeEach(() => {
      // Per-test setup
    });

    // Happy path tests first
    it('should handle normal case', () => {});

    // Edge cases
    it('should handle boundary condition', () => {});

    // Error cases
    it('should throw error for invalid input', () => {});
  });

  describe('another method', () => {
    // More tests
  });
});
```
