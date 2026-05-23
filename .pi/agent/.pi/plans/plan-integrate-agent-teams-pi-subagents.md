# Comprehensive Analysis & Implementation Plan: `agent-team.ts` + `pi-subagents` Integration

## 1. Executive Summary

You have **two completely different agent orchestration systems** that are architecturally incompatible in their current form:

| Aspect | `agent-team.ts` (Your Extension) | `pi-subagents` (npm Package) |
|--------|----------------------------------|-------------------------------|
| **Dispatch mechanism** | Spawns `child_process` via `spawn("pi", args)` | Uses Pi's internal `AgentSession` API |
| **Agent definition** | Custom YAML frontmatter parser (`parseAgentFile`) | Custom `.md` frontmatter + built-in defaults |
| **Communication** | JSON stdout streaming (`--mode json`) | In-process via `AgentManager` + `EventBus` |
| **Tool restriction** | `pi.setActiveTools(["dispatch_agent"])` — locks main agent to dispatch-only | Tools controlled per-agent via frontmatter |
| **State management** | Own `AgentState` map + session files on disk | `AgentRecord` objects in `AgentManager` |
| **UI** | Custom grid widget (`setWidget("agent-team")`) | Built-in agent widget + conversation viewer |
| **Frontmatter fields** | `name`, `description`, `tools`, `systemPrompt` | 17+ fields including `model`, `thinking`, `max_turns`, `isolation`, `memory`, `skills`, etc. |

**Bottom line:** `agent-team.ts` is essentially a **standalone orchestrator that spawns external `pi` processes**. `pi-subagents` is an **in-process sub-agent manager that reuses Pi's session infrastructure**. They solve the same problem at different layers.

---

## 2. Key Incompatibilities

### 2.1 Agent Definition Format Clash

**`agent-team.ts`** parses agents like:
```yaml
---
name: explore
description: Fast codebase exploration
tools: read,grep,find,ls
systemPrompt: ... # INLINE in frontmatter
---
```

**`pi-subagents`** expects:
```yaml
---
description: Fast codebase exploration
tools: read, bash, grep, find, ls
model: haiku
thinking: low
prompt_mode: replace
---
You are a read-only exploration agent... # Body is system prompt
```

Your agent files (`agents/*.md`) use `name` + `systemPrompt` in frontmatter. pi-subagents expects the body after frontmatter to BE the system prompt. These are **different parsing conventions**.

### 2.2 Dispatch Mechanism Clash

- **`agent-team.ts`**: Calls `dispatchAgent()` → `spawn("pi", [...args])` → child process → parses JSON stdout
- **`pi-subagents`**: Calls `AgentManager.spawn()` → creates in-process `AgentSession` → runs within the same Pi instance

These are fundamentally different execution models. They cannot both own the `dispatch_agent` tool simultaneously.

### 2.3 Frontmatter Field Gaps

Your agent files are **missing critical fields** that pi-subagents uses:
- `prompt_mode` (replace vs append)
- `model` (your agents don't specify models)
- `thinking` level
- `max_turns`
- `isolation` (worktree support)
- `memory` scope
- `skills` preloading
- `extensions` (MCP/extension tool inheritance)
- `run_in_background`

### 2.4 Permission System Conflict

Your agents use a `permission:` block (`tools: {read: allow, write: deny}`) that is specific to `pi-permission-system`. `pi-subagents` uses `tools:` frontmatter as a simple comma-separated list. These are **different permission models**.

---

## 3. Integration Options

### Option A: **Replace `agent-team.ts` dispatch with pi-subagents RPC** (Recommended)

Keep `agent-team.ts` for its UI (grid dashboard, team selection, footer) but replace its `dispatchAgent()` implementation to use pi-subagents' cross-extension RPC instead of spawning child processes.

**How it works:**
1. `agent-team.ts` listens for `subagents:ready` event
2. When dispatching, it emits `subagents:rpc:spawn` instead of `spawn("pi", ...)`
3. It listens for `subagents:completed` / `subagents:failed` events to update the grid widget
4. The team system filters which agents are available

**Pros:** Reuses pi-subagents' battle-tested session management, worktree isolation, graceful turn limits, concurrency control, conversation viewer
**Cons:** Requires pi-subagents to be running; grid widget needs rewrite to consume event data instead of child process stdout

### Option B: **Make `agent-team.ts` use pi-subagents' `AgentManager` directly**

Import the `AgentManager` and call `spawn()`/`spawnAndWait()` directly instead of using the RPC layer.

**Pros:** Tighter integration, more control
**Cons:** Tight coupling to pi-subagents internals, breaks when pi-subagents updates

### Option C: **Run them side-by-side (NOT recommended)**

Both extensions coexist. `agent-team.ts` uses its own `dispatch_agent` tool while pi-subagents registers its own `Agent` tool.

**Cons:** Main agent gets confused with two dispatch mechanisms; `setActiveTools(["dispatch_agent"])` in agent-team.ts would HIDE the `Agent` tool from pi-subagents, breaking it completely.

---

## 4. Recommended Implementation Plan (Option A)

### Step 1: Update Agent Definition Files

**Goal:** Make `agents/*.md` files compatible with BOTH systems.

**Changes needed for each agent file:**

The current files use `name:` + `systemPrompt:` in frontmatter. We need to:
1. Remove `name:` (filename becomes the name in pi-subagents)
2. Move system prompt from `systemPrompt:` frontmatter field to the **body** of the markdown
3. Remove `systemPrompt:` from frontmatter
4. Add `prompt_mode: replace` (since these are standalone agent prompts)
5. Ensure `tools:` is a simple comma-separated list (it already is)
6. Add `extensions: false` for read-only agents (Explore, Plan, Reviewer, Assistant)
7. Add `skills: false` for agents that don't need skills

**Example transformation for `Explore.md`:**

Before:
```yaml
---
description: Explore Agent - fast read-only codebase search
tools: read,bash,grep,find,ls
systemPrompt: |
  # Explore Agent
  You are a read-only exploration agent...
---
```

After:
```yaml
---
description: Explore Agent - fast read-only codebase search and pattern discovery
tools: read, bash, grep, find, ls
prompt_mode: replace
extensions: false
skills: false
run_in_background: true
---

# Explore Agent
You are a read-only exploration agent...
```

**Risk:** The `permission:` block used by `pi-permission-system` is NOT recognized by pi-subagents. If you rely on `pi-permission-system` for fine-grained bash allowlisting, you'll lose that granularity. Pi-subagents uses a simpler `tools:` list.

**Acceptance criteria:**
- [ ] All 5 agent files (`Assistant.md`, `Do.md`, `Explore.md`, `Plan.md`, `Reviewer.md`) have body-based system prompts
- [ ] No `name:` or `systemPrompt:` in frontmatter
- [ ] Each has `prompt_mode: replace`
- [ ] `tools:` is comma-separated with spaces
- [ ] `extensions:` and `skills:` explicitly set

### Step 2: Create the Teams Configuration

**Goal:** Define team composition in `.pi/agents/teams.yaml`.

Since `agent-team.ts` already reads from `.pi/agents/teams.yaml`, create this file:

```yaml
engineering:
  - Explore
  - Plan
  - Do
  - Reviewer

full:
  - Assistant
  - Explore
  - Plan
  - Do
  - Reviewer

analysis:
  - Explore
  - Plan
  - Reviewer
```

**Note:** Agent names must match the filenames (without `.md`), which is how pi-subagents discovers them. The current `agent-team.ts` matches by `name:` frontmatter — after step 1, it needs to match by filename instead.

**Acceptance criteria:**
- [ ] `.pi/agents/teams.yaml` exists with team definitions
- [ ] Team member names match agent filenames (case-insensitive)

### Step 3: Rewrite `agent-team.ts` to Use pi-subagents RPC

**Goal:** Replace the `child_process.spawn` dispatch with pi-subagents' cross-extension RPC event bus.

**Key changes:**

1. **Remove:** `spawn` import from `child_process`
2. **Remove:** `dispatchAgent()` function (the child_process version)
3. **Add:** Event bus integration:
   ```typescript
   let subagentsReady = false;
   
   pi.events.on("subagents:ready", () => { subagentsReady = true; });
   ```
4. **Rewrite** `dispatchAgent()` to use RPC:
   ```typescript
   function dispatchAgent(agentName: string, task: string, ctx: any): Promise<{output: string, exitCode: number, elapsed: number}> {
     return new Promise((resolve) => {
       const requestId = crypto.randomUUID();
       
       // Listen for spawn reply (gets agent ID)
       const unsubReply = pi.events.on(`subagents:rpc:spawn:reply:${requestId}`, (reply) => {
         unsubReply();
         if (!reply.success) {
           resolve({ output: `Spawn failed: ${reply.error}`, exitCode: 1, elapsed: 0 });
           return;
         }
         const agentId = reply.data.id;
         // Track agentId for this agent name...
       });
       
       pi.events.emit("subagents:rpc:spawn", {
         requestId,
         type: agentName,
         prompt: task,
         options: { description: task.slice(0, 50), run_in_background: false },
       });
     });
   }
   ```
5. **Update widget** to consume `subagents:started`, `subagents:completed`, `subagents:failed` events instead of parsing child process stdout.
6. **Remove:** `setActiveTools(["dispatch_agent"])` — this is the CRITICAL conflict. Instead, keep `dispatch_agent` as a registered tool alongside pi-subagents' `Agent` tool. OR remove `dispatch_agent` entirely and have the system prompt tell the main agent to use the `Agent` tool with team-filtered types.

**Acceptance criteria:**
- [ ] No `child_process.spawn` calls in the extension
- [ ] Dispatch goes through `subagents:rpc:spawn` event
- [ ] Widget updates from `subagents:completed` / `subagents:failed` events
- [ ] Grid dashboard still renders agent cards with status

### Step 4: Handle the `setActiveTools` Conflict

**Goal:** Allow both extensions to coexist without tool lockout.

**The problem:** `agent-team.ts` calls `pi.setActiveTools(["dispatch_agent"])` in `session_start`, which removes ALL other tools including pi-subagents' `Agent` tool.

**Solutions (pick one):**

**4a. Remove `setActiveTools` entirely.** Let the main agent keep all tools and use system prompt instructions to guide behavior. The system prompt already says "You do NOT have direct access to the codebase" — rely on prompt adherence.

**4b. Use `setActiveTools(["dispatch_agent", "Agent"])` — but this won't work** because `Agent` is registered by pi-subagents after `session_start`, so it may not be in the tool list yet.

**4c. (Recommended) Replace `dispatch_agent` tool with a thin wrapper around the `Agent` tool.** Remove the custom `dispatch_agent` tool registration. Instead, in the `before_agent_start` system prompt override, instruct the main agent to use pi-subagents' `Agent` tool with specific `subagent_type` values filtered to the active team. Use pi-subagents' RPC to validate the type is in the team before the agent is spawned.

**Acceptance criteria:**
- [ ] pi-subagents' `Agent` tool is available and functional
- [ ] The main agent can dispatch to team members
- [ ] No tool lockout occurs

### Step 5: Fix the `applyExtensionDefaults` Call

**Goal:** Remove or replace the broken import.

The extension calls `applyExtensionDefaults(import.meta.url, _ctx)` but the import is commented out (`//import { applyExtensionDefaults } from "./themeMap.ts"`). This will cause a runtime error.

**Options:**
- Remove the call entirely if it's not needed
- Or create the `themeMap.ts` file with a proper implementation

**Acceptance criteria:**
- [ ] No runtime errors from missing `applyExtensionDefaults`

### Step 6: Handle Agent Name Mapping

**Goal:** Bridge the name resolution between agent-team's team YAML and pi-subagents' agent type discovery.

`agent-team.ts` reads team members from `teams.yaml` (e.g., `Explore`). `pi-subagents` discovers agents from `.pi/agents/*.md` where the **filename** (minus `.md`) is the type name. 

Currently your agent files live in `agents/` (project root), not `.pi/agents/`. pi-subagents only looks in:
1. `.pi/agents/<name>.md` (project)
2. `~/.pi/agent/agents/<name>.md` (global)

**Solution:** Either:
- Move/symlink agent files to `.pi/agents/`
- Or keep them in `agents/` and have `agent-team.ts`'s `scanAgentDirs()` also scan `agents/` (it already does — but pi-subagents doesn't)

**Acceptance criteria:**
- [ ] pi-subagents can discover all agents defined in team YAML
- [ ] Agent types in `teams.yaml` match discoverable agent names

### Step 7: Merge Widget Systems

**Goal:** Prevent UI conflicts between agent-team's grid widget and pi-subagents' built-in widget.

Both extensions register widgets. You have options:
- **Disable pi-subagents' widget** and keep agent-team's grid (requires pi-subagents to support widget suppression — check if it does)
- **Disable agent-team's grid** and rely on pi-subagents' widget (loses team-specific grid layout)
- **Keep both** (might look cluttered)

**Recommendation:** Replace agent-team's grid widget with a custom implementation that pulls data from pi-subagents events. Listen to `subagents:started`, `subagents:completed`, `subagents:failed` to update cards.

**Acceptance criteria:**
- [ ] No visual conflicts in the TUI
- [ ] Agent status is visible and updates in real-time

---

## 5. Dependency Graph

```
Step 5 (fix applyExtensionDefaults) ─── no dependency
Step 1 (update agent files)          ─── no dependency
Step 2 (create teams.yaml)           ─── depends on Step 1 (names must match)
Step 6 (agent name mapping)          ─── depends on Step 1, Step 2
Step 3 (rewrite dispatch)            ─── depends on Step 1, Step 6
Step 4 (setActiveTools conflict)     ─── depends on Step 3
Step 7 (merge widgets)               ─── depends on Step 3, Step 4
```

## 6. Quick Win: Minimum Viable Integration

If you want the fastest path to getting them working together:

1. **Fix the crash:** Comment out `applyExtensionDefaults(import.meta.url, _ctx)` line
2. **Move agents:** Copy `agents/*.md` → `.pi/agents/*.md` and reformat frontmatter
3. **Remove `setActiveTools`** call from `session_start` handler
4. **Remove `dispatch_agent` tool registration** — let pi-subagents' `Agent` tool handle dispatching
5. **Keep the system prompt override** in `before_agent_start` but change it to instruct using the `Agent` tool with team-filtered types
6. **Keep the grid widget** but update it to listen to `subagents:*` events instead of child process stdout

This gives you team management + grid dashboard powered by pi-subagents' execution engine.

---

## 7. Risks & Edge Cases

| Risk | Severity | Mitigation |
|------|----------|------------|
| `permission:` frontmatter block lost when switching to pi-subagents format | High | Either keep pi-permission-system active alongside, or add `disallowed_tools` to agent frontmatter for critical restrictions |
| `applyExtensionDefaults` is called but not imported — runtime crash | Critical | Fix in Step 5 first |
| Agent files in `agents/` not discovered by pi-subagents | High | Move to `.pi/agents/` or create symlinks |
| `setActiveTools(["dispatch_agent"])` hides pi-subagents' `Agent` tool | Critical | Must remove or modify |
| Do agent uses `isolation: worktree` which needs pi-subagents' worktree support, not agent-team's | Medium | pi-subagents supports worktree natively — just pass `isolation: "worktree"` in options |
| pi-subagents may not honor `permission:` block from agents/*.md | Medium | pi-subagents uses its own simpler tool restriction model |
| The `Do.md` agent uses `TaskCreate`, `TaskList`, etc. tools — pi-subagents needs these registered | Medium | These come from `pi-tasks` package already installed; ensure `extensions: true` for Do agent |
| Background agent completion notifications from pi-subagents may conflict with agent-team's notification system | Low | Unify through event bus |
| `import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"` vs `@earendil-works/pi-coding-agent` — different package scopes | Low | agent-team.ts uses `@mariozechner`, do-executor uses `@earendil-works`. Both should work as they resolve to the same runtime |
