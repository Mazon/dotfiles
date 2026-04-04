---
description: REST/GraphQL API design best practices, versioning, documentation, and error handling
---

# API Design Skill

## REST API Design Principles

### Resource Naming

```
# Use nouns, not verbs
GET    /users          # Good
GET    /getUsers       # Bad

# Use plural for collections
GET    /users          # Good
GET    /user           # Bad (unless singular entity)

# Hierarchical resources
GET    /users/123/orders
GET    /users/123/orders/456/items

# Filter with query parameters
GET    /users?role=admin&status=active
GET    /posts?sort=-created_at&page=2&limit=10
```

### HTTP Methods

| Method | Description | Idempotent | Safe |
|--------|-------------|------------|------|
| `GET` | Retrieve resource | Yes | Yes |
| `POST` | Create resource | No | No |
| `PUT` | Replace resource | Yes | No |
| `PATCH` | Update resource | No | No |
| `DELETE` | Delete resource | Yes | No |

### Status Codes

```rust
// 2xx Success
// 200 OK - Request succeeded
// 201 Created - Resource created
// 204 No Content - Successful request, no response body

// 3xx Redirection
// 301 Moved Permanently - Resource moved
// 302 Found - Temporary redirect
// 304 Not Modified - Resource not modified (for caching)

// 4xx Client Errors
// 400 Bad Request - Invalid request
// 401 Unauthorized - Authentication required
// 403 Forbidden - Authenticated but no permission
// 404 Not Found - Resource not found
// 409 Conflict - Resource conflict
// 422 Unprocessable Entity - Validation errors
// 429 Too Many Requests - Rate limited

// 5xx Server Errors
// 500 Internal Server Error - Server error
// 503 Service Unavailable - Service temporarily unavailable
```

### Request/Response Examples

```rust
// GET /users/123
Response:
{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com",
  "created_at": "2024-03-21T10:00:00Z",
  "updated_at": "2024-03-21T10:00:00Z"
}

// POST /users
Request:
{
  "name": "Bob",
  "email": "bob@example.com"
}

Response:
{
  "id": 124,
  "name": "Bob",
  "email": "bob@example.com",
  "created_at": "2024-03-21T10:01:00Z",
  "updated_at": "2024-03-21T10:01:00Z"
}

// PATCH /users/123
Request:
{
  "email": "alice.new@example.com"
}

Response:
{
  "id": 123,
  "name": "Alice",
  "email": "alice.new@example.com",
  "created_at": "2024-03-21T10:00:00Z",
  "updated_at": "2024-03-21T10:02:00Z"
}

// DELETE /users/123
Status: 204 No Content
```

### API Versioning

#### URL Path Versioning

```rust
// Version in URL path
GET    /v1/users
GET    /v2/users

// Pros:
// - Simple to implement
// - Clear versioning
//
// Cons:
// - URL pollution
// - Duplicate endpoints

// Implementation with Axum
async fn get_users_v1() -> Json<Vec<User>> {
    // v1 implementation
}

async fn get_users_v2() -> Json<UserResponse> {
    // v2 implementation
}

let app = Router::new()
    .route("/v1/users", get(get_users_v1))
    .route("/v2/users", get(get_users_v2));
```

#### Header Versioning

```rust
// Version in header
GET /users
Accept: application/vnd.myapi.v1+json

// Implementation
async fn get_users(headers: HeaderMap) -> Result<Json<UserResponse>> {
    let accept = headers.get("accept")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");

    if accept.contains("v1") {
        Ok(Json(UserResponse::V1(get_users_v1_impl())))
    } else if accept.contains("v2") {
        Ok(Json(UserResponse::V2(get_users_v2_impl())))
    } else {
        Err(ApiError::UnsupportedVersion)
    }
}
```

#### Query Parameter Versioning

```rust
// Version in query parameter
GET /users?version=1
GET /users?version=2

// Implementation
async fn get_users(Query(params): Query<VersionParams>) -> Json<Vec<User>> {
    match params.version.unwrap_or(1) {
        1 => Json(get_users_v1()),
        2 => Json(get_users_v2()),
        _ => Err(ApiError::UnsupportedVersion),
    }
}
```

### Pagination

#### Offset-Based Pagination

```rust
#[derive(Deserialize)]
struct PaginationParams {
    page: Option<usize>,
    limit: Option<usize>,
}

async fn get_users(
    Query(params): Query<PaginationParams>,
) -> Json<PaginatedResponse<User>> {
    let page = params.page.unwrap_or(1);
    let limit = params.limit.unwrap_or(20);

    let total = fetch_user_count().await;
    let users = fetch_users_paginated(page, limit).await;

    Json(PaginatedResponse {
        data: users,
        pagination: Pagination {
            page,
            limit,
            total,
            total_pages: (total as f64 / limit as f64).ceil() as usize,
        },
    })
}

// Response
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

#### Cursor-Based Pagination

```rust
#[derive(Deserialize)]
struct CursorParams {
    cursor: Option<String>,
    limit: Option<usize>,
}

async fn get_users(
    Query(params): Query<CursorParams>,
) -> Json<CursorResponse<User>> {
    let cursor = params.cursor.unwrap_or_default();
    let limit = params.limit.unwrap_or(20);

    let users = fetch_users_cursor(cursor, limit).await;
    let next_cursor = users.last().map(|u| u.id.to_string());

    Json(CursorResponse {
        data: users,
        next_cursor,
        has_more: next_cursor.is_some(),
    })
}

// Response
{
  "data": [...],
  "next_cursor": "eyJpZCI6MTIzfQ==",
  "has_more": true
}
```

## GraphQL Patterns

### Schema Design

```graphql
# Basic schema
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments: [Comment!]!
  createdAt: DateTime!
}

type Comment {
  id: ID!
  content: String!
  author: User!
  post: Post!
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
  posts(limit: Int, offset: Int): [Post!]!
}

type Mutation {
  createUser(name: String!, email: String!): User!
  createPost(title: String!, content: String!, authorId: ID!): Post!
  createComment(content: String!, postId: ID!, authorId: ID!): Comment!
}
```

### Resolvers with Async-GraphQL

```rust
use async_graphql::{Schema, Object, Context, SimpleObject, Result};

#[derive(SimpleObject)]
struct User {
    id: i32,
    name: String,
    email: String,
}

pub struct Query;

#[Object]
impl Query {
    async fn user(&self, ctx: &Context<'_>, id: i32) -> Result<Option<User>> {
        let db = ctx.data::<Database>().unwrap();
        let user = db.get_user(id).await?;
        Ok(user)
    }

    async fn users(
        &self,
        ctx: &Context<'_>,
        limit: Option<i32>,
        offset: Option<i32>,
    ) -> Result<Vec<User>> {
        let db = ctx.data::<Database>().unwrap();
        let users = db.get_users(limit.unwrap_or(20), offset.unwrap_or(0)).await?;
        Ok(users)
    }
}

pub struct Mutation;

#[Object]
impl Mutation {
    async fn create_user(
        &self,
        ctx: &Context<'_>,
        name: String,
        email: String,
    ) -> Result<User> {
        let db = ctx.data::<Database>().unwrap();
        let user = db.create_user(&name, &email).await?;
        Ok(user)
    }
}

let schema = Schema::build(Query, Mutation, EmptySubscription)
    .data(Database::new())
    .finish();
```

### DataLoader Pattern

```rust
use async_graphql::dataloader::*;

struct UserDataLoader {
    db: Database,
}

#[async_trait::async_trait]
impl Loader<i32> for UserDataLoader {
    type Value = User;
    type Error = ApiError;

    async fn load(&self, keys: &[i32]) -> Result<HashMap<i32, User>, Self::Error> {
        let users = self.db.get_users_batch(keys).await?;
        Ok(users.into_iter().map(|u| (u.id, u)).collect())
    }
}

// In resolver
async fn posts(&self, ctx: &Context<'_>) -> Result<Vec<Post>> {
    let loader = ctx.data::<DataLoader<UserDataLoader>>().unwrap();
    let posts = ctx.data::<Database>().unwrap()?.get_posts().await?;

    // Batch load authors
    for post in &posts {
        loader.load_one(post.author_id).await?;
    }

    Ok(posts)
}
```

### Subscriptions

```rust
use async_graphql::Subscription;

pub struct Subscription;

#[Subscription]
impl Subscription {
    async fn user_updated(&self, user_id: i32) -> impl Stream<Item = User> {
        let mut receiver = subscribe_to_user_updates(user_id).await;
        async_stream::stream! {
            while let Some(user) = receiver.recv().await {
                yield user;
            }
        }
    }
}
```

## Error Handling

### Standard Error Response Format

```rust
#[derive(Serialize)]
struct ErrorResponse {
    error: ErrorDetail,
}

#[derive(Serialize)]
struct ErrorDetail {
    code: String,
    message: String,
    details: Option<serde_json::Value>,
    request_id: String,
}

impl ApiError {
    fn to_response(&self, request_id: String) -> ErrorResponse {
        ErrorResponse {
            error: ErrorDetail {
                code: self.code().to_string(),
                message: self.message().to_string(),
                details: self.details(),
                request_id,
            },
        }
    }
}
```

### Error Codes

```rust
#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ErrorCode {
    // Authentication errors
    Unauthorized,
    TokenExpired,
    InvalidCredentials,

    // Validation errors
    ValidationError,
    InvalidInput,
    MissingRequiredField,

    // Resource errors
    NotFound,
    AlreadyExists,
    Conflict,

    // Server errors
    InternalServerError,
    ServiceUnavailable,
    DatabaseError,
}

#[derive(Debug)]
pub enum ApiError {
    Unauthorized { message: String },
    NotFound { resource: String, id: String },
    Validation { field: String, message: String },
    Internal { message: String },
}

impl ApiError {
    fn code(&self) -> ErrorCode {
        match self {
            ApiError::Unauthorized { .. } => ErrorCode::Unauthorized,
            ApiError::NotFound { .. } => ErrorCode::NotFound,
            ApiError::Validation { .. } => ErrorCode::ValidationError,
            ApiError::Internal { .. } => ErrorCode::InternalServerError,
        }
    }

    fn status(&self) -> StatusCode {
        match self {
            ApiError::Unauthorized { .. } => StatusCode::UNAUTHORIZED,
            ApiError::NotFound { .. } => StatusCode::NOT_FOUND,
            ApiError::Validation { .. } => StatusCode::UNPROCESSABLE_ENTITY,
            ApiError::Internal { .. } => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}
```

### Validation Errors

```rust
#[derive(Deserialize, Validate)]
struct CreateUserRequest {
    #[validate(email(message = "Invalid email format"))]
    #[validate(length(min = 1, max = 100, message = "Name must be 1-100 characters"))]
    name: String,

    #[validate(email(message = "Invalid email format"))]
    email: String,

    #[validate(length(min = 8, message = "Password must be at least 8 characters"))]
    password: String,
}

async fn create_user(
    State(db): State<Database>,
    Json(input): Json<CreateUserRequest>,
) -> Result<Json<User>, ApiError> {
    if let Err(errors) = input.validate() {
        return Err(ApiError::Validation {
            field: errors.field_errors().keys().next().unwrap().to_string(),
            message: errors.to_string(),
        });
    }

    let user = db.create_user(&input).await?;
    Ok(Json(user))
}
```

### Error Response Examples

```json
// Validation error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": "Invalid email format",
      "password": "Password must be at least 8 characters"
    },
    "request_id": "req_abc123"
  }
}

// Not found error
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "details": {
      "resource": "user",
      "id": "123"
    },
    "request_id": "req_abc123"
  }
}

// Internal server error
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "details": null,
    "request_id": "req_abc123"
  }
}
```

## API Documentation

### OpenAPI Specification (Swagger)

```rust
use utoipa::OpenApi;
use utoipa_swagger_ui::SwaggerUi;

#[derive(OpenApi)]
#[openapi(
    paths(
        get_user,
        create_user,
        update_user,
        delete_user
    ),
    components(
        schemas(User, CreateUserRequest, UpdateUserRequest)
    ),
    tags(
        (name = "users", description = "User management API")
    )
)]
struct ApiDoc;

let app = Router::new()
    .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));
```

### API Documentation in Rust

```rust
/// Get user by ID
///
/// Retrieves a user by their unique identifier.
///
/// # Parameters
///
/// * `id` - User ID
///
/// # Returns
///
/// Returns the user if found, or 404 if not found.
///
/// # Example
///
/// ```bash
/// curl http://localhost:8080/api/v1/users/123
/// ```
#[utoipa::path(
    get,
    path = "/api/v1/users/{id}",
    params(
        ("id" = i32, Path, description = "User ID")
    ),
    responses(
        (status = 200, description = "User found", body = User),
        (status = 404, description = "User not found")
    ),
    tag = "users"
)]
async fn get_user(
    Path(id): Path<i32>,
    State(db): State<Database>,
) -> Result<Json<User>, ApiError> {
    let user = db.get_user(id).await.ok_or(ApiError::NotFound {
        resource: "user".to_string(),
        id: id.to_string(),
    })?;
    Ok(Json(user))
}
```

### Generating OpenAPI JSON

```rust
// Automatically generate OpenAPI spec
let openapi = ApiDoc::openapi();

// Save to file
let spec = serde_json::to_string_pretty(&openapi).unwrap();
std::fs::write("openapi.json", spec).unwrap();
```

### Interactive Documentation

```rust
// Setup Swagger UI
let swagger_ui = SwaggerUi::new("/swagger-ui")
    .url("/api-docs/openapi.json", ApiDoc::openapi());

// Access at http://localhost:8080/swagger-ui/
```

## Rate Limiting

### Token Bucket Algorithm

```rust
use std::sync::Arc;
use std::time::{Duration, Instant};

struct RateLimiter {
    capacity: u32,
    tokens: u32,
    refill_rate: u32,
    last_refill: Instant,
}

impl RateLimiter {
    fn new(capacity: u32, refill_rate: u32) -> Self {
        RateLimiter {
            capacity,
            tokens: capacity,
            refill_rate,
            last_refill: Instant::now(),
        }
    }

    fn try_acquire(&mut self) -> bool {
        self.refill();

        if self.tokens > 0 {
            self.tokens -= 1;
            true
        } else {
            false
        }
    }

    fn refill(&mut self) {
        let elapsed = self.last_refill.elapsed();
        let tokens_to_add = (elapsed.as_secs() as u32) * self.refill_rate;
        self.tokens = (self.tokens + tokens_to_add).min(self.capacity);
        self.last_refill = Instant::now();
    }
}
```

### Rate Limiting Middleware

```rust
use axum::{
    extract::Request,
    middleware::Next,
    response::Response,
};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

async fn rate_limit_middleware(
    request: Request,
    next: Next,
) -> Result<Response, ApiError> {
    let ip = request
        .extensions()
        .get::<ConnectInfo<SocketAddr>>()
        .map(|c| c.0.ip())
        .unwrap();

    let limiters = request
        .extensions()
        .get::<Arc<Mutex<HashMap<IpAddr, RateLimiter>>>>()
        .unwrap();

    let mut limiters = limiters.lock().unwrap();
    let limiter = limiters
        .entry(ip)
        .or_insert_with(|| RateLimiter::new(100, 10)); // 100 req/min

    if !limiter.try_acquire() {
        return Err(ApiError::TooManyRequests);
    }

    Ok(next.run(request).await)
}
```

### Response Headers for Rate Limiting

```rust
use http::HeaderValue;

fn add_rate_limit_headers(response: &mut Response, limit: u32, remaining: u32) {
    response.headers_mut().insert(
        "X-RateLimit-Limit",
        HeaderValue::from(limit.to_string()),
    );
    response.headers_mut().insert(
        "X-RateLimit-Remaining",
        HeaderValue::from(remaining.to_string()),
    );
}
```

## Best Practices

### API Design

- Use nouns for resource names (`/users`, not `/getUsers`)
- Use plural for collections (`/users`, not `/user`)
- Use HTTP methods appropriately (GET for read, POST for create)
- Use appropriate status codes
- Support pagination for large collections
- Provide filtering and sorting with query parameters
- Use ISO 8601 for date/time formats
- Use JSON for request/response bodies
- Support content negotiation (Accept header)

### Error Handling

- Always return consistent error format
- Include error codes for programmatic handling
- Provide detailed error messages
- Include request IDs for debugging
- Log errors server-side
- Don't expose sensitive information in errors

### Security

- Use HTTPS only
- Implement authentication and authorization
- Validate all input
- Use parameterized queries for database
- Implement rate limiting
- Use CORS properly
- Sanitize output
- Keep dependencies updated

### Performance

- Implement caching
- Use connection pooling
- Optimize database queries
- Use async/await properly
- Implement pagination
- Compress responses
- Use CDN for static assets
- Monitor performance metrics
