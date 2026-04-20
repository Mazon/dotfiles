---
description: Async Rust patterns with tokio, concurrency, channels, and async traits
---

# Rust Async Skill

## Tokio Runtime Setup

### Basic Runtime

```rust
use tokio;

#[tokio::main]
async fn main() {
    println!("Hello from tokio!");
}
```

### Multi-Threaded Runtime

```rust
use tokio;

#[tokio::main(flavor = "multi_thread", worker_threads = 4)]
async fn main() {
    println!("Running on 4 threads");
}
```

### Current Thread Runtime

```rust
use tokio;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    // Single-threaded runtime
    // Useful for tests or blocking work
}
```

### Manual Runtime

```rust
use tokio::runtime::Runtime;

fn main() {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        // Async code here
        println!("Async code running");
    });
}
```

## Async/Await Patterns

### Basic Async Functions

```rust
use std::time::Duration;
use tokio::time::sleep;

async fn fetch_data(id: u32) -> String {
    sleep(Duration::from_millis(100)).await;
    format!("Data for {}", id)
}

async fn process(id: u32) -> String {
    let data = fetch_data(id).await;
    data.to_uppercase()
}
```

### Concurrent Execution with join!

```rust
use tokio::task::join_all;

async fn fetch_multiple() -> Vec<String> {
    let ids = vec![1, 2, 3, 4, 5];

    // Run all fetches concurrently
    let tasks: Vec<_> = ids.into_iter()
        .map(|id| fetch_data(id))
        .collect();

    join_all(tasks).await
}

// Or with join! macro for known number of futures
async fn fetch_two() -> (String, String) {
    let a = fetch_data(1);
    let b = fetch_data(2);
    tokio::join!(a, b)
}
```

### Error Handling in Async

```rust
use std::error::Error;

type Result<T> = std::result::Result<T, Box<dyn Error + Send + Sync>>;

async fn async_operation() -> Result<String> {
    let data = fetch_data(1).await?;
    let processed = process_async(&data).await?;
    Ok(processed)
}

// Multiple results with try_join
async fn fetch_with_error() -> Result<(String, String)> {
    let a = fetch_data(1);
    let b = fetch_data(2);
    tokio::try_join!(a, b)
}
```

### Async Iterators

```rust
use tokio_stream::{StreamExt, Stream}; // Requires tokio-stream crate

async fn process_stream() {
    let stream = async_stream::stream! {
        for i in 0..10 {
            tokio::time::sleep(Duration::from_millis(100)).await;
            yield i;
        }
    };

    tokio::pin!(stream);

    while let Some(value) = stream.next().await {
        println!("Got: {}", value);
    }
}
```

## Channels

### mpsc (Multi-Producer, Single-Consumer)

```rust
use tokio::sync::mpsc;

async fn producer(mut tx: mpsc::Sender<String>) {
    for i in 0..10 {
        let msg = format!("Message {}", i);
        tx.send(msg).await.unwrap();
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
}

async fn consumer(mut rx: mpsc::Receiver<String>) {
    while let Some(msg) = rx.recv().await {
        println!("Received: {}", msg);
    }
}

async fn mpsc_example() {
    let (tx, rx) = mpsc::channel(32); // Buffer size

    tokio::spawn(producer(tx));
    tokio::spawn(consumer(rx));
}
```

### broadcast (Multi-Producer, Multi-Consumer)

```rust
use tokio::sync::broadcast;

async fn broadcast_example() {
    let (tx, mut rx1) = broadcast::channel(16);
    let mut rx2 = tx.subscribe();

    // Sender
    tokio::spawn(async move {
        for i in 0..10 {
            let _ = tx.send(format!("Broadcast {}", i));
            tokio::time::sleep(Duration::from_millis(100)).await;
        }
    });

    // Receiver 1
    tokio::spawn(async move {
        while let Ok(msg) = rx1.recv().await {
            println!("Rx1: {}", msg);
        }
    });

    // Receiver 2
    tokio::spawn(async move {
        while let Ok(msg) = rx2.recv().await {
            println!("Rx2: {}", msg);
        }
    });
}
```

### watch (Single-Producer, Multi-Consumer)

```rust
use tokio::sync::watch;

async fn watch_example() {
    let (tx, mut rx) = watch::channel(0);

    // Receiver
    tokio::spawn(async move {
        loop {
            let val = *rx.borrow_and_update();
            println!("Current value: {}", val);
            rx.changed().await.unwrap();
        }
    });

    // Sender
    for i in 1..=10 {
        tx.send(i).unwrap();
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
}
```

### oneshot (Single Value)

```rust
use tokio::sync::oneshot;

async fn oneshot_example() {
    let (tx, rx) = oneshot::channel();

    tokio::spawn(async move {
        tokio::time::sleep(Duration::from_millis(500)).await;
        tx.send("Response!").unwrap();
    });

    let result = rx.await.unwrap();
    println!("Received: {}", result);
}
```

## Async Traits

### Using async_trait Macro

```rust
use async_trait::async_trait;

#[async_trait]
trait Processor {
    async fn process(&self, data: &str) -> Result<String>;
}

struct MyProcessor;

#[async_trait]
impl Processor for MyProcessor {
    async fn process(&self, data: &str) -> Result<String> {
        Ok(data.to_uppercase())
    }
}

async fn use_processor<P: Processor>(processor: &P) -> Result<String> {
    processor.process("hello").await
}
```

### Async Trait Objects

```rust
use async_trait::async_trait;
use std::sync::Arc;

#[async_trait]
trait Service {
    async fn handle(&self, request: &str) -> Result<String>;
}

async fn use_service(service: Arc<dyn Service>) -> Result<String> {
    service.handle("request").await
}
```

## Concurrent Programming Patterns

### Spawn Independent Tasks

```rust
use tokio::task;

async fn task_spawn() {
    let handle1 = task::spawn(async {
        // Background task 1
        tokio::time::sleep(Duration::from_secs(1)).await;
        42
    });

    let handle2 = task::spawn(async {
        // Background task 2
        tokio::time::sleep(Duration::from_secs(2)).await;
        24
    });

    // Wait for both
    let (result1, result2) = tokio::join!(handle1, handle2);
    println!("Results: {:?} {:?}", result1, result2);
}
```

### Task Local Storage

```rust
use tokio::task_local;

task_local! {
    static REQUEST_ID: u64;
}

async fn process_request() {
    REQUEST_ID.with(|id| {
        println!("Processing request ID: {}", *id);
    });
}

async fn task_local_example() {
    REQUEST_ID.scope(12345, async {
        process_request().await;
    }).await;
}
```

### Semaphore for Concurrency Limits

```rust
use tokio::sync::Semaphore;

async fn semaphore_example() {
    let semaphore = Arc::new(Semaphore::new(3)); // Max 3 concurrent

    let mut tasks = Vec::new();

    for i in 0..10 {
        let permit = semaphore.clone().acquire_owned().await.unwrap();
        tasks.push(tokio::spawn(async move {
            // Do work
            tokio::time::sleep(Duration::from_millis(100)).await;
            println!("Task {} completed", i);
            drop(permit); // Release permit
        }));
    }

    for task in tasks {
        task.await.unwrap();
    }
}
```

### Mutex in Async

```rust
use tokio::sync::Mutex;

async fn mutex_example() {
    let counter = Arc::new(Mutex::new(0));

    let mut tasks = Vec::new();

    for _ in 0..10 {
        let counter = counter.clone();
        tasks.push(tokio::spawn(async move {
            let mut c = counter.lock().await;
            *c += 1;
            println!("Count: {}", *c);
        }));
    }

    for task in tasks {
        task.await.unwrap();
    }

    println!("Final count: {}", *counter.lock().await);
}
```

### RwLock for Read-Write Access

```rust
use tokio::sync::RwLock;

async fn rwlock_example() {
    let data = Arc::new(RwLock::new(vec
![1, 2, 3]));

    // Multiple readers
    let mut read_tasks = Vec::new();
    for i in 0..5 {
        let data = data.clone();
        read_tasks.push(tokio::spawn(async move {
            let r = data.read().await;
            println!("Reader {}: {:?}", i, *r);
        }));
    }

    // Single writer
    let data_clone = data.clone();
    let write_task = tokio::spawn(async move {
        let mut w = data_clone.write().await;
        w.push(4);
        println!("Writer: modified data");
    });

    // Wait for all
    for task in read_tasks {
        task.await.unwrap();
    }
    write_task.await.unwrap();
}
```

## Timeout and Cancellation

### Timeout

```rust
use tokio::time::{timeout, sleep};
use std::time::Duration;

async fn timeout_example() -> Result<String, Box<dyn Error>> {
    match timeout(Duration::from_secs(1), long_operation()).await {
        Ok(result) => Ok(result),
        Err(_) => Err("Operation timed out".into()),
    }
}

async fn long_operation() -> String {
    sleep(Duration::from_secs(2)).await;
    "Done".to_string()
}
```

### Abort Handle

```rust
use tokio::task;

async fn abort_example() {
    let task = task::spawn(async {
        loop {
            println!("Running...");
            tokio::time::sleep(Duration::from_millis(100)).await;
        }
    });

    tokio::time::sleep(Duration::from_secs(1)).await;
    task.abort();

    match task.await {
        Ok(_) => println!("Task completed"),
        Err(e) => println!("Task aborted: {:?}", e),
    }
}
```

### Cooperative Cancellation

```rust
use tokio::select;

async fn cooperative_cancellation() -> Result<(), Box<dyn Error>> {
    let operation = async {
        for i in 0..100 {
            // Check for cancellation
            tokio::task::yield_now().await;
            println!("Step {}", i);
            tokio::time::sleep(Duration::from_millis(100)).await;
        }
        Ok::<(), Box<dyn Error>>(())
    };

    let timeout = tokio::time::sleep(Duration::from_secs(1));

    select! {
        result = operation => result,
        _ = timeout => Err("Timeout".into()),
    }
}
```

### Select Pattern

```rust
use tokio::sync::mpsc;
use tokio::select;

async fn select_example() {
    let (tx1, mut rx1) = mpsc::channel(16);
    let (tx2, mut rx2) = mpsc::channel(16);

    tokio::spawn(async move {
        tx1.send("From channel 1").await.unwrap();
    });

    tokio::spawn(async move {
        tokio::time::sleep(Duration::from_millis(50)).await;
        tx2.send("From channel 2").await.unwrap();
    });

    loop {
        select! {
            msg = rx1.recv() => {
                if let Some(msg) = msg {
                    println!("Rx1: {}", msg);
                } else {
                    break;
                }
            }
            msg = rx2.recv() => {
                if let Some(msg) = msg {
                    println!("Rx2: {}", msg);
                } else {
                    break;
                }
            }
            else => break,
        }
    }
}
```

## Async Stream Processing

### Stream Map and Filter

```rust
use futures::{stream, StreamExt};

async fn stream_operations() {
    let numbers = stream::iter(0..10);

    let result = numbers
        .map(|x| x * 2)
        .filter(|x| async move { x % 3 == 0 })
        .collect::<Vec<_>>()
        .await;

    println!("{:?}", result); // [0, 6, 12, 18]
}
```

### Stream with Error Handling

```rust
use futures::{StreamExt, TryStreamExt};

async fn stream_with_errors() -> Result<(), Box<dyn Error>> {
    let mut stream = async_stream::stream! {
        for i in 0..10 {
            if i == 5 {
                yield Err("Error at 5");
            } else {
                yield Ok(i);
            }
        }
    };

    while let Some(result) = stream.next().await {
        match result {
            Ok(value) => println!("Got: {}", value),
            Err(e) => println!("Error: {}", e),
        }
    }

    Ok(())
}
```

## Async HTTP with Reqwest

```rust
use reqwest::Client;

async fn http_get(url: &str) -> Result<String, reqwest::Error> {
    let client = Client::new();
    let response = client.get(url).send().await?;
    let text = response.text().await?;
    Ok(text)
}

async fn concurrent_requests() -> Result<(), Box<dyn Error>> {
    let urls = vec![
        "https://api.example.com/1",
        "https://api.example.com/2",
        "https://api.example.com/3",
    ];

    let client = Client::new();

    let responses = futures::future::try_join_all(
        urls.iter().map(|url| client.get(url).send())
    ).await?;

    for response in responses {
        println!("Status: {}", response.status());
    }

    Ok(())
}
```

## Best Practices

### Avoid Blocking in Async Code

```rust
// Bad: Blocks the thread
async fn blocking_bad() {
    std::thread::sleep(Duration::from_secs(1)); // Don't do this!
}

// Good: Use async sleep
async fn blocking_good() {
    tokio::time::sleep(Duration::from_secs(1)).await;
}

// For CPU-intensive blocking work, spawn_blocking
async fn cpu_intensive() {
    tokio::task::spawn_blocking(|| {
        // Blocking CPU work here
        let result = expensive_computation();
        result
    }).await.unwrap();
}
```

### Use Pin for Streams

```rust
use futures::StreamExt;

async fn pin_stream_example() {
    let stream = async_stream::stream! {
        for i in 0..10 {
            yield i;
        }
    };

    tokio::pin!(stream);

    while let Some(value) = stream.next().await {
        println!("Got: {}", value);
    }
}
```

### Handle Backpressure

```rust
use tokio::sync::mpsc;

async fn backpressure_example() {
    let (tx, mut rx) = mpsc::channel(10); // Small buffer

    tokio::spawn(async move {
        for i in 0..100 {
            // This will wait if buffer is full
            if let Err(_) = tx.send(i).await {
                break; // Receiver dropped
            }
        }
    });

    while let Some(value) = rx.recv().await {
        // Process value
        tokio::time::sleep(Duration::from_millis(50)).await;
    }
}
```

### Structured Concurrency

```rust
// All tasks complete before function returns
async fn structured_concurrency() {
    tokio::spawn(async {
        // Task 1
    });

    tokio::spawn(async {
        // Task 2
    });

    // Both tasks are automatically cancelled if this task is cancelled
    tokio::time::sleep(Duration::from_secs(1)).await;
}
```

## Common Patterns

### Retry Pattern

```rust
async fn retry_with_backoff<F, Fut, T, E>(
    mut f: F,
    max_attempts: u32,
) -> Result<T, E>
where
    F: FnMut() -> Fut,
    Fut: std::future::Future<Output = Result<T, E>>,
{
    let mut attempt = 0;
    loop {
        attempt += 1;
        match f().await {
            Ok(value) => return Ok(value),
            Err(e) if attempt < max_attempts => {
                let delay = Duration::from_millis(100 * 2_u64.pow(attempt));
                tokio::time::sleep(delay).await;
            }
            Err(e) => return Err(e),
        }
    }
}
```

### Worker Pool Pattern

```rust
async fn worker_pool() {
    let (tx, mut rx) = mpsc::channel(100);

    // Start workers
    for worker_id in 0..5 {
        let mut rx = tx.subscribe();
        tokio::spawn(async move {
            while let Ok(job) = rx.recv().await {
                println!("Worker {} processing job {}", worker_id, job);
                tokio::time::sleep(Duration::from_millis(100)).await;
            }
        });
    }

    // Send jobs
    for job in 0..20 {
        tx.send(job).await.unwrap();
    }
}
```

### Circuit Breaker Pattern

```rust
struct CircuitBreaker {
    failures: u32,
    threshold: u32,
    last_failure: Option<Instant>,
    cooldown: Duration,
    state: State,
}

enum State {
    Closed,
    Open,
    HalfOpen,
}

impl CircuitBreaker {
    async fn call<F, Fut, T, E>(&mut self, f: F) -> Result<T, E>
    where
        F: FnOnce() -> Fut,
        Fut: std::future::Future<Output = Result<T, E>>,
    {
        match self.state {
            State::Open => {
                if let Some(last) = self.last_failure {
                    if last.elapsed() > self.cooldown {
                        self.state = State::HalfOpen;
                    } else {
                        return Err("Circuit is open".into());
                    }
                }
            }
            State::HalfOpen => {
                // Allow one request to test
            }
            State::Closed => {
                // Normal operation
            }
        }

        match f().await {
            Ok(value) => {
                self.failures = 0;
                if matches!(self.state, State::HalfOpen) {
                    self.state = State::Closed;
                }
                Ok(value)
            }
            Err(e) => {
                self.failures += 1;
                self.last_failure = Some(Instant::now());
                if self.failures >= self.threshold {
                    self.state = State::Open;
                }
                Err(e)
            }
        }
    }
}
