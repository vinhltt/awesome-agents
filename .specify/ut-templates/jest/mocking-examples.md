# Jest Mocking Examples

## 1. Function Mocking with jest.fn()

### Basic Mock Function
```javascript
describe('Callback testing', () => {
  it('should call callback with correct arguments', () => {
    const mockCallback = jest.fn();

    const processor = new DataProcessor();
    processor.process([1, 2, 3], mockCallback);

    expect(mockCallback).toHaveBeenCalled();
    expect(mockCallback).toHaveBeenCalledTimes(3);
    expect(mockCallback).toHaveBeenCalledWith(1);
    expect(mockCallback).toHaveBeenNthCalledWith(2, 2);
  });
});
```

### Mock Implementation
```javascript
describe('Custom mock behavior', () => {
  it('should use mock implementation', () => {
    const mockFn = jest.fn((x) => x * 2);

    expect(mockFn(5)).toBe(10);
    expect(mockFn).toHaveBeenCalledWith(5);
  });

  it('should use different implementations per call', () => {
    const mockFn = jest.fn()
      .mockReturnValueOnce(10)
      .mockReturnValueOnce(20)
      .mockReturnValue(30);

    expect(mockFn()).toBe(10);  // First call
    expect(mockFn()).toBe(20);  // Second call
    expect(mockFn()).toBe(30);  // Third and subsequent calls
  });
});
```

## 2. Module Mocking with jest.mock()

### Automatic Mock
```javascript
// __mocks__/axios.js
export default {
  get: jest.fn(() => Promise.resolve({ data: {} })),
  post: jest.fn(() => Promise.resolve({ data: {} }))
};

// userService.test.js
import axios from 'axios';
import { UserService } from './userService';

jest.mock('axios');

describe('UserService', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch user data', async () => {
    const mockUser = { id: 1, name: 'John' };
    axios.get.mockResolvedValue({ data: mockUser });

    const user = await UserService.getUser(1);

    expect(axios.get).toHaveBeenCalledWith('/api/users/1');
    expect(user).toEqual(mockUser);
  });

  it('should handle API errors', async () => {
    axios.get.mockRejectedValue(new Error('Network error'));

    await expect(UserService.getUser(1)).rejects.toThrow('Network error');
  });
});
```

### Manual Mock
```javascript
jest.mock('./database', () => ({
  query: jest.fn(),
  connect: jest.fn(),
  disconnect: jest.fn()
}));

import { database } from './database';
import { UserRepository } from './userRepository';

describe('UserRepository', () => {
  it('should query database for users', async () => {
    database.query.mockResolvedValue([
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' }
    ]);

    const users = await UserRepository.findAll();

    expect(database.query).toHaveBeenCalledWith('SELECT * FROM users');
    expect(users).toHaveLength(2);
  });
});
```

## 3. Partial Module Mocking

Mock only specific exports from a module.

```javascript
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),  // Keep actual implementations
  formatDate: jest.fn()  // Mock only this function
}));

import { formatDate, calculateAge } from './utils';

describe('User display', () => {
  it('should use mocked formatDate but actual calculateAge', () => {
    formatDate.mockReturnValue('2025-01-01');

    const user = { birthDate: '1990-01-01' };
    const formatted = formatDate(user.birthDate);
    const age = calculateAge(user.birthDate);  // Uses actual implementation

    expect(formatted).toBe('2025-01-01');
    expect(age).toBeGreaterThan(30);
  });
});
```

## 4. Mocking Classes

```javascript
// Mock entire class
jest.mock('./Logger');

import { Logger } from './Logger';
import { Service } from './Service';

describe('Service with mocked Logger', () => {
  it('should log operations', () => {
    const mockLogger = new Logger();
    mockLogger.info.mockImplementation((msg) => console.log(msg));

    const service = new Service(mockLogger);
    service.performAction();

    expect(mockLogger.info).toHaveBeenCalledWith('Action performed');
  });
});

// Manual class mock
jest.mock('./Database', () => {
  return jest.fn().mockImplementation(() => {
    return {
      connect: jest.fn(),
      query: jest.fn(),
      disconnect: jest.fn()
    };
  });
});
```

## 5. Spying on Existing Methods

Use jest.spyOn() to mock methods while keeping original implementation available.

```javascript
describe('User authentication', () => {
  it('should call validation method', () => {
    const user = new User();
    const validateSpy = jest.spyOn(user, 'validate');

    user.login('username', 'password');

    expect(validateSpy).toHaveBeenCalled();
    validateSpy.mockRestore();  // Restore original implementation
  });

  it('should mock return value of spied method', () => {
    const user = new User();
    const validateSpy = jest.spyOn(user, 'validate')
      .mockReturnValue(true);

    const result = user.login('username', 'wrong-password');

    expect(result).toBe(true);  // Validation bypassed
    validateSpy.mockRestore();
  });
});
```

## 6. Mocking Timers

### Fast-Forward Time
```javascript
describe('Debounce function', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should delay execution', () => {
    const callback = jest.fn();
    const debounced = debounce(callback, 1000);

    debounced();
    expect(callback).not.toHaveBeenCalled();

    jest.advanceTimersByTime(500);
    expect(callback).not.toHaveBeenCalled();

    jest.advanceTimersByTime(500);
    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('should run all timers', () => {
    const callback = jest.fn();
    setTimeout(callback, 1000);

    jest.runAllTimers();

    expect(callback).toHaveBeenCalled();
  });
});
```

## 7. Mocking Date/Time

```javascript
describe('Time-dependent logic', () => {
  beforeAll(() => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2025-01-01'));
  });

  afterAll(() => {
    jest.useRealTimers();
  });

  it('should check if user is adult', () => {
    const user = { birthDate: '2000-01-01' };

    expect(isAdult(user)).toBe(true);  // Age is 25 in 2025
  });
});
```

## 8. Mocking Async/Promises

```javascript
describe('Async operations', () => {
  it('should mock resolved promise', async () => {
    const mockFetch = jest.fn().mockResolvedValue({ data: 'success' });

    const result = await mockFetch();

    expect(result.data).toBe('success');
  });

  it('should mock rejected promise', async () => {
    const mockFetch = jest.fn().mockRejectedValue(new Error('Failed'));

    await expect(mockFetch()).rejects.toThrow('Failed');
  });

  it('should mock async implementation', async () => {
    const mockFetch = jest.fn().mockImplementation(async (id) => {
      if (id === 1) return { data: 'user1' };
      throw new Error('Not found');
    });

    await expect(mockFetch(1)).resolves.toEqual({ data: 'user1' });
    await expect(mockFetch(2)).rejects.toThrow('Not found');
  });
});
```

## 9. Mocking External Dependencies (Database, API, File System)

### Database Mock
```javascript
const mockDb = {
  users: [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' }
  ],
  findById: jest.fn((id) => {
    return mockDb.users.find(u => u.id === id);
  }),
  create: jest.fn((user) => {
    const newUser = { id: mockDb.users.length + 1, ...user };
    mockDb.users.push(newUser);
    return newUser;
  })
};

jest.mock('./database', () => mockDb);
```

### File System Mock
```javascript
jest.mock('fs', () => ({
  readFileSync: jest.fn(() => 'file contents'),
  writeFileSync: jest.fn(),
  existsSync: jest.fn(() => true)
}));

import fs from 'fs';

describe('File operations', () => {
  it('should read file', () => {
    const content = fs.readFileSync('/path/to/file.txt', 'utf8');

    expect(content).toBe('file contents');
    expect(fs.readFileSync).toHaveBeenCalledWith('/path/to/file.txt', 'utf8');
  });
});
```

## 10. Mock Return Values Based on Arguments

```javascript
describe('Conditional mocking', () => {
  it('should return different values based on input', () => {
    const mockFn = jest.fn((x) => {
      if (x > 10) return 'high';
      if (x > 5) return 'medium';
      return 'low';
    });

    expect(mockFn(15)).toBe('high');
    expect(mockFn(7)).toBe('medium');
    expect(mockFn(3)).toBe('low');
  });

  it('should use mockImplementation for complex logic', () => {
    const mockCalculator = {
      calculate: jest.fn()
    };

    mockCalculator.calculate.mockImplementation((operation, a, b) => {
      switch (operation) {
        case 'add': return a + b;
        case 'subtract': return a - b;
        case 'multiply': return a * b;
        default: throw new Error('Unknown operation');
      }
    });

    expect(mockCalculator.calculate('add', 5, 3)).toBe(8);
    expect(mockCalculator.calculate('multiply', 5, 3)).toBe(15);
  });
});
```

## Mock Cleanup

Always clean up mocks to prevent test interference:

```javascript
describe('Test suite', () => {
  afterEach(() => {
    jest.clearAllMocks();      // Clear call history
    // jest.resetAllMocks();   // Clear call history + reset implementation
    // jest.restoreAllMocks(); // Restore original implementation (for spies)
  });
});
```

## Best Practices

1. **Clear mocks between tests** to avoid state leakage
2. **Mock at the right level** - mock external dependencies, not internal logic
3. **Use descriptive mock names** - `mockUserService` not `mock1`
4. **Verify mock calls** - check arguments, call count
5. **Restore spies** after use with `mockRestore()`
6. **Avoid over-mocking** - test real integrations when possible
7. **Use manual mocks for complex dependencies** - create `__mocks__/` directory
