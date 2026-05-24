# ~/.pi

**Secure, agent-based AI coding configuration for [pi](https://github.com/nicepkg/pi-coding-agent)**

🔒 Sandboxed · 🛡️ Permission-Gated · 🌳 Worktree Isolated · 🎨 Aurora Abyss Theme

---

## Quick Start — Core Workflow

```text
/idea "Fix login bug"    →  capture as a pending task
/plan #1                 →  explore codebase, save plan, create dependency-linked tasks
/do-next                 →  auto-pick & execute the next unblocked task in a worktree
/do-all                  →  run all pending tasks in parallel, wave by wave
/skill:review            →  review changes for correctness & security
/skill:git-pr            →  commit + push + open pull request
```

> Start with `/idea`, refine with `/plan`, execute with `/do-next` or `/do-all`, ship with `/skill:git-pr`.

---

## Security Architecture

> Every agent action is constrained by three independent layers: OS-level sandboxing, a default-deny permission system, and per-agent isolation policies.

### 🔒 OS-Level Sandbox (Bubblewrap)

| Layer | Policy |
|-------|--------|
| **Network** | Deny-by-default. No direct internet access — proxied through local allowlist |
| **PID namespace** | Isolated — agents cannot see host processes |
| **Seccomp filter** | UNIX domain socket creation blocked via BPF |
| **Root filesystem** | Read-only (`--ro-bind / /`) |

**Protected paths (write-masked):** `~/.ssh`, `~/.gnupg`, `~/.config`, `~/.bashrc`, `~/.zshrc`, `~/.profile`, `~/.gitconfig`

**Hidden (replaced with `/dev/null`):** `.env`, `.env.*`

**Sensitive files (read-denied):** `.env`, `.env.*`, `*.pem`, `*.key`, `~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.config`

### 🛡️ Permission System

| Rule | Access |
|------|--------|
| Default (`*`) | **Ask** — every action requires approval |
| `rm -rf *` | **Deny** — non-overridable, even for Do agent |
| `sudo *` | **Deny** — non-overridable |
| Read tools (`read`, `grep`, `find`) | Allow |
| Write / Edit | Ask (global), overridden per-agent |
| Yolo mode | **Disabled** |

Each agent defines its own permission block that **replaces** (not merges with) the global defaults — agents get only the capabilities they need.

### 🌳 Agent Isolation

| Agent | Write | Edit | Bash | Isolation |
|-------|-------|------|------|-----------|
| **Do** | ✅ Allow | ✅ Allow | Allow (npm, cargo, git, python…) | **Worktree** — changes in separate git worktree, merged on success |
| **Plan** | ✅ Plans only | ❌ Deny | Deny (`*`) / Allow (git, rg, cat…) | Background |
| **Explore** | ❌ Deny | ❌ Deny | Ask (`*`) | Background |
| **Reviewer** | ❌ Deny | ❌ Deny | Ask (`*`) | Background |
| **Assistant** | ❌ Deny | ❌ Deny | Ask (`*`) | Background |

> The Do agent is the **only** agent that can modify your codebase — and it does so in an isolated git worktree that must be merged explicitly.

---

## Agents

| Agent | Purpose | File Access |
|-------|---------|-------------|
| **Do** | Implement, build, test — executes tasks | ✅ Full (worktree) |
| **Plan** | Explore codebase → save plan → create tasks | 📝 Plans only |
| **Explore** | Fast read-only code search & pattern discovery | 🔒 Read-only |
| **Reviewer** | Code review — correctness & security | 🔒 Read-only |
| **Assistant** | Chat, Q&A, writing, analysis | 🔒 Read-only |

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
| `git-merge` | Verify build → merge branch → update task status |
| `review` | Structured code review with severity ratings (Critical → Info) |
| `debug` | Root-cause analysis → creates independent fix tasks |
| `ask-user` | Structured decision handshake for high-stakes choices |
| `librarian` | Research open-source libraries with source code citations |

---

## Models

| Provider | Model | Notes |
|----------|-------|-------|
| **zai** *(default)* | `glm-5.1` | Default model, high thinking |
| zai | `glm-5-turbo` | Fast variant |
| zai | `glm-5v-turbo` | Vision |
| google | `gemini-3.1-pro-preview` | |
| google | `gemini-3.5-flash` | |
| google | `gemini-3.1-flash-lite` | |
| llama-cpp *(local)* | Auto-discovered | Local models via llama.cpp server |

---

## Configuration Highlights

| Setting | Value | Why |
|---------|-------|-----|
| Theme | **Aurora Abyss** | Custom dark theme — deep navy base, lavender primary, teal secondary |
| Default model | `zai/glm-5.1` | High thinking enabled for deep reasoning |
| Compaction | Disabled | Full conversation context retained |
| Thinking block | Hidden | Clean output, thinking happens silently |
| Web search | `summary-review` | Fetch → summarize → review workflow |
| Follow-up mode | `one-at-a-time` | One question at a time, no barrage |
| Double-escape | Interrupt | Two taps kills the running agent |
| Spinner | Minimal | No animation, no verb display |

> **Theme colors:** `#191724` base · `#c4a7e7` primary · `#9ccfd8` secondary · `#eb6f92` accent · `#f6c177` warning
