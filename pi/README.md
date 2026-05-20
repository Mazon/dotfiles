# ~/.pi — My Personal Pi Configuration

This is my personal configuration directory for [pi](https://github.com/nicepkg/pi-coding-agent), the AI coding agent. It holds custom agents, skills, prompts, extensions, and project-level settings that shape how pi works for me.

## Directory Layout

```
~/.pi/
├── agent/
│   ├── agents/          # Custom subagent definitions (Markdown + YAML frontmatter)
│   ├── skills/          # Skill workflows (auto-triggered by commands like /skill:name)
│   ├── prompts/         # Named prompt templates (slash commands)
│   ├── extensions/      # Custom extensions (TypeScript plugins)
│   ├── sessions/        # Per-project conversation session data
│   ├── settings.json    # Agent-level settings (model, theme, packages)
│   ├── auth.json        # Provider credentials (gitignored)
│   └── observability/   # Usage history and monitoring config
```

## How It Works

### The Agent System

Pi uses a **delegation model**. When you give it a task, the main orchestrator agent decides whether to handle it directly or delegate to a specialized subagent:

| Agent | Purpose | Can Edit Files? |
|-------|---------|-----------------|
| **Assistant** | Chat, Q&A, writing, analysis, brainstorming | No |
| **Explore** | Fast read-only codebase search & pattern discovery | No |
| **Plan** | Context gathering → actionable plans with dependency analysis | No (writes plan files only) |
| **Do** | Execute coding tasks — implements, builds, tests | Yes (in isolated worktrees) |
| **Reviewer** | Conservative code review focused on correctness & security | No |

The orchestrator routes work based on intent. Each agent has its own permission profile defined in YAML frontmatter — e.g., the Explore agent can `read`, `grep`, `find`, and `ls` but is denied `write` and `edit`.

### The Workflow

A typical development flow through pi looks like this:

```
1. /init          → Set up a new project (.gitignore, AGENTS.md, README.md)
2. /plan <goal>   → Plan agent explores the codebase and writes a plan to .pi/plans/
3. Review plan    → User reviews and approves the plan
4. /do            → Do agents execute plan tasks (parallelized by wave)
5. /skill:review-task → Reviewer checks the code, updates board status
6. /skill:git-pr  → Commit + open a pull request
```

### Task Board

Pi includes a built-in task board (powered by SQLite). Tasks flow through columns:

```
backlog → in-progress → code-review → uat → completed
```

Board operations are exposed as tools (`board_create_task`, `board_list_tasks`, etc.) that any agent can call. The board tracks sprints, labels, people, and workload.

### Skills

Skills are multi-step workflows triggered by `/skill:<name>`. They live in `agent/skills/<name>/SKILL.md` and always delegate to a subagent:

| Skill | Trigger | What It Does |
|-------|---------|-------------|
| `/skill:code-review` | Review a PR or branch changes | Delegates to Reviewer → structured findings |
| `/skill:consult` | Ask for architectural advice | Delegates to Explore → evidence-based analysis |
| `/skill:debug` | Investigate an error | Traces root causes → creates board tasks per fix |
| `/skill:git-commit` | Commit all changes | Auto-generates message matching repo style |
| `/skill:git-pr` | Ship changes as a PR | Branch + commit + push + `gh pr create` |
| `/skill:git-merge` | Merge branches into main | Verifies build/tests → merges → updates board |
| `/skill:review-task` | Review a board task's code | Reviewer checks code → updates task status |

### Prompts (Slash Commands)

Named prompts in `agent/prompts/` become slash commands:

| Command | Purpose |
|---------|---------|
| `/init` | Initialize a project with .gitignore, AGENTS.md, README.md |
| `/plan <goal>` | Create an implementation plan |
| `/ask <question>` | Route to the general assistant |
| `/add-task <title>` | Add a task to the board backlog |
| `/grill-me <topic>` | Relentless interview to nail down a design |

### Extensions

TypeScript plugins that extend pi at runtime:

- **next-task** — `/next-task` picks the oldest backlog task, moves it to in-progress, and plans it
- **llama-cpp** — Registers a local llama.cpp server as a model provider (auto-discovers models)
- **do-executor** — Custom execution logic for the Do agent
- **pi-usage-stats** — Usage tracking and statistics

## Configuration

### Agent Settings (`agent/settings.json`)

Key fields:
- `defaultModel` — Which LLM to use by default
- `enabledModels` — Available models for switching
- `packages` — npm packages that extend pi (board, permissions, observability, etc.)
- `theme` — UI theme
- `compaction` — Context window compaction settings

### Permissions (`agent/pi-permissions.jsonc`)

Controls what tools each agent can use. For example:
- Explore agent: read-only tools allowed, write/edit denied
- Do agent: all tools allowed, runs in isolated git worktrees
- Assistant: bash requires approval, file edits denied

### Adding a Custom Agent

Create `agent/agents/<Name>.md` with YAML frontmatter:

```markdown
---
description: What this agent does
enabled: true
permission:
  tools:
    read: allow
    bash: ask
    write: deny
---

# Agent Name

Instructions for the agent...
```

### Adding a Skill

Create `agent/skills/<name>/SKILL.md`:

```markdown
---
name: my-skill
description: When to use this skill
argument-hint: "<what argument to expect>"
---

# My Skill

Instructions for the skill workflow, including delegation logic...
```

### Adding a Prompt

Create `agent/prompts/<name>.md`:

```markdown
---
description: What this prompt does
argument-hint: "<expected argument>"
---

Instructions with $ARGUMENTS as placeholder for user input...
```

### Adding an Extension

Create a TypeScript file in `agent/extensions/` implementing the `ExtensionAPI`:

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("my-command", {
    description: "What it does",
    handler: async (args, ctx) => {
      pi.sendUserMessage("Instruction for the LLM...");
    },
  });
}
```

## My Model Setup

Configured models in `settings.json`:
- **Primary:** `zai/glm-5.1` with high thinking level
- **Alternatives:** `zai/glm-5-turbo`, local `llama-cpp/Qwen3.6-27B-Q6_K-MTP`, Google Gemini models
- Transport: auto-detect
- Thinking blocks: hidden by default

## Key Principles

1. **Delegation over monolith** — Each agent has a single responsibility and narrow permissions
2. **Isolation for safety** — Do agents run in git worktrees; code changes don't touch the main tree until merged
3. **Plan before execute** — Plans are written to `.pi/plans/`, reviewed by the user, then dispatched by wave
4. **Board as source of truth** — Tasks track work across the full lifecycle (backlog → completed)
5. **Evidence over opinion** — Agents read actual code before making recommendations
