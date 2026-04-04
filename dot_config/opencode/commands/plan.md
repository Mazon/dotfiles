# Plan Command

Spawn the planning subagent to create or update an actionable plan.

## Usage

### Create a plan from current conversation
```
/plan
```
Spawns the planning subagent, passing the full conversation context. The planning subagent gathers additional context, analyzes dependencies, and creates a structured plan file.

### Create a plan with a specific description
```
/plan <description>
```
Example: `/plan add authentication with OAuth2`
Spawns the planning subagent with the provided description as the planning objective.

---

## Implementation Instructions

When this command is invoked by the Prime agent:

### 1. Determine the planning objective

Parse the command to determine what to plan:
- If `/plan` with no argument: Use the current conversation context as the planning objective
- If `/plan <description>`: Use the provided description as the planning objective

### 2. Spawn planning subagent via Task tool

Use the Task tool to spawn the planning subagent:

```
Task(
  description="Create action plan",
  prompt="[The planning objective from step 1]",
  subagent_type="planning"
)
```

The planning subagent will:
1. Gather context using read, glob, grep, and webfetch tools
2. Spawn explore subagents for complex searches if needed
3. Analyze task dependencies and build a DAG
4. Write the plan to the plan file with wave-based progress checkboxes
5. Return a structured summary

### 3. After planning subagent returns

**Re-read the plan file** to get the current state.

**Sync todowrite** — Call `todowrite` with items matching the plan file checkboxes:

| Plan File | todowrite status |
|-----------|-----------------|
| `[ ]`    | `pending`       |
| `[-]`    | `in_progress`   |
| `[x]`    | `completed`     |

### 4. Present results to user

```markdown
## Plan Created

**Objective:** [From Purpose section]
**Total tasks:** N across N waves

**Wave breakdown:**
- Wave 1: [N tasks — description]
- Wave 2: [N tasks — description]
- ...

**Key decisions:** [From Decision Log]

**Next steps:**
- Use `/do` to execute the plan (auto-detects sequential or parallel based on wave structure)
- Use `/do --single` to force sequential execution
- Use `/review` to analyze existing changes first
```

---

## Error Handling

### Planning subagent reports failure
```
Planning failed: [reason]
Try providing more context or a more specific description.
```

### Unable to create plan file
```
Error: Could not create the plan file.
Check that the .opencode/plans/ directory exists and is writable.
```

---

## Notes for Prime Agent

- **Planning subagent writes the plan file** — Prime does not write plan content
- **Prime syncs todowrite** after planning completes
- **Conversation context is passed via prompt** — planning subagent has access to read/glob/grep for additional context
- **Planning subagent may spawn explore subagents** for complex codebase searches
