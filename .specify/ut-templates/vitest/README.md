# Vitest Test Templates

Vitest is highly compatible with Jest. Most Jest patterns work in Vitest with minimal changes.

## Key Differences from Jest

1. **Import syntax**: Use `'vitest'` instead of `'@jest/globals'`
```javascript
import { describe, it, expect, vi, beforeEach } from 'vitest';
```

2. **Mocking**: Use `vi` instead of `jest`
```javascript
const mockFn = vi.fn();
vi.mock('./module');
vi.spyOn(object, 'method');
```

3. **Timers**: Use `vi.useFakeTimers()` instead of `jest.useFakeTimers()`

## Basic Test Structure

```javascript
import { describe, it, expect, beforeEach } from 'vitest';
import { Calculator } from '../src/calculator';

describe('Calculator', () => {
  let calculator;

  beforeEach(() => {
    calculator = new Calculator();
  });

  it('should add numbers correctly', () => {
    expect(calculator.add(2, 3)).toBe(5);
  });

  it('should handle edge cases', () => {
    expect(calculator.divide(10, 0)).toThrow('Division by zero');
  });
});
```

## Mocking Example

```javascript
import { describe, it, expect, vi } from 'vitest';
import { UserService } from './userService';
import { api } from './api';

vi.mock('./api');

describe('UserService', () => {
  it('should fetch user data', async () => {
    api.get.mockResolvedValue({ data: { id: 1, name: 'John' } });

    const user = await UserService.getUser(1);

    expect(user.name).toBe('John');
    expect(api.get).toHaveBeenCalledWith('/users/1');
  });
});
```

## Async Testing

```javascript
it('should handle async operations', async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
});

it('should resolve promise', async () => {
  await expect(fetchData()).resolves.toBe('value');
});

it('should reject promise', async () => {
  await expect(failingFetch()).rejects.toThrow('Error');
});
```

For more detailed patterns, refer to Jest templates - they are 95% compatible with Vitest.
