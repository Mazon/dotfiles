**Secure, agent-based AI coding configuration for [pi](https://github.com/nicepkg/pi-coding-agent)**

Sandboxed | Permission-Gated | Worktree Isolated | Smooth defaults

---

## Usage

```text
/idea "Fix login bug"    →  capture as a pending task
/plan                    →  explore codebase, save plan, create dependency-linked tasks
/do                      →  The executor commands
/skill:review            →  review changes for correctness & security
```

> Start with `/idea`, refine with `/plan`, execute with `/do`, ship with `/skill:git-pr`.

---

## Security Architecture

> Every agent action is constrained by three independent layers: OS-level sandboxing, a default-deny permission system, and per-agent isolation policies.

### OS-Level Sandbox

| Layer | Policy |
|-------|--------|
| **Network** | Deny-by-default. No direct internet access — proxied through local allowlist |
| **PID namespace** | Isolated — agents cannot see host processes |
| **Seccomp filter** | UNIX domain socket creation blocked via BPF |
| **Root filesystem** | Read-only (`--ro-bind / /`) |

**Protected paths (write-masked):** `~/.ssh`, `~/.gnupg`, `~/.config`, `~/.bashrc`, `~/.zshrc`, `~/.profile`, `~/.gitconfig`

**Hidden (replaced with `/dev/null`):** `.env`, `.env.*`

**Sensitive files (read-denied):** `.env`, `.env.*`, `*.pem`, `*.key`, `~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.config`

### Permission System

Whitelist only.

| Rule | Access |
|------|--------|
| Default (`*`) | **Ask** — every action requires approval |
| Read tools (`read`, `grep`, `find`) | Allow |
| Write / Edit | Ask (global), overridden per-agent |

Each agent defines its own permission block that **replaces** (not merges with) the global defaults — agents get only the capabilities they need.

### Agent Isolation

| Agent | Write | Edit | Bash | Isolation |
|-------|-------|------|------|-----------|
| **Do** | Allow | Allow | Allow (npm, cargo, git, python...) | **Worktree** -- changes in separate git worktree, merged on success |
| **Plan** | Ask (`*`) | Deny | Deny (`*`) / Allow (git, rg, cat...) | Background |
| **Explore** | Deny | Deny | Ask (`*`) | Background |
| **Reviewer** | Deny | Deny | Ask (`*`) | Background |
| **Assistant** | Deny | Deny | Ask (`*`) | Background |

> The Do agent is the **only** agent that can modify your codebase — and it does so in an isolated git worktree that must be merged explicitly.

---

## Slash Commands

| Command | What | Delegates To |
|---------|------|-------------|
| `/idea <text>` | Capture an idea as a pending task | Direct (TaskCreate) |
| `/plan <goal \| #id>` | Explore → plan → save → create tasks | Plan |
| `/do <task-id>` | Execute a single task in a worktree | Do |
| `/do-next` | Auto-pick and execute the next unblocked task | Do |
| `/do-all` | Execute all pending tasks in wave order (parallel) | Do |
| `/ask <question>` | Route to assistant for chat/analysis | Assistant |
| `/init` | Initialize project (git, .gitignore, README) | Do |
| `/grill-me <topic>` | Interview-style design deep-dive | Reviewer |

---

## Skills

| Skill | What It Does |
|-------|-------------|
| `git-commit` | Stage all changes + commit with auto-generated message |
| `git-pr` | Branch + commit + push + open pull request |
| `git-merge` | Verify build, merge branch, update task status |
| `review` | Structured code review with severity ratings (Critical to Info) |
| `debug` | Root-cause analysis, creates independent fix tasks |
| `ask-user` | Structured decision handshake for high-stakes choices |

---

## Misc Extensions

Extensions add custom commands, tools, themes, and UI enhancements. The following are installed and active:

### pi-usage-stats

Tracks token and cost usage per session and per project. Data is stored locally under `agent/extensions/pi-usage-stats/logs/`.

### split-editor

Configures the integrated editor split for file review during agent sessions. Uses `nvim` in a vertical 50% split.


---

## Models

Currently configured providers are z.ai, Google Gemini, and llama.cpp. The default model is `glm-5.1` via z.ai. Available models:

| Provider | Model | Notes |
|----------|-------|-------|
| z.ai | glm-5.1 | Default, high reasoning |
| z.ai | glm-5-turbo | Fast responses |
| z.ai | glm-5v-turbo | Vision-capable |
| Google | gemini-3.1-pro-preview | Pro-tier Gemini |
| Google | gemini-3.1-flash-lite | Lightweight flash |
| Google | gemini-3.5-flash | Latest flash model |

> The exact set of models will vary by user and available API keys.

---

## Configuration Highlights

| Setting | Value | Why |
|---------|-------|-----|
| Compaction | Disabled | Full conversation context retained |
| Thinking block | Hidden | Clean output, thinking happens silently |
| Web search | `summary-review` | Fetch, summarize, review workflow |
| Theme | Aurora Abyss | Custom dark pastel palette |
| Double-escape | `interrupt` | Two quick escapes interrupts the running agent |
| Hardware cursor | Disabled | Uses software cursor for terminal compatibility |
| Install telemetry | Disabled | No data sent on package installs |
