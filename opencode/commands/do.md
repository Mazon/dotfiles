# Do Command

Execute planned tasks — automatically chooses sequential or parallel execution based on plan structure.

## Usage

```
/do                    Auto-detect execution mode (parallel if waves with 2+ tasks + clean tree, else sequential)
/do --single           Force sequential execution (never creates worktrees)
/do <task-description> Execute a specific task (always sequential)
/do wave <N>           Execute a specific wave (parallel within wave if 2+ tasks)
```

---

## Mode Detection Logic

When this command is invoked, apply this decision tree **in order**:

```
1. Parse flags and arguments
   ├─ --single flag present          → MODE = sequential
   ├─ <task-description> provided    → MODE = sequential (single task, no parallelism possible)
   └─ wave <N> provided              → proceed to step 2 with targeted wave only

2. Read the plan file → parse Progress section for wave headers
   ├─ No wave headers found          → MODE = sequential
   └─ Wave headers found             → proceed to step 3

3. Evaluate waves for parallelism
   ├─ All waves have only 1 task     → MODE = sequential
   └─ Some wave has 2+ tasks         → proceed to step 4

4. Pre-flight checks for parallel mode
   ├─ Not a git repo (no .git directory detectable via read/glob)  → MODE = sequential (with warning)
   ├─ Dirty working tree / other checks are deferred to do subagent self-creation
   └─ Waves with 2+ tasks                → MODE = parallel
```

### Pre-flight Warnings

**When auto-detection chooses parallel mode, inform the user:**

```markdown
🚀 **Parallel mode detected:** Wave [N] has [X] independent tasks.
Each task will create its own git worktree for concurrent execution.

Tasks:
- [task 1 description]
- [task 2 description]

Use `/do --single` to force sequential execution instead.
```

**When auto-detection falls back to sequential due to dirty tree:**

```markdown
⚠️ **Parallel mode available but skipped:** Uncommitted changes detected.
Falling back to sequential execution.
Commit or stash changes, then run `/do` again for parallel execution.
```

**When auto-detection falls back to sequential for other reasons (no waves, single-task waves):**

No special warning needed — sequential is the natural mode.

---

## Implementation Instructions

When this command is invoked by the Prime agent:

### 1. Parse flags and arguments

Parse the command to determine execution target and mode:

| Input | Target | Forced Mode |
|-------|--------|-------------|
| `/do` | All pending tasks | Auto-detect |
| `/do --single` | All pending tasks | Sequential |
| `/do <text>` | Tasks matching text | Sequential |
| `/do wave <N>` | Specific wave N | Auto-detect (parallel if wave has 2+ tasks) |

### 2. Read the plan file and parse structure

**Read the plan file to determine:**
- Pending (unchecked) tasks in the Progress section
- Wave headers: `### Wave N — [description]`
- Tasks per wave: count pending tasks under each wave header
- Dependency annotations: `- [ ] Task (depends: X, Y)`

### 3. Apply mode detection logic

Follow the decision tree above to determine MODE (sequential or parallel).

### 4. Execute in chosen mode

#### Sequential Mode

Spawn a single `do` that works through all pending tasks in order.

**Prepare context for do:**

```markdown
## Assignment
Objective: [1-2 sentence summary from the plan file's Purpose section]
Scope: [All pending tasks / specific task matching text / specific wave]
Plan file: [plan file path provided by system]
```

**Spawn do via Task tool:**

```
Task(
  description="Execute tasks",
  prompt="[The minimal context above]",
  subagent_type="do"
)
```

**The subagent will:**
1. Read the plan file to get purpose and tasks
2. Execute tasks sequentially
3. Update checkbox status (`[ ]` → `[-]` → `[x]`)
4. Return a completion report

**After subagent returns:** Re-read the plan file to get the updated checkbox state.

#### Parallel Mode

Execute waves sequentially, tasks within each wave in parallel. Each `do` subagent self-creates its own worktree at startup. The `git-helper` subagent handles only the merge phase.

**For each wave to process:**

##### If wave has 1 task:

```
Spawn a single do (no worktree needed — same as sequential).
Wait for completion.
Update the plan file checkbox.
```

##### If wave has 2+ tasks:

**Step 1: Spawn concurrent do subagents**

Use the Task tool to spawn ALL subagents for this wave IN A SINGLE MESSAGE:

```
Task(
  description="Wave N, Task: [task description]",
  prompt="[Subagent prompt with worktree self-creation instructions]",
  subagent_type="do"
)
```

IMPORTANT: Include ALL Task invocations in one response to achieve true parallelism.

**Subagent prompt for parallel mode:**

```markdown
## Assignment
Objective: [1-2 sentence summary from the plan file's Purpose section]
Your Task: **[task label]** — [task description]
Plan file: [plan file path provided by system] (read-only — do NOT modify)

## Worktree Self-Creation
You must create your own worktree BEFORE doing any other work:

1. Call `use-git-worktree(action: 'create', name: 'wave-N-task-[sanitized-desc]')`
   - Sanitize: lowercase, hyphens, max 40 chars
2. From the response, extract the worktree `path` and `branch`
3. All file operations must use absolute paths rooted at the worktree path
4. If creation fails, report the error immediately and STOP

## Execution
1. Create your worktree (see above)
2. Read the plan file for full task context
3. Execute the task
4. Stage and commit ALL changes: `git add -A && git commit -m '[type](wave-N): [task description]'`
5. Report all modified files with absolute paths
```

**Step 2: Wait for all subagents to complete**

**Step 3: Spawn git-helper for merge phase**

After all tasks in the wave complete, spawn a `git-helper` subagent to merge all worktrees:

```
Task(
  description="Merge wave N worktrees",
  prompt="## Assignment: Merge Phase

Merge the following worktrees into the target branch, one at a time, then clean up.

**Target branch:** main (or the current branch)
**Merge strategy:** theirs (keep worktree changes on conflict)

**Worktrees to merge (in order):**
1. Name: [name1] — Task: [description1] — Status: [success/failed]
2. Name: [name2] — Task: [description2] — Status: [success/failed]

**Instructions:**
- Skip worktrees where the do subagent failed (Status: failed)
- For each successful worktree:
  1. Call use-git-worktree(action: 'merge', name: '[name]', targetBranch: '[target]', mergeStrategy: 'theirs')
  2. If merge has conflicts, resolve them using your judgment
  3. After successful merge, call use-git-worktree(action: 'remove', name: '[name]')
- For failed worktrees, keep them alive for manual review
- Report results in the merge report format defined in your instructions.",
  subagent_type="git-helper"
)
```

**Step 4: Update the plan file**

After ALL merges complete for the wave, update the plan file checkboxes for all tasks in this wave:
- Mark all tasks in the wave as `[x]` (completed)
- Add any surprises to the Surprises & Discoveries section
- If tasks failed, mark as `[-]` with a note

### 5. Update the plan file

- **Sequential mode:** The subagent updates checkboxes directly. Re-read to sync.
- **Parallel mode:** Prime agent updates checkboxes after each wave:
  - Mark all tasks in the wave as `[x]` (completed)
  - Add any surprises to the Surprises & Discoveries section
  - If tasks failed, mark as `[-]` with a note

### 6. Present results to user

**Sync todowrite** — Call `todowrite` with updated plan file checkbox states (see todowrite Sync section in `agents/prime.md` for mapping).

**Sequential mode summary:**

```markdown
## Execution Complete

**Mode:** Sequential

**Tasks Completed:**
- List of tasks that were completed
- Any issues encountered
- Suggestions for next steps

**Current Task State:**
[Read the plan file's Progress section to show updated checkboxes]

**Recommendations:**
- If all tasks complete: "Use /review to analyze changes, or /commit to commit."
- If tasks remain: "Use /do again for remaining tasks."
- If issues found: "Review issues and decide next steps."
```

**Parallel mode summary:**

```markdown
## Execution Complete

**Mode:** Parallel (auto-detected)

**Wave 1 (2 tasks — parallel):**
| Task | Status | Branch | Files Modified |
|------|--------|--------|---------------|
| Task A | ✅ Complete | wave-1/task-a | 3 files |
| Task B | ✅ Complete | wave-1/task-b | 5 files |

**Merge Status:** All branches merged to main. Worktrees cleaned up.

**Wave 2 (1 task — sequential):**
| Task | Status |
|------|--------|
| Task C | ✅ Complete |

**Summary:**
- Total tasks: N
- Completed: N
- Failed: 0
- Merge conflicts: 0

**Recommendations:**
- Use `/review` to analyze all changes
- Or use `/commit` if ready to commit
```

---

## Error Handling

### No plan file found
```
Error: No plan file found in the working directory.
Please create a plan first using /plan.
```

### No pending tasks
```
No pending tasks found. All checkboxes in the plan file are completed.
```

### Task not found (when targeting specific task)
```
Error: Task matching "<text>" not found in the plan file.
Current tasks:
[Show list from the plan file's Progress section]
```

### Wave not found (when targeting specific wave)
```
Error: Wave <N> not found in the plan file.
Available waves:
[Show wave headers from the plan file's Progress section]
```

### Plan file not readable
```
Warning: Could not read the plan file.
do will have limited context.
```

### Worktree creation fails
```
Failed to create worktree for task "X": [error from use-git-worktree]
The do subagent reported failure. Marking task as failed, continuing with remaining tasks.
```

### Subagent reports failure
```
Task "X" in wave 1 failed: [reason]
Attempting merge of completed tasks. Failed task skipped.
```

### Merge conflict
```
⚠️ Merge conflict detected when merging branch "wave-1/task-x":
[conflict details]

The worktree is preserved at: [path]
Options for the user:
  (a) Resolve manually in the worktree, then run `/do` to continue
  (b) Retry with a different merge strategy (git-helper can try 'ours' or 'theirs')
  (c) Skip this worktree and continue with remaining merges
  (d) Abort remaining merges and keep all worktrees for manual review
```

### Dirty working tree (parallel mode pre-flight)
```
⚠️ Parallel mode available but skipped: Uncommitted changes detected.
Falling back to sequential execution.
Commit or stash changes, then run `/do` again for parallel execution.
```

---

## Example Workflows

### Example 1: Auto-detect → Sequential (no waves)
```
User: /do

Agent (Prime) actions:
1. Parse args: no flags, no task description → check plan structure
2. Read plan file → no wave headers found
3. Mode: sequential
4. Spawn single do with all pending tasks
5. Present results

Output: "Execution Complete (sequential mode). All 3 tasks finished."
```

### Example 2: Auto-detect → Parallel (waves with 2+ tasks)
```
User: /do

Agent (Prime) actions:
1. Parse args: no flags → check plan structure
2. Read plan file → Wave 1 has 2 tasks, Wave 2 has 2 tasks
3. Pre-flight: check .git directory → exists
4. Mode: parallel
5. Execute Wave 1 (2 tasks, each self-creates worktree, then git-helper merges)
6. Execute Wave 2 (2 tasks, each self-creates worktree, then git-helper merges)
7. Present results

Output:
🚀 Parallel mode detected: Wave 1 has 2 independent tasks.
Each task will create its own git worktree for concurrent execution.
[... execution ...]
Execution Complete (parallel mode). 4 tasks across 2 waves.
```

### Example 3: Force sequential with --single
```
User: /do --single

Agent (Prime) actions:
1. Parse args: --single flag → MODE = sequential (forced)
2. Spawn single do (no worktrees, regardless of wave structure)
3. Present results

Output: "Execution Complete (sequential mode, forced by --single)."
```

### Example 4: Target specific task
```
User: /do implement auth service

Agent (Prime) actions:
1. Parse args: task description provided → MODE = sequential (always)
2. Find matching task in plan file
3. Spawn do for that specific task
4. Present results

Output: "Auth service task completed. 2 tasks remaining."
```

### Example 5: Target specific wave
```
User: /do wave 2

Agent (Prime) actions:
1. Parse args: wave 2 targeted → check wave 2 structure
2. Read plan file → Wave 2 has 2 tasks
3. Pre-flight: check .git directory → exists
4. Mode: parallel (within wave 2)
5. Execute Wave 2 only
6. Present results

Output: "Wave 2 complete (parallel, 2 tasks). 2 tasks remain in other waves."
```

---

## Integration with Other Commands

After `/do` completes, suggest appropriate next steps:

| Situation | Suggested Command |
|-----------|------------------|
| All tasks complete | `/review` to analyze changes |
| Small changes made | `/commit` to commit |
| More tasks remain | `/do` again for next batch |
| Issues encountered | Review issues, then `/do` to retry |
| After merge conflicts | Resolve manually, then `/do` for remaining tasks |

---

## Important Notes

### Branch Naming Convention (Parallel Mode)
- Use `wave-{N}/task-{sanitized-description}` for worktree branches
- Sanitize: lowercase, replace spaces/special chars with hyphens, max 40 chars
- Example: "Add dark mode CSS variables" → `wave-1/add-dark-mode-css-variables`

### Worktree Limits
- No hard limit on concurrent worktrees — the number is constrained by system resources
- Prime may split very large waves into sub-waves at its discretion

### Subagent Isolation (Parallel Mode)
- Each subagent works in its own worktree — full filesystem isolation
- Subagents should NOT modify the plan file (Prime agent handles all updates)
- Subagents report results back; Prime agent aggregates and updates
- **todowrite is synced by Prime agent after wave completion — subagents do not need to update it**

### Worktree Lifecycle
- `do` subagents self-create worktrees via `use-git-worktree(action: 'create')`. Only the merge phase uses the `git-helper` subagent.
- All worktree operations use the `use-git-worktree` tool — never raw `git worktree` commands
- Cleanup uses `use-git-worktree(action: 'remove')` after successful merge
- No terminal sessions or cmux workspaces are created for parallel worktrees

### Sequential Merge Rationale
- Merges are done one at a time per wave by the `git-helper` subagent, not all at once
- This ensures any conflict is attributed to a specific branch
- If a merge fails, remaining worktrees are preserved for later merging
- Git can merge non-overlapping changes to the same file, so same-file edits from different tasks are handled gracefully

### Notes for Prime Agent
- **Subagent reads the plan file directly** — keep prompts minimal (scope + file path only)
- **Living document** — Both agents read/write to the same plan file
- **todowrite sync** — Prime agent syncs todowrite from the plan file after subagent completes
- **Non-blocking** — User can cancel subagent execution if needed
- **State persistence** — All task status changes are persisted in the plan file
