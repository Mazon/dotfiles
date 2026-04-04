---
description: DevOps/Infrastructure patterns including Docker, Kubernetes, Terraform, and CI/CD for Rust applications
---

# DevOps Skill

## Docker for Rust Applications

### Optimized Dockerfile

```dockerfile
# Build stage
FROM rust:1.75-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Build application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from builder
COPY --from=builder /app/target/release/my-app /app/my-app

# Use non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 8080

CMD ["/app/my-app"]
```

### Multi-Stage Build for Smaller Images

```dockerfile
# Build stage
FROM rust:1.75-slim as builder

WORKDIR /app

# Cache dependencies
RUN cargo new my-app
WORKDIR /app/my-app

COPY Cargo.toml Cargo.lock ./
RUN cargo build --release
RUN rm src/*.rs

# Copy source code
COPY src ./src
RUN touch src/main.rs
RUN cargo build --release

# Runtime stage (distroless)
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/my-app/target/release/my-app /my-app

EXPOSE 8080

CMD ["/my-app"]
```

### Alpine Linux Variant

```dockerfile
FROM rust:1.75-alpine as builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    pkgconfig \
    openssl-dev \
    libgcc

COPY . .

# Build with musl target
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:3.19

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates libgcc

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/my-app /app/my-app

EXPOSE 8080

CMD ["/app/my-app"]
```

### Development Dockerfile

```dockerfile
FROM rust:1.75-slim

WORKDIR /app

# Install development tools
RUN apt-get update && \
    apt-get install -y \
    cargo-watch \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Pre-install dependencies
COPY Cargo.toml Cargo.lock ./
RUN cargo fetch

# Set up hot reload
CMD ["cargo-watch", "-x", "run"]
```

### Docker Compose for Development

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    volumes:
      - .:/app
      - cargo_cache:/usr/local/cargo/registry
    environment:
      - RUST_LOG=debug
      - DATABASE_URL=postgres://postgres:password@db:5432/myapp

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  cargo_cache:
  postgres_data:
```

## Kubernetes Patterns

### Basic Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rust-app
  labels:
    app: rust-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rust-app
  template:
    metadata:
      labels:
        app: rust-app
    spec:
      containers:
      - name: rust-app
        image: my-registry/rust-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: RUST_LOG
          value: "info"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: rust-app-service
spec:
  type: ClusterIP
  selector:
    app: rust-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: rust-app-ingress
spec:
  type: LoadBalancer
  selector:
    app: rust-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

### ConfigMap and Secrets

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rust-app-config
data:
  APP_NAME: "My Rust App"
  LOG_LEVEL: "info"

---
apiVersion: v1
kind: Secret
metadata:
  name: rust-app-secret
type: Opaque
data:
  DATABASE_URL: cG9zdGdyZXM6Ly91c2VyOnBhc3NAdG9tYXRvOjU0MzIvZGI=  # base64 encoded
  API_KEY: c2VjcmV0LWtleQ==

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rust-app
spec:
  template:
    spec:
      containers:
      - name: rust-app
        envFrom:
        - configMapRef:
            name: rust-app-config
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: rust-app-secret
              key: DATABASE_URL
```

### HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: rust-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: rust-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Init Containers

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rust-app
spec:
  template:
    spec:
      initContainers:
      - name: migrate-db
        image: my-registry/rust-app:latest
        command: ["my-app", "migrate"]
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: rust-app-secret
              key: DATABASE_URL
      containers:
      - name: rust-app
        image: my-registry/rust-app:latest
        # Main app container
```

### Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: rust-app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: rust-app
```

## Terraform Patterns

### Module Structure

```
terraform/
├── modules/
│   ├── app/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── database/
│   │   └── ...
│   └── vpc/
│       └── ...
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── ...
│   └── production/
│       └── ...
└── provider.tf
```

### App Module

```hcl
# modules/app/main.tf
resource "aws_ecs_task_definition" "app" {
  family                   = "rust-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "rust-app"
      image     = "${var.image}:${var.image_tag}"
      cpu       = var.cpu
      memory    = var.memory
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "RUST_LOG"
          value = var.log_level
        }
      ]

      secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "rust-app"
    container_port   = var.container_port
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.log_retention
}
```

### Variables

```hcl
# modules/app/variables.tf
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "image" {
  description = "Docker image repository"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "log_level" {
  description = "Rust log level"
  type        = string
  default     = "info"
}

variable "secrets" {
  description = "Container secrets"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}
```

### Outputs

```hcl
# modules/app/outputs.tf
output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "service_id" {
  value = aws_ecs_service.app.id
}
```

### Root Configuration

```hcl
# environments/dev/main.tf
module "vpc" {
  source      = "../../modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"
}

module "app" {
  source           = "../../modules/app"
  app_name         = "rust-app-dev"
  image            = "my-registry/rust-app"
  image_tag        = var.image_tag
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.public_subnet_ids
  security_groups  = [module.vpc.default_security_group_id]
  cluster_id       = module.ecs.cluster_id
  target_group_arn = module.alb.target_group_arn
  environment      = "dev"
}
```

### Provider Configuration

```hcl
# provider.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "rust-app"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"
}
```

## CI/CD Patterns

### GitHub Actions - Rust

```yaml
name: Rust CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  CARGO_TERM_COLOR: always
  RUST_BACKTRACE: 1

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - uses: actions-rust-lang/setup-rust-toolchain@v1
      with:
        toolchain: stable

    - name: Cache cargo registry
      uses: actions/cache@v4
      with:
        path: ~/.cargo/registry
        key: ${{ runner.os }}-cargo-registry-${{ hashFiles('**/Cargo.lock') }}

    - name: Cache cargo index
      uses: actions/cache@v4
      with:
        path: ~/.cargo/git
        key: ${{ runner.os }}-cargo-index-${{ hashFiles('**/Cargo.lock') }}

    - name: Cache cargo build
      uses: actions/cache@v4
      with:
        path: target
        key: ${{ runner.os }}-cargo-build-target-${{ hashFiles('**/Cargo.lock') }}

    - name: Run tests
      run: cargo test --all-features

    - name: Run clippy
      run: cargo clippy -- -D warnings

    - name: Check formatting
      run: cargo fmt -- --check

  build:
    name: Build
    needs: test
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - uses: actions-rust-lang/setup-rust-toolchain@v1

    - name: Build release
      run: cargo build --release

    - name: Upload binary
      uses: actions/upload-artifact@v4
      with:
        name: binary
        path: target/release/my-app

  docker:
    name: Docker Build
    needs: test
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ secrets.DOCKER_USERNAME }}/rust-app:latest
          ${{ secrets.DOCKER_USERNAME }}/rust-app:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### GitLab CI - Rust

```yaml
image: rust:latest

variables:
  CARGO_HOME: "$CI_PROJECT_DIR/.cargo"
  RUST_BACKTRACE: 1

stages:
  - test
  - build
  - deploy

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .cargo/registry
    - target/

test:
  stage: test
  before_script:
    - rustc --version
    - cargo --version
  script:
    - cargo test --all-features
    - cargo clippy -- -D warnings
    - cargo fmt -- --check

build:
  stage: build
  script:
    - cargo build --release
  artifacts:
    paths:
      - target/release/my-app
    expire_in: 1 week

docker:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t my-registry/rust-app:$CI_COMMIT_SHA .
    - docker push my-registry/rust-app:$CI_COMMIT_SHA

deploy_staging:
  stage: deploy
  image: alpine/helm:latest
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - helm upgrade --install rust-app ./charts/rust-app
        --set image.tag=$CI_COMMIT_SHA
        --namespace staging
  only:
    - main
```

### Deployment Pipeline

```yaml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster my-cluster \
          --service rust-app \
          --force-new-deployment

    - name: Wait for deployment
      run: |
        aws ecs wait services-stable \
          --cluster my-cluster \
          --services rust-app
```

## Infrastructure as Code Principles

### State Management

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Workspaces for Environments

```bash
# Create workspace
terraform workspace new dev

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select production
```

### Variable Validation

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}

variable "port" {
  description = "Port number"
  type        = number

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}
```

### Resource Naming Conventions

```hcl
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster"
}

resource "aws_ecs_service" "app" {
  name = "${var.project_name}-${var.environment}-app"
}
```

### Dependency Management

```hcl
resource "aws_security_group" "app" {
  name = "${var.project_name}-app-sg"
  # ...
}

resource "aws_ecs_service" "app" {
  name = "${var.project_name}-app"

  network_configuration {
    security_groups = [aws_security_group.app.id]
  }
}
```

## Monitoring and Observability

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'rust-app'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __meta_kubernetes_pod_container_port_number
        regex: (.+)
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Rust Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_errors_total[5m])"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "targets": [
          {
            "expr": "container_memory_usage_bytes{container=\"rust-app\"}"
          }
        ]
      }
    ]
  }
}
```

## Best Practices

### Security

```yaml
# Use non-root user
USER appuser

# Don't run as root in Kubernetes
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

# Secrets management
secrets:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: database-url
```

### Cost Optimization

```hcl
# Use spot instances
resource "aws_ecs_task_definition" "app" {
  # ...
}

resource "aws_autoscaling_group" "app" {
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 3
    }
  }
}
```

### Scalability

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 100
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```
