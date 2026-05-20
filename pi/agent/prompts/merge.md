---
description: Merge unmerged task branches into main
argument-hint: "branch name or 'all' to list options"
---

Merge task branches into main.

**Argument:** $@

**Steps:**

1. **Find unmerged task branches**
   Run: `git branch --list 'task/*' --no-merged main`

2. **If no argument or argument is "all" — list options**
   For each unmerged branch, show:
   - Branch name
   - Number of commits ahead: `git rev-list --count main..branch`
   - Files changed: `git diff main...branch --stat` (last line only)
   - Board task ID from branch name (e.g., `task/5-add-auth` → task #5)

   Report the list and let the user pick which to merge.

3. **If a specific branch is given — merge it**
   - Verify the branch exists: `git branch --list <branch>`
   - Switch to main: `git checkout main`
   - Merge with no fast-forward: `git merge --no-ff <branch> -m "Merge branch '<branch>'"`
   - If merge conflicts occur, report them and stop (do not auto-resolve)
   - Delete the branch: `git branch -d <branch>`
   - Extract task ID from branch name (e.g., `task/5-add-auth` → `5`)
   - Update board: `board_update_task({ id: 5, status: "completed" })`
   - Add board comment: `board_add_comment({ taskId: 5, body: "✅ Merged into main" })`

4. **Report**
   Confirm what was merged:
   - Branch name
   - Task ID and title (from board)
   - Commits merged
   - Any conflicts encountered
