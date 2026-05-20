---
name: review-task
description: Review code changes for a board task, then update its status based on findings. Use when the user asks to review a task, complete a review cycle, or finish a board task review.
argument-hint: "[optional task ID]"
---

# Review Task

Review the code changes for a board task currently in `code-review` status, then update the task status based on the review findings.

## Delegation

**Always delegate to a subagent.** This is a two-phase process:

1. **Review phase** → delegate to the `Reviewer` subagent
2. **Board update phase** → the main agent updates the board based on findings

## Workflow

### Step 1 — Find the Task

- If a task ID is provided as an argument, fetch it with `board_get_task`.
- Otherwise, call `board_list_tasks` with `{ "status": "code-review" }` and take the first result.
- If no tasks are in `code-review` status, report "No tasks to review" and **stop**.
- If there are multiple tasks, ask the user which one to review.

### Step 2 — Launch the Reviewer Subagent

Use the `Agent` tool with:
- `subagent_type`: "Reviewer"
- `description`: "Review task: <task title>"
- `prompt`: "Review the current code changes in this repository. Focus on the most recent commits and any uncommitted changes. Provide your findings in the standard review format with severity ratings (Critical, High, Medium, Low/Nit)."

### Step 3 — Update the Board Task

After the Reviewer subagent returns, check its findings:

**If the reviewer found NO critical or high issues:**
- `board_update_task({ id: <task_id>, status: "completed" })`
- `board_add_comment({ taskId: <task_id>, body: "✅ Reviewed and approved\n\n[Include review summary]" })`

**If the reviewer found critical or high issues:**
- `board_update_task({ id: <task_id>, status: "in-progress" })`
- `board_add_comment({ taskId: <task_id>, body: "⚠️ Review found issues:\n\n[List each critical/high finding with file, line, and description]\n\n[Include suggested fixes]" })`

### Step 4 — Report

Report to the user:
- Review findings summary (severity counts)
- Task's new status
- If issues were found, list what needs to be fixed before completion

### Step 5 — Fix Issues (only when critical/high issues found)

If the reviewer found critical or high issues, use `ask_user_question` to ask the user if they want to fix the issues now:

- **"Fix issues now"** — Proceed to Step 6 to fix and re-review.
- **"Just flag for now"** — Stop here. The task stays in `in-progress` with the review comment.

If no critical/high issues were found, skip to the end — the task is already completed.

### Step 6 — Fix and Re-review

If the user chose to fix issues:

1. **Delegate to a `Do` subagent** with `isolation: "worktree"`:
   - `subagent_type`: "Do"
   - `description`: "Fix review issues: <task title>"
   - `prompt`: Build a prompt that includes:
     - The original task description (from `board_get_task`)
     - The full list of critical and high issues from the review
     - For each issue: file path, line, description, and suggested fix
     - Instruction: "Fix all listed issues. Do not change unrelated code. After fixing, run any available tests/linters to verify the fixes."

2. **After the Do subagent returns:**
   - If fixes were applied successfully:
     - Merge the worktree branch back (or stage/commit the changes)
     - `board_update_task({ id: <task_id>, status: "code-review" })`
     - `board_add_comment({ taskId: <task_id>, body: "🔧 Fixed review issues:\n\n[List what was fixed]" })`
     - Loop back to **Step 2** to re-review the fixes (the re-review only needs to verify the specific issues were addressed, not a full review).
   - If fixes failed or the subagent couldn't resolve all issues:
     - Keep the task in `in-progress`
     - `board_add_comment({ taskId: <task_id>, body: "⚠️ Could not auto-fix all issues:\n\n[List what still needs manual attention]" })`
     - Report to the user what couldn't be fixed

3. **Re-review loop limit:** After 3 fix+review cycles, stop and report to the user that manual intervention is needed.

## Edge Cases

- **All issues are Low/Nit:** Don't offer to fix — approve and complete the task. Nits can be addressed separately.
- **Mixed severity (Critical + Nits):** Only include Critical and High issues in the fix prompt. Ignore nits.
- **User declines fix:** Task stays in `in-progress`. The review comment serves as a TODO for the developer.
