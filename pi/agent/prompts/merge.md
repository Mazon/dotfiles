---
description: Merge unmerged branches into main
argument-hint: "branch name or 'all' to list options"
---

Merge branches into main and update the board.

**Argument:** $ARGUMENTS

**Steps:**

1. **Find unmerged branches**
   Run: `git branch --no-merged main`
   Filter to task branches if any exist, otherwise show all unmerged.

2. **If no argument or argument is "all" — list options**
   For each unmerged branch, show:
   - Branch name
   - Number of commits ahead: `git rev-list --count main..branch`
   - Files changed: `git diff main...branch --stat` (last line only)
   - Board task ID if extractable from branch name or commit messages

   Report the list and let the user pick which to merge.

3. **If a specific branch is given — merge it**
   - Verify the branch exists: `git branch --list <branch>`
   - Switch to main: `git checkout main`
   - Merge with no fast-forward: `git merge --no-ff <branch> -m "Merge branch '<branch>'"`
   - If merge conflicts occur, report them and stop (do not auto-resolve)
   - Delete the branch: `git branch -d <branch>`
   - Try to extract a board task ID:
     - Check the branch name for patterns: `task/<id>-*`, `task-<id>-*`, or `pi-agent-*`
     - For `pi-agent-*` branches, inspect commit messages for task references (e.g. `#123`, `task 123`, `Task #123`)
     - If a task ID is found → update board: `board_update_task({ id: <id>, status: "completed" })` and `board_add_comment({ taskId: <id>, body: "✅ Merged into main" })`
     - If no task ID found → search board tasks in `code-review` or `in-progress` status by title/description for a match and ask the user to confirm
     - If no board match → skip board update, just report the merge

4. **Report**
   Confirm what was merged:
   - Branch name
   - Task ID and title (from board, if found)
   - Commits merged
   - Any conflicts encountered
