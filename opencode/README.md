# OpenCode Configuration

A structured [opencode.ai](https://opencode.ai) configuration with custom agents, commands, skills, and multi-environment profiles.

## Directory Structure

```
~/.config/opencode/
├── opencode.json          # Core configuration — personal profile (GLM models)
├── agents/                # Agent definitions
│   ├── prime.md           #   Orchestrator — routes tasks to subagents
│   ├── planning.md        #   Plan creator — writes execution plans
│   ├── do.md              #   Task executor — runs planned steps
│   ├── explore.md         #   Code searcher — read-only codebase exploration
│   ├── reviewer-alpha.md  #   Conservative code reviewer
│   ├── reviewer-beta.md   #   Balanced code reviewer
│   ├── reviewer-gamma.md  #   Exploratory code reviewer
│   ├── git-helper.md      #   Git operations specialist
│   └── chat.md            #   Conversational agent — web-enabled Q&A
├── commands/              # Slash command implementations
│   ├── plan.md            #   /plan — create or update an execution plan
│   ├── do.md              #   /do — execute planned tasks in parallel
│   ├── review.md          #   /review — tri-model code review
│   ├── commit.md          #   /commit — generate commit message and push
├── skills/                # Domain-specific skill files
│   ├── api-design-rust.md
│   ├── devops-rust.md
│   ├── documentation.md
│   ├── git-workflows.md
│   ├── rust-async.md
│   ├── rust-basics.md
│   ├── rust-testing.md
│   └── testing.md
└── .opencode/             # Runtime state (plans, history) — gitignored
    └── plugins/
        └── git-worktree.ts
```

## Agents

| Agent | Mode | Role | Model | Key Access |
|-------|------|------|-------|------------|
| `prime` | default | Orchestrator — reads, plans, routes to subagents | glm-5.1 | Read-only, delegates all work |
| `planning` | subagent | Plan creator — researches and writes execution plans | glm-5.1 | Read, write (plans only), web |
| `do` | subagent | Task executor — runs well-defined plan steps | glm-5-turbo | Full read/write/bash |
| `explore` | subagent | Code search — fast read-only codebase exploration | glm-5-turbo | Read-only, restricted bash |
| `reviewer-alpha` | subagent | Conservative review — correctness and security | glm-4.7 | Read-only, restricted bash |
| `reviewer-beta` | subagent | Balanced review — maintainability and patterns | glm-5 | Read-only, restricted bash |
| `reviewer-gamma` | subagent | Exploratory review — architecture and edge cases | glm-5.1 | Read-only, restricted bash |
| `git-helper` | subagent | Git operations — worktree merge, commit workflow, review gathering | glm-5-turbo | Read/write/bash + use-git-worktree |
| `chat` | default | Conversational Q&A | glm-5.1 | Web-only (no file access) |

### Reviewer Ensemble

The three reviewers use a graduated model and temperature strategy:

- **Alpha** — older model (glm-4.7), lowest temperature (0.1) → conservative, precise, high-confidence findings
- **Beta** — mid model (glm-5), moderate temperature (0.2) → balanced, catches both obvious and subtle issues
- **Gamma** — newest model (glm-5.1), highest temperature (0.5) → creative, explores edge cases and architecture

## Commands

| Command | Description |
|---------|-------------|
| `/plan` | Create or update a structured execution plan |
| `/do` | Execute planned tasks (parallel via self-created worktrees) |
| `/review` | Gather diff via git-helper, then run 3-reviewer code analysis |
| `/commit` | Spawn git-helper to generate commit message, commit and push |

## Configuration Profiles

Two standalone configuration files are provided. The active profile is determined by which file is named `opencode.json`. To switch profiles, manually swap the files.

### Personal Profile (`opencode.json`)

This is the **default** active configuration.

- **Models:** GLM family via Z.AI Coding Plan
  - `prime` / `planning` → `zai-coding-plan/glm-5.1`
  - `do` / `explore` → `zai-coding-plan/glm-5-turbo` (faster for execution/search)
  - `reviewer-alpha` → `zai-coding-plan/glm-4.7` (conservative)
  - `reviewer-beta` → `zai-coding-plan/glm-5` (balanced)
  - `reviewer-gamma` → `zai-coding-plan/glm-5.1` (exploratory)
  - `git-helper` → `zai-coding-plan/glm-5-turbo`
  - `chat` → `zai-coding-plan/glm-5.1`
- **MCP:** No MCP servers configured
- **Use case:** Local development without work infrastructure


## Plugins

| Plugin | Purpose |
|--------|---------|
| `git-worktree` | Manages git worktree lifecycle for parallel task execution via `use-git-worktree` tool |
| `opencode-cmux` | Terminal multiplexer integration for concurrent sessions |

The `git-worktree` plugin provides the `use-git-worktree` tool that handles worktree operations (create, merge, remove, preflight) and blocks direct `git worktree` bash commands to ensure managed lifecycle. The `git-helper` subagent and `do` subagents (in parallel mode) call this tool.

