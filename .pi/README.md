# ~/.pi — Personal Pi Configuration

Configuration for [pi](https://github.com/nicepkg/pi-coding-agent), the AI coding agent.

## Models

| Provider | Model | Notes |
|----------|-------|-------|
| **zai** (default) | `glm-5.1` | Default model, high thinking |
| zai | `glm-5-turbo` | Faster variant |
| zai | `glm-5v-turbo` | Vision model |
| google | `gemini-3.1-pro-preview` | |
| google | `gemini-3.1-flash-lite` | |
| google | `gemini-3.5-flash` | |
| llama-cpp (local) | auto-discovered | Local models via llama.cpp server |

## Agents

| Agent | Purpose | Isolation | Edits Files? |
|-------|---------|-----------|-------------|
| **Assistant** | Chat, Q&A, writing, analysis | Background | No |
| **Explore** | Read-only code search & pattern discovery | Background | No |
| **Plan** | Gathers context → creates actionable plans | Foreground | No |
| **Do** | Implements, builds, tests | Background + worktree | Yes |
| **Reviewer** | Code review (correctness & security) | Background | No |

## Skills

| Command | What It Does | Delegates To |
|---------|-------------|-------------|
| `/skill:review` | Review PR, branch, task, or working tree | Reviewer |
| `/skill:debug` | Root-cause analysis → creates fix tasks | general-purpose |
| `/skill:git-commit` | Stage + commit with auto-generated message | Do |
| `/skill:git-pr` | Branch + commit + push + open PR | Do |
| `/skill:git-merge` | Verify build → merge → update tasks | Do |

## Slash Commands

| Command | Purpose | Delegates To |
|---------|---------|-------------|
| `/init` | Initialize project (git, .gitignore, AGENTS.md, README.md) | Do |
| `/plan <goal \| task-id>` | Create an implementation plan | Plan |
| `/do <plan-file \| task-id>` | Execute a plan or task (auto/multi/single modes) | Do (via extension) |
| `/ask <question>` | Route to assistant for chat/analysis | Assistant |
| `/add-task <title>` | Add a pending task | Direct (TaskCreate) |
| `/grill-me <topic>` | Interview-style design deep-dive | Reviewer |

## `/do` Command Modes

The `do-executor` extension provides flexible plan execution:

```
/do <task-id>                 — auto-detect: multi if waves exist, single otherwise
/do <plan-file>               — execute a saved plan file
/do -single <plan \| task>    — one agent for the whole plan
/do -multi <plan \| task>     — agents per wave (parallel within waves)
```

Task IDs can be bare numbers (`5`) or `#`-prefixed (`#5`). Plans are auto-discovered from `.pi/plans/task-<id>-*.md`.

## Task Workflow

Tasks track work through `pending → in_progress → completed`.

```
/add-task "Fix login bug"     → creates a pending task
/plan <task-id>               → Plan agent explores + writes plan to .pi/plans/
  ↳ review the plan
/do <task-id>                 → Do agent executes in an isolated worktree
/skill:review <task-id>       → Reviewer checks the code
/skill:git-pr                 → commit + open PR
```

Tasks support dependencies (`addBlocks`/`addBlockedBy`) and parallel execution — completed tasks auto-trigger unblocked dependents.

## Custom Extensions

### `do-executor` — Plan & Task Execution

Registers the `/do` command and the `parse_plan_waves` tool. Parses plan files programmatically (waves, tasks, specs) and generates precise instructions for the LLM to dispatch Do subagents with proper worktree isolation, branch merging, and task status updates.

### `llama-cpp` — Local Model Provider

Custom provider for locally-running [llama.cpp](https://github.com/ggerganov/llama.cpp) models. Auto-discovers models from the server at `$LLAMA_CPP_URL` (default `localhost:8080/v1`). Falls back to a generic model entry if the server isn't running at startup.

## Packages

| Package | Purpose |
|---------|---------|
| `@tintinweb/pi-subagents` | Subagent orchestration |
| `pi-permission-system` | Per-agent tool/bash/skill permissions |
| `@tmustier/pi-usage-extension` | Usage stats tracking |
| `@tintinweb/pi-tasks` | Task management |
| `@e9n/pi-gmail` | Gmail integration (unread notifications every 5 min) |
| `@e9n/pi-webserver` | HTTP API for pi (port 3100, manual start) |
| `pi-ask-user` | Structured user decision prompts |
| `pi-web-access` | Web search & content fetching |
| `pi-observability` | Performance metrics (TPS, context usage, cost) |
| `pi-skills-sh` | Shell skill support |

## Directory Structure

```
~/.pi/
├── README.md                       # This file
├── settings.json                   # Top-level UI settings (spinner config)
├── web-search.json                 # Web search workflow config
├── agent/
│   ├── settings.json               # Main config: models, packages, providers, integrations
│   ├── auth.json                   # Provider credentials (gitignored)
│   ├── pi-permissions.jsonc        # Global permission policy
│   ├── pi-tps.json                 # Observability/powerline segment config
│   ├── agents/
│   │   ├── Assistant.md            # General-purpose chat agent
│   │   ├── Explore.md              # Read-only code search agent
│   │   ├── Plan.md                 # Planning agent
│   │   ├── Do.md                   # Code execution agent
│   │   └── Reviewer.md             # Code review agent
│   ├── skills/
│   │   ├── debug/SKILL.md          # Root-cause analysis → fix tasks
│   │   ├── git-commit/SKILL.md     # Auto-commit workflow
│   │   ├── git-merge/SKILL.md      # Branch merge workflow
│   │   ├── git-pr/SKILL.md         # PR creation workflow
│   │   └── review/SKILL.md         # Code review lifecycle
│   ├── prompts/
│   │   ├── add-task.md             # /add-task command
│   │   ├── ask.md                  # /ask command
│   │   ├── grill-me.md             # /grill-me command
│   │   ├── init.md                 # /init command
│   │   └── plan.md                 # /plan command
│   ├── extensions/
│   │   ├── do-executor/index.ts    # /do command + parse_plan_waves tool
│   │   ├── llama-cpp.ts            # Local llama.cpp provider
│   │   ├── package.json            # Extension package config
│   │   └── pi-usage-stats/         # Usage stats settings
│   ├── observability/
│   │   └── settings.json           # Observability display config
│   └── sessions/                   # Session history (jsonl)
├── tasks/                          # Task storage
└── subagent-schedules/             # Scheduled subagent jobs
```

## Key Config Files

| File | What's In It |
|------|-------------|
| `agent/settings.json` | Models, packages, theme, compaction, integrations |
| `agent/auth.json` | Provider credentials (gitignored, uses env vars) |
| `agent/pi-permissions.jsonc` | Global default policy + per-tool/bash rules |
| `agent/pi-tps.json` | Observability segments (TPS, context, cost display) |
| `settings.json` | UI-level settings (spinner behavior) |
| `web-search.json` | Web search workflow mode |
| `.pi/tasks/` | Task storage |
| `.pi/plans/` | Implementation plans |

## Permissions Model

Global defaults in `pi-permissions.jsonc`:
- **Read-only tools** (`read`, `grep`, `find`, `ls`) — always allowed
- **Task tools** — mostly allowed, `TaskExecute` requires confirmation
- **Destructive tools** (`write`, `edit`) — require confirmation
- **Bash** — read-only commands allowed, everything else requires confirmation
- **Skills** — `review` allowed, others require confirmation

Each agent overrides these with its own permission block (which replaces, not merges, the global defaults).

## Extending Pi

- **Agent:** `agent/agents/<Name>.md` — Markdown + YAML frontmatter with description and permissions
- **Skill:** `agent/skills/<name>/SKILL.md` — Workflow that delegates to a subagent
- **Prompt:** `agent/prompts/<name>.md` — Named prompt with `$ARGUMENTS` placeholder
- **Extension:** `agent/extensions/<name>.ts` — TypeScript plugin using `ExtensionAPI`
