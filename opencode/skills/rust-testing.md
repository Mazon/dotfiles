---
description: Rust testing strategies including unit tests, integration tests, mocking, benchmarks, and property-based testing
---

# Rust Testing Skill

## Unit Tests

### Basic Unit Tests

```rust
// Inline in src/lib.rs or src/*.rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_addition() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    fn test_subtraction() {
        assert_eq!(subtract(5, 3), 2);
    }
}

fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn subtract(a: i32, b: i32) -> i32 {
    a - b
}
```

### Test Organization

```rust
// tests/integration_test.rs - Separate file
use my_crate::add;

#[test]
fn test_integration() {
    assert_eq!(add(10, 20), 30);
}

// tests/common/mod.rs - Shared test utilities
pub fn setup_test_data() -> Vec<i32> {
    vec![1, 2, 3, 4, 5]
}
```

### Running Tests

```bash
# Run all tests
cargo test

# Run specific test
cargo test test_addition

# Run tests in specific module
cargo test tests::module_name

# Run with output
cargo test -- --nocapture

# Run with logging
RUST_LOG=debug cargo test

# Run in parallel (default)
cargo test

# Run sequentially
cargo test -- --test-threads=1

# Run with filters
cargo test test_name
cargo test mod::test_name
```

### Test Attributes

```rust
#[test]
fn test_basic() {
    // Basic test
}

#[test]
#[ignore]
fn test_slow() {
    // Skipped unless --ignored is used
}

#[test]
#[should_panic]
fn test_panics() {
    panic!("Expected panic");
}

#[test]
#[should_panic(expected = "Expected message")]
fn test_panic_with_message() {
    panic!("Expected message");
}

#[test]
#[ignore = "Reason for ignoring"]
fn test_with_reason() {
    // Test is ignored with explanation
}
```

### Test Fixtures

```rust
struct TestFixture {
    data: Vec<i32>,
}

impl TestFixture {
    fn new() -> Self {
        TestFixture {
            data: vec![1, 2, 3, 4, 5],
        }
    }

    fn reset(&mut self) {
        self.data = vec![1, 2, 3, 4, 5];
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_fixture() {
        let mut fixture = TestFixture::new();
        assert_eq!(fixture.data.len(), 5);

        // Modify
        fixture.data.push(6);
        assert_eq!(fixture.data.len(), 6);

        // Reset
        fixture.reset();
        assert_eq!(fixture.data.len(), 5);
    }
}
```

## Integration Tests

### Basic Integration Tests

```rust
// tests/integration_test.rs
use my_app::App;

#[test]
fn test_full_flow() {
    let mut app = App::new();
    app.add_item("item1");
    app.add_item("item2");

    assert_eq!(app.item_count(), 2);
}
```

### Integration Test Setup

```rust
// tests/common/mod.rs
use my_app::App;

pub fn create_test_app() -> App {
    App::with_config(AppConfig {
        port: 0, // Use random port for tests
        timeout: 1000,
    })
}

pub fn cleanup_database() {
    // Cleanup after tests
}

// tests/integration_test.rs
mod common;

#[test]
fn test_with_setup() {
    let app = common::create_test_app();
    // Test code
}
```

### HTTP Integration Tests

```rust
use reqwest::Client;

#[tokio::test]
async fn test_api_endpoint() {
    let client = Client::new();
    let response = client
        .get("http://localhost:8080/api/health")
        .send()
        .await
        .unwrap();

    assert_eq!(response.status(), reqwest::StatusCode::OK);

    let body: serde_json::Value = response.json().await.unwrap();
    assert_eq!(body["status"], "ok");
}
```

### Database Integration Tests

```rust
use sqlx::SqlitePool;

#[tokio::test]
async fn test_database_operations() {
    // Use in-memory database for tests
    let pool = SqlitePool::connect(":memory:").await.unwrap();

    // Run migrations
    sqlx::query("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        .execute(&pool)
        .await
        .unwrap();

    // Insert test data
    sqlx::query("INSERT INTO users (name) VALUES (?)")
        .bind("Alice")
        .execute(&pool)
        .await
        .unwrap();

    // Query and verify
    let result: (String,) = sqlx::query_as("SELECT name FROM users WHERE id = 1")
        .fetch_one(&pool)
        .await
        .unwrap();

    assert_eq!(result.0, "Alice");
}
```

## Mocking with Mockall

### Basic Mocking

```rust
// Add to Cargo.toml:
// [dev-dependencies]
// mockall = "0.12"

use mockall::{mock, predicate::*};

// Define trait to mock
#[automock]
trait UserService {
    fn get_user(&self, id: u32) -> Option<User>;
    fn create_user(&self, name: &str) -> Result<User, Error>;
}

struct User {
    id: u32,
    name: String,
}

// Test with mock
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;

    #[test]
    fn test_with_mock() {
        let mut mock = MockUserService::new();

        // Setup expectations
        mock.expect_get_user()
            .with(eq(1))
            .returning(|_| Some(User { id: 1, name: "Alice".into() }));

        mock.expect_create_user()
            .with(eq("Bob"))
            .returning(|name| Ok(User { id: 2, name: name.into() }));

        // Use mock
        assert!(mock.get_user(1).is_some());
        assert!(mock.create_user("Bob").is_ok());
    }
}
```

### Mock Struct Methods

```rust
#[automock]
struct Calculator {
    add: fn(i32, i32) -> i32,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculator_mock() {
        let mut mock = MockCalculator::new();
        mock.expect_add()
            .with(eq(2), eq(3))
            .return_const(5);

        assert_eq!(mock.add(2, 3), 5);
    }
}
```

### Sequence of Calls

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sequence() {
        let mut mock = MockUserService::new();

        mock.expect_get_user()
            .times(2)
            .with(eq(1))
            .returning(|_| Some(User { id: 1, name: "Alice".into() }));

        // First call
        let user = mock.get_user(1);
        assert!(user.is_some());

        // Second call
        let user = mock.get_user(1);
        assert!(user.is_some());
    }
}
```

### Mock Async Methods

```rust
#[automock]
#[async_trait::async_trait]
trait AsyncService {
    async fn fetch_data(&self, id: u32) -> Result<String>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_async_mock() {
        let mut mock = MockAsyncService::new();

        mock.expect_fetch_data()
            .with(eq(1))
            .returning(|_| Ok("Data".to_string()));

        let result = mock.fetch_data(1).await.unwrap();
        assert_eq!(result, "Data");
    }
}
```

## Property-Based Testing with Proptest

### Basic Property Tests

```rust
// Add to Cargo.toml:
// [dev-dependencies]
// proptest = "1.4"

use proptest::prelude::*;

proptest! {
    #[test]
    fn test_addition_commutative(a in 0..100i32, b in 0..100i32) {
        assert_eq!(a + b, b + a);
    }

    #[test]
    fn test_multiplication_distributive(a in 0..100i32, b in 0..100i32, c in 0..100i32) {
        assert_eq!(a * (b + c), a * b + a * c);
    }
}
```

### Strategy Definitions

```rust
// Custom strategy
fn email_strategy() -> impl Strategy<Value = String> {
    prop::string::string_regex("[a-z]+@[a-z]+\\.[a-z]+").unwrap()
}

proptest! {
    #[test]
    fn test_email_validation(email in email_strategy()) {
        assert!(is_valid_email(&email));
    }

    #[test]
    fn test_vector_operations(vec in prop::collection::vec(0..100i32, 0..10)) {
        let sum: i32 = vec.iter().sum();
        assert!(sum >= 0);
    }
}
```

### Complex Strategies

```rust
use proptest::collection::hash_map;

proptest! {
    #[test]
    fn test_hashmap_operations(
        map in hash_map(".*", 0..100i32, 0..10)
    ) {
        let sum: i32 = map.values().sum();
        assert!(sum >= 0);
    }

    #[test]
    fn test_with_struct(
        config in any::<MyConfig>()
    ) {
        let result = process_config(&config);
        assert!(result.is_ok());
    }
}
```

### Shrinking

```rust
proptest! {
    #[test]
    fn test_finds_counterexample(n in 0..1000u32) {
        // Proptest will find minimal failing case
        assert!(n != 42); // Will find 42
    }
}

// Running: cargo test
// Finds counterexample: n=42
// Minimal failing case: n=42
```

## Benchmarking with Criterion

### Basic Benchmarks

```rust
// Add to Cargo.toml:
// [dev-dependencies]
// criterion = "0.5"

use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| b.iter(|| fibonacci(black_box(20))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

### Running Benchmarks

```bash
# Run benchmarks
cargo bench

# Run specific benchmark
cargo bench fibonacci

# Save baseline
cargo bench -- --save-baseline main

# Compare with baseline
cargo bench -- --baseline main

# Generate plots
cargo bench -- --plotting-backend plotters
```

### Benchmark Groups

```rust
fn criterion_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("algorithms");

    group.bench_function("fib_recursive", |b| {
        b.iter(|| fibonacci(black_box(20)))
    });

    group.bench_function("fib_iterative", |b| {
        b.iter(|| fibonacci_iterative(black_box(20)))
    });

    group.finish();
}
```

### Benchmark Comparisons

```rust
fn compare_benchmarks(c: &mut Criterion) {
    let baseline = fibonacci(black_box(20));

    c.bench_with_input(
        BenchmarkId::new("baseline", 20),
        &baseline,
        |b, _| b.iter(|| fibonacci(black_box(20))),
    );
}
```

## Test Coverage

### Using tarpaulin

```bash
# Install
cargo install cargo-tarpaulin

# Generate coverage report
cargo tarpaulin --out Html

# Generate line coverage
cargo tarpaulin --line

# Generate for specific tests
cargo tarpaulin --tests integration

# Exclude modules
cargo tarpaulin --exclude-files '*_test.rs'
```

### Using grcov

```bash
# Install
cargo install grcov

# Run tests with instrumentation
cargo +nightly test

# Generate coverage report
grcov target/debug -t html -o coverage/
```

## Async Testing

### Tokio Test Macro

```rust
#[tokio::test]
async fn test_async_function() {
    let result = async_operation().await;
    assert_eq!(result, "expected");
}

#[tokio::test(flavor = "multi_thread")]
async fn test_multi_threaded() {
    // Test with multi-threaded runtime
}

#[tokio::test(start_paused = true)]
async fn test_time_travel() {
    // Paused time for deterministic tests
    tokio::time::advance(Duration::from_secs(10)).await;
}
```

### Testing Async Channels

```rust
use tokio::sync::mpsc;

#[tokio::test]
async fn test_channel_communication() {
    let (tx, mut rx) = mpsc::channel(10);

    tokio::spawn(async move {
        tx.send("Hello".to_string()).await.unwrap();
    });

    let received = rx.recv().await.unwrap();
    assert_eq!(received, "Hello");
}
```

### Testing Async Streams

```rust
use futures::StreamExt;

#[tokio::test]
async fn test_async_stream() {
    let mut stream = async_stream::stream! {
        for i in 0..5 {
            yield i;
        }
    };

    let mut sum = 0;
    while let Some(value) = stream.next().await {
        sum += value;
    }

    assert_eq!(sum, 10);
}
```

## Test Utilities

### Custom Assertions

```rust
macro_rules! assert_approx_eq {
    ($a:expr, $b:expr, $epsilon:expr) => {
        let diff = ($a - $b).abs();
        assert!(
            diff < $epsilon,
            "Values differ by {}, which is greater than {}",
            diff,
            $epsilon
        );
    };
}

#[test]
fn test_float_comparison() {
    assert_approx_eq!(1.0, 1.000001, 0.0001);
}
```

### Test Helpers

```rust
pub struct TestContext {
    temp_dir: tempfile::TempDir,
}

impl TestContext {
    pub fn new() -> Self {
        TestContext {
            temp_dir: tempfile::tempdir().unwrap(),
        }
    }

    pub fn temp_path(&self) -> &Path {
        self.temp_dir.path()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_context() {
        let ctx = TestContext::new();
        let file_path = ctx.temp_path().join("test.txt");
        // Use file_path for testing
    }
}
```

## Testing Patterns

### State Testing

```rust
#[test]
fn test_state_transitions() {
    let mut machine = StateMachine::new();
    assert_eq!(machine.state(), State::Initial);

    machine.transition_to(State::Running);
    assert_eq!(machine.state(), State::Running);

    machine.transition_to(State::Stopped);
    assert_eq!(machine.state(), State::Stopped);
}
```

### Error Case Testing

```rust
#[test]
fn test_error_handling() {
    let result = operation_that_fails();

    assert!(result.is_err());
    match result {
        Err(MyError::InvalidInput(msg)) => {
            assert!(msg.contains("expected"));
        }
        _ => panic!("Expected InvalidInput error"),
    }
}
```

### Boundary Testing

```rust
#[test]
fn test_boundary_conditions() {
    // Test edge cases
    assert_eq!(process(0), 0);
    assert_eq!(process(1), 1);
    assert_eq!(process(u32::MAX), u32::MAX);
    assert_eq!(process(i32::MIN as u32), 0);
}
```

## Best Practices

### Test Organization

```rust
// Group related tests
#[cfg(test)]
mod tests {
    mod user_tests {
        use super::super::*;

        #[test]
        fn test_create_user() {
            // Test user creation
        }

        #[test]
        fn test_delete_user() {
            // Test user deletion
        }
    }

    mod auth_tests {
        use super::super::*;

        #[test]
        fn test_login() {
            // Test authentication
        }
    }
}
```

### Keep Tests Independent

```rust
// Bad: Tests depend on execution order
#[test]
fn test_step1() {
    shared_state.set_value(1);
}

#[test]
fn test_step2() {
    // Fails if test_step1 hasn't run
    assert_eq!(shared_state.get_value(), 1);
}

// Good: Each test is self-contained
#[test]
fn test_with_state() {
    let mut state = State::new();
    state.set_value(1);
    assert_eq!(state.get_value(), 1);
}
```

### Test Naming

```rust
// Use descriptive names
#[test]
fn test_returns_400_when_email_is_invalid() {
    // Clear description of what's being tested
}

#[test]
fn test_converts_string_to_lowercase() {
    // Good naming
}
```

### Use Test Doubles

```rust
// Use mocks/fakes to isolate units
#[test]
fn test_service_logic() {
    let mock_repo = MockRepository::new();
    let service = UserService::new(mock_repo);

    let result = service.create_user("test@example.com");
    assert!(result.is_ok());
}
```

## Continuous Integration

### GitHub Actions

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions-rust-lang/setup-rust-toolchain@v1
        with:
          toolchain: stable
      - run: cargo test --all-features
```

### Coverage Badge

```bash
# Generate coverage and upload
cargo tarpaulin --ciserver github --out Xml
bash <(curl -s https://codecov.io/bash)
```
