# ~/.pi — Personal Pi Configuration

Configuration for [pi](https://github.com/nicepkg/pi-coding-agent), the AI coding agent.

## Agents

| Agent | Purpose | Edits Files? |
|-------|---------|-------------|
| **Assistant** | Chat, Q&A, analysis | No |
| **Explore** | Read-only code search | No |
| **Plan** | Gathers context → writes plans | Plans only |
| **Do** | Implements, builds, tests | Yes (worktrees) |
| **Reviewer** | Code review (correctness & security) | No |

## Skills

| Command | What It Does |
|---------|-------------|
| `/skill:code-review` | Review a PR or branch |
| `/skill:consult` | Architectural advice |
| `/skill:debug` | Root-cause analysis → fix tasks |
| `/skill:git-commit` | Stage + commit with auto-generated message |
| `/skill:git-pr` | Branch + commit + push + open PR |
| `/skill:git-merge` | Verify → merge → update tasks |
| `/skill:review-task` | Review code → update task status |

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/init` | Initialize a project |
| `/plan <goal>` | Create an implementation plan |
| `/do <task-id>` | Execute a task (single) or plan (multi) |
| `/ask <question>` | Route to assistant |
| `/add-task <title>` | Add a pending task |
| `/grill-me <topic>` | Interview-style design deep-dive |

## Task Workflow

Tasks track work through `pending → in_progress → completed`.

```
/add-task "Fix login bug"     → creates a pending task
/plan <task-id>               → Plan agent explores + writes plan to .pi/plans/
  ↳ review the plan
/do <task-id>                 → Do agent executes in an isolated worktree
/skill:review-task <task-id>  → Reviewer checks the code
/skill:git-pr                 → commit + open PR
```

Tasks support dependencies (`addBlocks`/`addBlockedBy`) and parallel execution — completed tasks auto-trigger unblocked dependents.

## Key Config Files

| File | What's In It |
|------|-------------|
| `agent/settings.json` | Model, theme, packages, compaction |
| `agent/auth.json` | Provider credentials (gitignored) |
| `agent/pi-permissions.jsonc` | Per-agent tool permissions |
| `.pi/tasks/` | Task storage |
| `.pi/plans/` | Implementation plans |

## Extending Pi

- **Agent:** `agent/agents/<Name>.md` — Markdown + YAML frontmatter with description and permissions
- **Skill:** `agent/skills/<name>/SKILL.md` — Workflow that delegates to a subagent
- **Prompt:** `agent/prompts/<name>.md` — Named prompt with `$ARGUMENTS` placeholder
- **Extension:** `agent/extensions/<name>.ts` — TypeScript plugin using `ExtensionAPI`
