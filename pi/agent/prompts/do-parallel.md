---
description: Execute a plan in parallel using wave-based dispatch to Do agents
argument-hint: "<plan-file-path>"
---

Execute the plan file in parallel by parsing its waves and dispatching each wave's tasks concurrently to Do subagents.

**Plan file:**

$@

**Instructions:**

1. **Read the plan file** at the path above. If it doesn't exist, report an error and stop.

2. **Parse the waves** — Identify all sections matching `### Wave N`. Extract each wave's tasks (the `- [ ]` checkbox items) and the Detailed Specifications for each task.

3. **Execute waves sequentially, tasks within each wave in parallel:**

   For each wave (in order):

   a. **Launch all tasks simultaneously** — For each task in the wave, use the `Agent` tool with:
      - `subagent_type`: `"Do"`
      - `description`: a short description of the task
      - `prompt`: the task description AND its detailed spec, prefixed with: `"Execute this task step by step. After each step, verify the result before moving to the next. Report a summary when complete.\n\n"`
      - `run_in_background`: `true`
      - `isolation`: `"worktree"` — each subagent gets its own worktree so parallel tasks don't conflict

   b. **Wait for all tasks** — Call `get_subagent_result` with `wait: true` for each launched subagent.

   c. **Check results** — Note successes and failures. If any task failed, report which ones and ask whether to continue or abort. Do NOT proceed to the next wave without confirmation if there are failures.

   d. **Report wave progress** — Briefly summarize what was accomplished before starting the next wave.

4. **Final summary** — After all waves (or on abort), report:

```markdown
## Parallel Execution Complete

**Plan:** [path]
**Total waves:** N
**Total tasks:** N (completed: N, failed: N)

| Wave | Tasks | Status | Notes |
|------|-------|--------|-------|
| 1    | 3     | ✅     | ...   |

### Branches Created
- [any worktree branches from subagents]

### Next Steps
- [recommendations]
```

**Rules:**
- NEVER implement tasks yourself — always delegate to Do subagents
- All tasks in a wave MUST launch before waiting on any (true parallelism)
- Waves are sequential — complete Wave N before starting Wave N+1
- If not in a git repo or worktree fails, omit `isolation` and run subagents in foreground sequentially as fallback
