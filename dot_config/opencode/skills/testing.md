---
description: Test writing strategies, patterns, and best practices across multiple languages
---

# Testing Skill

## Test Types

| Type | Scope | Speed | Purpose |
|------|-------|-------|---------|
| Unit | Function/method | Fast | Logic correctness |
| Integration | Module/API | Medium | Component interaction |
| E2E | Full flow | Slow | User scenarios |
| Property | Input/output invariants | Medium | Correctness classes |
| Contract | Service boundaries | Medium | API compatibility |
| Snapshot | Rendered output | Fast | Detect unintended changes |
| Benchmark | Performance | Varies | Regression detection |

## Test Structure (AAA Pattern)

### TypeScript / Jest

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => {
      // Arrange
      const input = { name: 'John', email: 'john@example.com' }

      // Act
      const result = userService.createUser(input)

      // Assert
      expect(result).toMatchObject({
        id: expect.any(String),
        name: 'John',
        email: 'john@example.com'
      })
    })
  })
})
```

### Python / pytest

```python
# tests/test_user_service.py
import pytest
from myapp.service import UserService, UserNotFoundError

class TestCreateUser:
    """Tests for UserService.createUser."""

    def test_creates_user_with_valid_data(self):
        # Arrange
        service = UserService(db=mock_db)
        payload = {"name": "John", "email": "john@example.com"}

        # Act
        result = service.create_user(payload)

        # Assert
        assert result.id is not None
        assert result.name == "John"
        assert result.email == "john@example.com"

    def test_raises_error_for_duplicate_email(self):
        # Arrange
        service = UserService(db=mock_db)
        mock_db.get_user_by_email.return_value = existing_user

        # Act & Assert
        with pytest.raises(UserNotFoundError):
            service.create_user({"name": "Jane", "email": "john@example.com"})

    @pytest.mark.parametrize("email", [
        "not-an-email",
        "@missing-local.com",
        "no-at-sign.com",
    ])
    def test_rejects_invalid_email(self, email):
        service = UserService(db=mock_db)
        with pytest.raises(ValidationError):
            service.create_user({"name": "Test", "email": email})
```

### Go / testing

```go
// user_service_test.go
package service_test

import (
    "testing"

    "myapp/service"
    "myapp/service/mocks"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

func TestCreateUser_ValidData(t *testing.T) {
    // Arrange
    mockDB := mocks.NewMockDB(t)
    svc := service.NewUserService(mockDB)

    mockDB.EXPECT().InsertUser(mock.Anything, mock.Anything).Return(nil)

    // Act
    user, err := svc.CreateUser(context.Background(), service.CreateUserInput{
        Name:  "John",
        Email: "john@example.com",
    })

    // Assert
    assert.NoError(t, err)
    assert.Equal(t, "John", user.Name)
    assert.Equal(t, "john@example.com", user.Email)
    assert.NotEmpty(t, user.ID)
}

func TestCreateUser_DuplicateEmail(t *testing.T) {
    mockDB := mocks.NewMockDB(t)
    svc := service.NewUserService(mockDB)

    mockDB.EXPECT().GetUserByEmail(mock.Anything, "john@example.com").
        Return(&service.User{ID: "1"}, nil)

    _, err := svc.CreateUser(context.Background(), service.CreateUserInput{
        Name:  "Jane",
        Email: "john@example.com",
    })

    assert.ErrorIs(t, err, service.ErrDuplicateEmail)
}
```

## Naming Conventions

```
describe('methodName')
  └── it('should [expected behavior] when [condition]')
```

Examples:
- `it('should return null when user not found')`
- `it('should throw error when email is invalid')`
- `it('should calculate total with discount applied')`

Python (pytest): `test_<verb>_<noun>_<condition>` — e.g., `test_create_user_with_valid_data`, `test_raises_error_for_duplicate_email`

Go: `Test<Function>_<Scenario>` — e.g., `TestCreateUser_ValidData`, `TestCreateUser_DuplicateEmail`

## Test Coverage Goals

| Coverage Type | Target |
|---------------|--------|
| Statements | 80%+ |
| Branches | 75%+ |
| Functions | 90%+ |
| Lines | 80%+ |

## Test Doubles Taxonomy

| Double | Behavior | Use When |
|--------|----------|----------|
| **Stub** | Returns canned responses | Isolating the unit under test from a dependency |
| **Mock** | Verifies interactions (calls, args, order) | Checking that a collaborator was called correctly |
| **Fake** | Working but simplified implementation | In-memory database, fake clock |
| **Spy** | Records calls but delegates to real implementation | Wrapping a real service to assert on usage |
| **Dummy** | Passed around but never actually used | Filling required constructor parameters |

### Stub Examples

```python
# Python stub
class StubPaymentGateway:
    def charge(self, amount):
        return {"status": "ok", "transaction_id": "stub-123"}
```

```go
// Go stub
type StubEmailSender struct{}

func (s *StubEmailSender) Send(to, subject, body string) error {
    return nil // always succeeds
}
```

### Mock Examples

```typescript
// TypeScript/Jest mock
const mockRepo = {
  findById: jest.fn().mockResolvedValue({ id: '1', name: 'Test' }),
  save: jest.fn().mockResolvedValue({ id: '2', name: 'New' }),
}

userService.updateUser('1', { name: 'Updated' })

expect(mockRepo.save).toHaveBeenCalledWith(
  expect.objectContaining({ name: 'Updated' })
)
```

```python
# Python mock (unittest.mock)
from unittest.mock import MagicMock, call

mock_repo = MagicMock()
mock_repo.find_by_id.return_value = User(id='1', name='Test')

service.update_user('1', {'name': 'Updated'})

mock_repo.save.assert_called_once_with(
    User(id='1', name='Updated')
)
```

### Fake Examples

```python
# Python fake: in-memory repository
class FakeUserRepository:
    def __init__(self):
        self._users = {}

    def save(self, user):
        self._users[user.id] = user
        return user

    def find_by_id(self, user_id):
        return self._users.get(user_id)

    def find_by_email(self, email):
        for u in self._users.values():
            if u.email == email:
                return u
        return None
```

```go
// Go fake: in-memory store
type FakeUserStore struct {
    users map[string]*service.User
}

func NewFakeUserStore() *FakeUserStore {
    return &FakeUserStore{users: make(map[string]*service.User)}
}

func (f *FakeUserStore) Save(ctx context.Context, u *service.User) error {
    f.users[u.ID] = u
    return nil
}

func (f *FakeUserStore) GetByID(ctx context.Context, id string) (*service.User, error) {
    u, ok := f.users[id]
    if !ok {
        return nil, service.ErrNotFound
    }
    return u, nil
}
```

## Mocking Patterns

### TypeScript / Jest

```typescript
// Function mock
jest.fn().mockReturnValue('value')
jest.fn().mockResolvedValue('async value')

// Module mock
jest.mock('./api', () => ({
  fetchData: jest.fn()
}))

// Spy
jest.spyOn(console, 'log').mockImplementation()

// Partial mock with implementation
jest.spyOn(service, 'calculate').mockImplementation((a, b) => a + b)

// Reset between tests
afterEach(() => jest.clearAllMocks())
```

### Python / pytest + unittest.mock

```python
from unittest.mock import patch, MagicMock

# Patch a dependency
@patch('myapp.service.requests.get')
def test_fetches_data(mock_get):
    mock_get.return_value.json.return_value = {"key": "value"}
    result = service.fetch_data("https://api.example.com")
    assert result == {"key": "value"}
    mock_get.assert_called_once_with("https://api.example.com")

# Patch as context manager
def test_with_context_manager():
    with patch('myapp.service.requests.get') as mock_get:
        mock_get.return_value.status_code = 200
        service.check_endpoint()
```

### Go / testify mocks

```go
// Using testify/mock code generation
type MockDB struct {
    mock.Mock
}

func (m *MockDB) GetUser(ctx context.Context, id string) (*User, error) {
    args := m.Called(ctx, id)
    if u := args.Get(0); u != nil {
        return u.(*User), args.Error(1)
    }
    return nil, args.Error(1)
}

// In test
mockDB := new(MockDB)
mockDB.On("GetUser", mock.Anything, "123").Return(&User{ID: "123"}, nil)
mockDB.On("GetUser", mock.Anything, "missing").Return(nil, ErrNotFound)
```

## Snapshot Testing

### TypeScript / Jest

```typescript
// Component snapshot
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const tree = renderer
    .create(<UserProfile user={{ name: 'John', role: 'admin' }} />)
    .toJSON()
  expect(tree).toMatchSnapshot()
})

// Inline snapshot (auto-updates on first run)
it('formats user data', () => {
  expect(formatUser({ name: 'John', email: 'john@example.com' }))
    .toMatchInlineSnapshot(`
    "John <john@example.com> [admin]"
  `)
})
```

### Python / syrupy

```python
# pip install syrupy
@pytest.mark.snapshot
def test_serialized_output(snapshot):
    result = serialize_config({"debug": True, "port": 8080})
    assert result == snapshot
```

## E2E Testing

### Playwright (TypeScript)

```typescript
// tests/e2e/login.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login')
  })

  test('successful login redirects to dashboard', async ({ page }) => {
    await page.fill('[data-testid="email"]', 'user@example.com')
    await page.fill('[data-testid="password"]', 'password123')
    await page.click('[data-testid="login-btn"]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('h1')).toHaveText('Welcome back')
  })

  test('shows error for invalid credentials', async ({ page }) => {
    await page.fill('[data-testid="email"]', 'user@example.com')
    await page.fill('[data-testid="password"]', 'wrong-password')
    await page.click('[data-testid="login-btn"]')

    await expect(page.locator('[data-testid="error"]')).toBeVisible()
    await expect(page.locator('[data-testid="error"]')).toHaveText(
      /invalid credentials/i
    )
  })
})
```

### Cypress (TypeScript)

```typescript
// cypress/e2e/login.cy.ts
describe('Login Flow', () => {
  beforeEach(() => {
    cy.visit('/login')
  })

  it('successful login', () => {
    cy.get('[data-testid="email"]').type('user@example.com')
    cy.get('[data-testid="password"]').type('password123')
    cy.get('[data-testid="login-btn"]').click()

    cy.url().should('include', '/dashboard')
    cy.get('h1').should('contain', 'Welcome back')
  })

  it('invalid credentials shows error', () => {
    cy.get('[data-testid="email"]').type('user@example.com')
    cy.get('[data-testid="password"]').type('wrong')
    cy.get('[data-testid="login-btn"]').click()

    cy.get('[data-testid="error"]')
      .should('be.visible')
      .and('contain', 'invalid credentials')
  })
})
```

### Python / pytest + httpx (API E2E)

```python
import pytest
import httpx

@pytest.fixture
def api_client():
    return httpx.Client(base_url="http://localhost:8080/api/v1")

class TestUserAPI:
    def test_create_and_get_user(self, api_client):
        # Create user
        resp = api_client.post("/users", json={
            "name": "John",
            "email": "john@example.com"
        })
        assert resp.status_code == 201
        user_id = resp.json()["id"]

        # Fetch user
        resp = api_client.get(f"/users/{user_id}")
        assert resp.status_code == 200
        assert resp.json()["name"] == "John"
```

## Contract Testing

### Pact (TypeScript / Python)

```typescript
// Consumer test (TypeScript)
import { Pact } from '@pact-foundation/pact'

const provider = new Pact({
  consumer: 'UserService',
  provider: 'UserAPI',
})

describe('UserService <-> UserAPI contract', () => {
  beforeAll(() => provider.setup())

  it('returns user by ID', async () => {
    await provider.addInteraction({
      state: 'user 123 exists',
      uponReceiving: 'a request for user 123',
      withRequest: { method: 'GET', path: '/api/users/123' },
      willRespondWith: {
        status: 200,
        body: { id: '123', name: 'John', email: 'john@example.com' },
      },
    })

    const user = await userService.getUser('123')
    expect(user.name).toBe('John')
  })

  afterAll(() => provider.verify())
  afterEach(() => provider.finalize())
})
```

## Test Data Factories

### TypeScript

```typescript
// factories/user.ts
import { faker } from '@faker-js/faker'

export function createUser(overrides?: Partial<User>): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    role: 'user',
    createdAt: new Date(),
    ...overrides,
  }
}

export function createAdmin(overrides?: Partial<User>): User {
  return createUser({ role: 'admin', ...overrides })
}

// Usage in tests
it('promotes user to admin', () => {
  const user = createUser({ name: 'Jane' })
  const result = promoteToAdmin(user)
  expect(result.role).toBe('admin')
  expect(result.name).toBe('Jane') // preserves other fields
})
```

### Python

```python
# factories.py
import factory

class UserFactory(factory.Factory):
    class Meta:
        model = User

    id = factory.Faker('uuid4')
    name = factory.Faker('name')
    email = factory.Faker('email')
    role = 'user'

class AdminFactory(UserFactory):
    role = 'admin'

# Usage in tests
def test_promotes_user():
    user = UserFactory(name='Jane')
    result = promote_to_admin(user)
    assert result.role == 'admin'
    assert result.name == 'Jane'
```

### Go

```go
// factories_test.go
package testutil

import (
    "github.com/google/uuid"
    "myapp/service"
)

type UserBuilder struct {
    user service.User
}

func NewUserBuilder() *UserBuilder {
    return &UserBuilder{
        user: service.User{
            ID:    uuid.New().String(),
            Name:  "Test User",
            Email: "test@example.com",
            Role:  "user",
        },
    }
}

func (b *UserBuilder) WithName(name string) *UserBuilder {
    b.user.Name = name
    return b
}

func (b *UserBuilder) WithEmail(email string) *UserBuilder {
    b.user.Email = email
    return b
}

func (b *UserBuilder) AsAdmin() *UserBuilder {
    b.user.Role = "admin"
    return b
}

func (b *UserBuilder) Build() service.User {
    return b.user
}

// Usage
user := NewUserBuilder().WithName("Jane").AsAdmin().Build()
```

## Running Tests

### TypeScript / Jest

```bash
# Run all tests
npx jest

# Run with coverage
npx jest --coverage

# Run specific file
npx jest src/user.service.test.ts

# Watch mode
npx jest --watch

# Update snapshots
npx jest --updateSnapshot
```

### Python / pytest

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific file
pytest tests/test_user_service.py

# Run by marker
pytest -m "integration"

# Run with coverage
pytest --cov=myapp --cov-report=html

# Run with output (don't capture stdout)
pytest -s

# Run only last failures
pytest --lf
```

### Go

```bash
# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run specific package
go test ./service/...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run benchmarks
go test -bench=. ./...

# Run with race detector
go test -race ./...
```

## Best Practices

- One assertion per test (when practical)
- Test edge cases: null, undefined, empty, max
- Don't test implementation details
- Use descriptive test names
- Keep tests independent
- Avoid shared state between tests
- Use factories/builders instead of hardcoded test data
- Prefer fakes over mocks when the fake is simple to implement
- Test the behavior, not the implementation
- Use parametrized tests for input validation and boundary conditions
- Reset mocks between tests
- Run tests in CI with coverage gates
- Keep tests fast — move slow I/O tests to integration/e2e suites
