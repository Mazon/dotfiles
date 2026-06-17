# pi · Agent Coding Configuration

A secure, agent-based AI coding setup built on [pi](https://github.com/nicepkg/pi-coding-agent).

**Sandboxed** · **Permission-gated** · **Worktree-isolated**

Every agent runs inside an OS-level sandbox, behind a default-deny permission system, with the only code-modifying agent confined to an isolated git worktree.

---

## Workflow

The configuration is built around a small, opinionated flow:

```
/idea "Fix login bug"   →  capture as a pending task
/plan                   →  explore codebase, save plan, create dependency-linked tasks
/do                     →  execute tasks in an isolated worktree
/skill:git-pr           →  branch, commit, push, open a pull request
```

> Capture with `/idea` · refine with `/plan` · execute with `/do` · ship with `/skill:git-pr`.

---

## Slash Commands

| Command | Action | Delegates to |
|---------|--------|--------------|
| `/idea <text>` | Capture an idea as a pending task | Direct |
| `/plan <goal \| #id>` | Explore → plan → create linked tasks | Plan |
| `/do <task-id>` | Execute a single task in a worktree | Do |
| `/do-next` | Pick and execute the next unblocked task | Do |
| `/do-all` | Execute all pending tasks in wave order | Do |
| `/ask <question>` | Route chat / analysis to an assistant | Assistant |
| `/init` | Initialize a project (git, README, .gitignore) | Do |
| `/grill-me <topic>` | Interview-style design deep-dive | Reviewer |

## Skills

| Skill | What it does |
|-------|--------------|
| `git-commit` | Stage all changes + commit with an auto-generated message |
| `git-pr` | Branch + commit + push + open a pull request |
| `git-merge` | Verify build, merge branch, update task status |
| `review` | Structured code review with severity ratings |
| `debug` | Root-cause analysis, creates independent fix tasks |
| `ask-user` | Decision handshake for high-stakes choices |

---

## Security Architecture

Agent actions are constrained by three independent layers.

### 1. OS-Level Sandbox

| Layer | Policy |
|-------|--------|
| Network | Deny-by-default; only `localhost` / `127.0.0.1` allowed |
| PID namespace | Isolated — agents cannot see host processes |
| Seccomp filter | UNIX domain socket creation blocked via BPF |
| Root filesystem | Read-only bind mount |

**Write-masked:** `~/.ssh`, `~/.gnupg`, `~/.config`, `~/.bashrc`, `~/.zshrc`, `~/.profile`, `~/.gitconfig`
**Read-denied:** `.env*`, `*.pem`, `*.key`, `~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.config`, `*credentials*.json`, `*.tfstate`, `~/.kube/`, and more

### 2. Permission System

Whitelist-only. Read tools (`read`, `grep`, `find`) are allowed; everything else requires approval. Each agent defines its own permission block that **replaces** — not merges with — the global defaults, so agents receive only the capabilities they need.

### 3. Agent Isolation

| Agent | Write | Edit | Bash | Isolation |
|-------|:-----:|:----:|------|-----------|
| **Do** | ✓ | ✓ | Allow (npm, cargo, git, python…) | **Worktree** — merged on success |
| **Plan** | Ask | ✗ | Deny (allow: git, rg, cat…) | Background |
| **Explore** | ✗ | ✗ | Ask | Background |
| **Reviewer** | ✗ | ✗ | Ask | Background |
| **Assistant** | ✗ | ✗ | Ask | Background |

> The **Do** agent is the only agent that can modify your codebase — and it does so in an isolated git worktree that must be merged explicitly.

---

## Models

Default: **`zai/glm-5.1`** (high reasoning). Available models:

| Provider | Model | Notes |
|----------|-------|-------|
| z.ai | `glm-5.1` | Default, high reasoning |
| z.ai | `glm-5-turbo` | Fast responses |
| z.ai | `glm-5v-turbo` | Vision-capable |
| Google | `gemini-3.1-pro-preview` | Pro-tier Gemini |
| Google | `gemini-3.1-flash-lite` | Lightweight flash |
| llama-server | `Qwen3.6-27B-Q6_K-MTP` | Local, self-hosted |

> The exact set of models varies by user and available API keys.

---

## Configuration Highlights

| Setting | Value | Why |
|---------|-------|-----|
| Compaction | Disabled | Full conversation context retained |
| Thinking block | Hidden | Clean output; reasoning happens silently |
| Web search | `summary-review` | Fetch → summarize → review workflow |
| Theme | Aurora Abyss | Custom dark pastel palette |
| Thinking level | `high` | Default to deeper reasoning |
| Telemetry | Disabled | No data sent on package installs |

---

## Extensions

A curated set of extensions is installed and active:

- **pi-claude-sandbox** — OS-level sandboxing (network, filesystem, PID namespace, seccomp).
- **pi-permission-system** — default-deny, per-agent permission gates.
- **pi-ask-user** — structured decision handshake for high-stakes choices.
- **pi-tasks / pi-subagents** — task tracking and parallel subagent execution.
- **pi-skills-sh** — shell-driven skills (`git-commit`, `review`, `debug`, …).
- **pi-web-access** — web search and the `librarian` research skill.
- **pi-nvim-buffer / pi-msgpack-rpc** — Neovim editor integration.
- **pi-qol** — quality-of-life UI: notifications, session rename, pending queue.
- **pi-usage-stats / pi-zai-usage** — local token and cost tracking per session.

---

## Layout

```
agent/
├── agents/      # Do, Plan, Explore, Reviewer, Assistant
├── extensions/  # installed extensions and providers
├── prompts/     # slash command prompts (idea, plan, init, …)
├── skills/      # reviewable, composable skills
├── themes/      # Aurora Abyss palette
├── models.json  # custom model providers
├── sandbox.json # filesystem / network sandbox policy
└── settings.json
```
