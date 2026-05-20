---
name: git-merge
description: Merge unmerged branches into main and update the board. Use when the user asks to merge a branch, clean up branches, or mentions "merge".
argument-hint: "branch name or 'all' to list options"
---

# Merge

Merge completed feature branches into main and update the corresponding board tasks.

## Delegation

**Always delegate to a Do subagent.** Use the `Agent` tool with:
- `subagent_type`: "Do"
- `description`: "Merge branches into main"
- `prompt`: the merge instructions below, customized with the user's argument

## Building the Subagent Prompt

Determine the argument:
- A specific branch name → pass it directly
- "all" or no argument → pass "all"
- The user's argument: `$ARGUMENTS`

```
Merge branches into main and update the board.

**Argument:** $ARGUMENTS

## Step 1 — Find Unmerged Branches

Run: git branch --no-merged main
Filter to task branches if any exist, otherwise show all unmerged.

## Step 2 — If no argument or "all" — List Options

For each unmerged branch:
- git rev-list --count main..<branch>
- git diff main...<branch> --stat
- Try to extract a board task ID from branch name or commit messages.

Report the list and let the user pick which to merge.

## Step 3 — If a specific branch is given — Verify & Merge

1. Verify the branch exists: git branch --list <branch>
2. **Build & test the branch before merging:**
   - git checkout <branch>
   - Run the project's build/test commands (check package.json, Makefile, or similar for the right commands)
   - If build or tests fail:
     - Report the failures with full output.
     - **Do NOT merge.** STOP here.
     - Add a comment to the related board task (if found): "❌ Merge blocked: build/test failed"
   - If build and tests pass, proceed to merge.
3. Merge into main:
   - git checkout main
   - git merge --no-ff <branch> -m "Merge branch '<branch>'"
   - If conflicts occur, report them and STOP — do not auto-resolve.
4. Delete the branch: git branch -d <branch>
5. Clean up worktree: git worktree prune
6. Update the board:
   - Check branch name for patterns: task/<id>-*, task-<id>-*, pi-agent-*
   - For pi-agent-* branches, check commit messages for task references (#123, task 123)
   - If task ID found: board_update_task to "completed", board_add_comment "✅ Merged into main"
   - If no task ID found: search board tasks in code-review or in-progress status for a match
   - If no board match: skip board update

## Step 4 — Report

Confirm: branch name, task ID and title (if found), commits merged, any conflicts.
```

## After the Subagent Returns

Present the merge results to the user.
