---
description: Rust best practices, patterns, and idioms for safe and efficient code
---

# Rust Skill

## Project Structure

### Standard Cargo Project Layout

```
my-project/
├── Cargo.toml              # Package metadata and dependencies
├── Cargo.lock              # Exact dependency versions (generated)
├── src/
│   ├── main.rs            # Binary entry point
│   └── lib.rs             # Library entry point (if library)
├── tests/
│   └── integration_test.rs # Integration tests
├── benches/               # Criterion benchmarks
└── examples/              # Example code
```

### Cargo.toml Essentials

```toml
[package]
name = "my-crate"
version = "0.1.0"
edition = "2021"
rust-version = "1.70"

[dependencies]
# Production dependencies
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
thiserror = "1.0"
anyhow = "1.0"

[dev-dependencies]
# Testing dependencies
mockall = "0.12"
proptest = "1.4"
criterion = "0.5"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1

[profile.dev]
opt-level = 0
```

## Error Handling Patterns

### Basic Result Types

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
enum AppError {
    NotFound(String),
    InvalidInput(String),
    DatabaseError(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::NotFound(msg) => write!(f, "Not found: {}", msg),
            AppError::InvalidInput(msg) => write!(f, "Invalid input: {}", msg),
            AppError::DatabaseError(msg) => write!(f, "Database error: {}", msg),
        }
    }
}

impl Error for AppError {}
```

### Using thiserror for Error Enums

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("Resource not found: {0}")]
    NotFound(String),

    #[error("Authentication failed: {0}")]
    Unauthorized(String),

    #[error("Database error: {source}")]
    DatabaseError {
        #[from]
        source: sqlx::Error,
    },

    #[error("Validation error: {field} - {message}")]
    ValidationError { field: String, message: String },
}

// Usage
fn get_user(id: u32) -> Result<User, ApiError> {
    // Returns ApiError automatically via From trait
    Ok(User { id })
}
```

### Using anyhow for Application Errors

```rust
use anyhow::{Context, Result, bail, anyhow};

pub fn process_config(path: &str) -> Result<String> {
    let content = std::fs::read_to_string(path)
        .context(format!("Failed to read config from {}", path))?;

    if content.is_empty() {
        bail!("Config file is empty");
    }

    parse_config(&content)
        .map_err(|e| anyhow!("Failed to parse config: {}", e))
}

pub fn parse_config(content: &str) -> Result<String> {
    // Implementation
    Ok(content.to_string())
}
```

### Error Conversion Chain

```rust
use std::convert::TryFrom;

#[derive(Debug)]
struct ParseError(String);

impl std::fmt::Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "Parse error: {}", self.0)
    }
}

impl std::error::Error for ParseError {}

// From trait for automatic conversion
impl From<std::num::ParseIntError> for ParseError {
    fn from(err: std::num::ParseIntError) -> Self {
        ParseError(err.to_string())
    }
}
```

## Common Rust Idioms

### Option and Result Chaining

```rust
// Optimal pattern matching
fn get_user_name(user_id: Option<u32>, users: &HashMap<u32, String>) -> Option<String> {
    user_id.and_then(|id| users.get(&id).cloned())
}

// Operator ? for early returns
fn load_user(id: u32) -> Result<User, MyError> {
    let data = fetch_data(id)?;          // Returns early if Err
    let user = parse_user(data)?;        // Returns early if Err
    Ok(user)
}

// map vs and_then
let opt_name: Option<String> = Some("Alice");
let length = opt_name.map(|s| s.len());           // Option<usize>
let opt_length = opt_name.and_then(|s| parse_len(s)); // Option<usize>
```

### Iterator Patterns

```rust
let numbers = vec![1, 2, 3, 4, 5];

// Chain operations
let sum: i32 = numbers.iter()
    .filter(|&x| x % 2 == 0)
    .map(|x| x * x)
    .sum();

// collect into different types
let evens: Vec<i32> = numbers.iter()
    .filter(|&x| x % 2 == 0)
    .copied()
    .collect();

let set: HashSet<i32> = numbers.iter().copied().collect();

// fold for custom aggregation
let product = numbers.iter().fold(1, |acc, &x| acc * x);

// find returns Option
let first_even = numbers.iter().find(|&&x| x % 2 == 0);
```

### Closures

```rust
// Capture by reference
let list = vec![1, 2, 3];
let sum = |x: i32| list.iter().sum::<i32>() + x;

// Capture by moving
let data = String::from("hello");
let consumer = move || println!("{}", data);

// Function traits
fn apply<F>(f: F, x: i32) -> i32
where
    F: Fn(i32) -> i32,
{
    f(x)
}

// FnMut for mutating closures
fn apply_mut<F>(mut f: F) -> i32
where
    F: FnMut() -> i32,
{
    f() + f()
}
```

### String Handling

```rust
// String ownership
let s1 = String::from("hello");
let s2 = s1;  // s1 is moved, no longer valid

// Clone explicitly
let s1 = String::from("hello");
let s2 = s1.clone();  // Both are valid

// String slices (&str)
let s: String = String::from("hello");
let slice: &str = &s;

// Prefer &str for function arguments
fn process(s: &str) {  // Accepts both String and &str
    println!("{}", s);
}
```

## Ownership and Borrowing

### Borrowing Rules

```rust
fn borrow_examples() {
    let mut x = 5;

    // Multiple immutable references
    let r1 = &x;
    let r2 = &x;
    println!("{} and {}", r1, r2);

    // Mutable reference (exclusivity)
    let r3 = &mut x;
    *r3 += 1;

    // Can't have both mutable and immutable simultaneously
    // let r4 = &x;       // Error!
    // let r5 = &mut x;   // Error!
}
```

### Lifetimes

```rust
// Explicit lifetime annotation
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Lifetime elision (common patterns)
fn first_word(s: &str) -> &str {
    // &'a str input, returns &'a str
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    &s[..]
}

// Struct with lifetime
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
}
```

### Move Semantics

```rust
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Self {
        Point { x, y }
    }
}

// Move by default
fn consume_point(p: Point) {
    println!("Consuming: {:?}", p);
}

// Borrow with & reference
fn display_point(p: &Point) {
    println!("Displaying: {:?}", p);
}

// Mutably borrow with &mut
fn move_point(p: &mut Point, dx: i32, dy: i32) {
    p.x += dx;
    p.y += dy;
}
```

## Memory Safety Patterns

### Zero-Copy with Slices

```rust
// Zero-copy parsing
fn parse_headers(data: &[u8]) -> Vec<(&str, &str)> {
    let mut headers = Vec::new();
    let text = std::str::from_utf8(data).unwrap();

    for line in text.lines() {
        if let Some((key, value)) = line.split_once(':') {
            headers.push((key.trim(), value.trim()));
        }
    }

    headers
}
```

### Arena Allocation

```rust
// Bump allocator for short-lived allocations
use bumpalo::Bump;

pub struct Arena<T> {
    allocator: Bump,
    _marker: std::marker::PhantomData<T>,
}

impl<T> Arena<T> {
    pub fn new() -> Self {
        Arena {
            allocator: Bump::new(),
            _marker: std::marker::PhantomData,
        }
    }

    pub fn alloc(&self, value: T) -> &T {
        self.allocator.alloc(value)
    }
}
```

### Smart Pointers

```rust
// Box for heap allocation
fn create_box() -> Box<[u8]> {
    let data = vec![0u8; 1024];
    data.into_boxed_slice()
}

// Rc for shared ownership
use std::rc::Rc;

fn shared_data() {
    let data = Rc::new(vec![1, 2, 3]);
    let data2 = Rc::clone(&data);
    println!("Strong count: {}", Rc::strong_count(&data)); // 2
}

// Arc for thread-safe shared ownership
use std::sync::Arc;

fn thread_safe_shared() {
    let data = Arc::new(vec![1, 2, 3]);
    let data2 = Arc::clone(&data);
    // Can send data2 to another thread
}
```

## Pattern Matching

```rust
// Exhaustive matching
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn process_message(msg: Message) {
    match msg {
        Message::Quit => println!("Quit"),
        Message::Move { x, y } => println!("Move to {}, {}", x, y),
        Message::Write(text) => println!("Write: {}", text),
        Message::ChangeColor(r, g, b) => println!("RGB: {}, {}, {}", r, g, b),
    }
}

// Match guards
fn classify(num: i32) -> String {
    match num {
        n if n < 0 => "negative".to_string(),
        n if n == 0 => "zero".to_string(),
        n if n % 2 == 0 => "even".to_string(),
        _ => "odd".to_string(),
    }
}

// @ binding
struct Point { x: i32, y: i32 }

fn print_point(point: Point) {
    match point {
        Point { x: x @ 0..=10, y } => println!("x in range 0-10: {}, y: {}", x, y),
        Point { x, y: y @ 0..=10 } => println!("x: {}, y in range 0-10: {}", x, y),
        _ => println!("Point outside range"),
    }
}
```

## Common Traits

### Derivable Traits

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct User {
    id: u32,
    name: String,  // Note: Clone requires String to implement Clone
}

// Debug for {:?} formatting
// Clone for explicit cloning
// Copy for implicit copying (no ownership transfer)
// PartialEq for == operator
// Eq for structural equality
// Hash for HashMap keys
```

### Custom Traits

```rust
trait Storage {
    fn get(&self, key: &str) -> Option<String>;
    fn set(&mut self, key: String, value: String);
}

struct InMemoryStorage {
    data: HashMap<String, String>,
}

impl Storage for InMemoryStorage {
    fn get(&self, key: &str) -> Option<String> {
        self.data.get(key).cloned()
    }

    fn set(&mut self, key: String, value: String) {
        self.data.insert(key, value);
    }
}

// Trait objects
fn process(storage: &dyn Storage) {
    if let Some(value) = storage.get("key") {
        println!("Got: {}", value);
    }
}
```

## Performance Tips

### Optimize Builds

```bash
# Development
cargo build

# Release with optimizations
cargo build --release

# Profile-guided optimization (PGO)
cargo build --release
./target/release/bench  # Run workload
cargo pgo -- build --release
```

### Avoid Unnecessary Allocations

```rust
// Bad: Creates new String
fn format_bad(name: &str) -> String {
    format!("Hello, {}!", name)
}

// Good: Uses String::from if needed, or returns &str
fn format_good(name: &str) -> String {
    String::from("Hello, ") + name + "!"
}

// Even better: Write to buffer
fn write_to_buffer(name: &str, buf: &mut String) {
    buf.push_str("Hello, ");
    buf.push_str(name);
    buf.push('!');
}
```

### Use Cow for Conditional Ownership

```rust
use std::borrow::Cow;

fn to_uppercase(input: &str) -> Cow<'_, str> {
    if input.chars().all(|c| c.is_uppercase()) {
        Cow::Borrowed(input)  // No allocation needed
    } else {
        Cow::Owned(input.to_uppercase())  // Allocate
    }
}
```

## Best Practices

- Prefer `&str` over `&String` in function arguments
- Use `Result` for recoverable errors, `Option` for optional values
- Derive useful traits (`Debug`, `Clone`) for structs/enums
- Use iterators instead of loops when possible (performance + readability)
- Avoid `unwrap()` and `expect()` in production code
- Use `#[allow(clippy::all)]` sparingly
- Organize modules by feature, not by type
- Keep functions small and focused
- Write documentation tests with `///`
