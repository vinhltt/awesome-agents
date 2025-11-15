# Pytest Test Templates

## Basic Test Structure

```python
# test_calculator.py
import pytest
from calculator import Calculator

class TestCalculator:
    @pytest.fixture
    def calculator(self):
        """Setup: Create calculator instance before each test"""
        return Calculator()

    def test_add_positive_numbers(self, calculator):
        """Test adding two positive numbers"""
        result = calculator.add(5, 3)
        assert result == 8

    def test_add_negative_numbers(self, calculator):
        assert calculator.add(-5, -3) == -8

    def test_divide_by_zero_raises_error(self, calculator):
        with pytest.raises(ZeroDivisionError):
            calculator.divide(10, 0)

    def test_divide_with_decimals(self, calculator):
        result = calculator.divide(10, 3)
        assert abs(result - 3.333) < 0.001  # Floating point comparison
```

## Fixtures

```python
@pytest.fixture
def user_data():
    """Fixture providing test data"""
    return {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30
    }

@pytest.fixture
def database_connection():
    """Setup and teardown fixture"""
    # Setup
    conn = Database.connect()
    yield conn
    # Teardown
    conn.close()

def test_create_user(database_connection, user_data):
    user = User.create(database_connection, user_data)
    assert user.name == 'John Doe'
```

## Parametrized Tests

```python
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 6),
    (0, 5, 0),
    (-2, 3, -6),
    (-2, -3, 6),
])
def test_multiply(calculator, a, b, expected):
    assert calculator.multiply(a, b) == expected

@pytest.mark.parametrize("email,valid", [
    ("test@example.com", True),
    ("user+tag@example.com", True),
    ("invalid@", False),
    ("@example.com", False),
])
def test_email_validation(email, valid):
    assert EmailValidator.is_valid(email) == valid
```

## Mocking with pytest-mock

```python
def test_api_call(mocker):
    """Mock external API call"""
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.json.return_value = {'id': 1, 'name': 'John'}

    user = UserService.get_user(1)

    assert user['name'] == 'John'
    mock_get.assert_called_once_with('/api/users/1')

def test_database_query(mocker):
    """Mock database query"""
    mock_db = mocker.patch('app.database.query')
    mock_db.return_value = [{'id': 1, 'name': 'Alice'}]

    users = UserRepository.find_all()

    assert len(users) == 1
    assert users[0]['name'] == 'Alice'
```

## Async Testing

```python
import pytest

@pytest.mark.asyncio
async def test_async_fetch():
    """Test async function"""
    data = await fetch_data()
    assert data is not None

@pytest.mark.asyncio
async def test_async_error():
    """Test async error handling"""
    with pytest.raises(ValueError):
        await failing_async_function()
```

## Test Organization

```python
class TestUserAuthentication:
    """Group related tests in a class"""

    @pytest.fixture(autouse=True)
    def setup(self):
        """Runs before each test in this class"""
        self.auth_service = AuthService()

    def test_login_success(self):
        result = self.auth_service.login('user', 'password')
        assert result.success is True

    def test_login_failure(self):
        result = self.auth_service.login('user', 'wrong')
        assert result.success is False

    def test_logout(self):
        self.auth_service.login('user', 'password')
        result = self.auth_service.logout()
        assert result.success is True
```

## Markers

```python
@pytest.mark.slow
def test_slow_operation():
    """Mark slow tests"""
    pass

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_specific():
    pass
```

## Assertions

```python
# Equality
assert value == 5
assert value != 3

# Truthiness
assert value
assert not value
assert value is None
assert value is not None

# Membership
assert item in collection
assert item not in collection

# Exceptions
with pytest.raises(ValueError):
    function_that_raises()

with pytest.raises(ValueError, match="Invalid input"):
    function_that_raises()

# Approximate equality (floating point)
assert abs(value - 3.333) < 0.001
# Or use pytest.approx
assert value == pytest.approx(3.333, abs=0.001)
```

## File Naming

- Test files: `test_*.py` or `*_test.py`
- Test functions: `test_*`
- Test classes: `Test*`
