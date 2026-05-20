---
name: git-pr
description: Create a feature branch off master/develop/main when needed, stage and commit all changes, push, and immediately open a pull request via the gh CLI. Use when the user asks to open a PR, ship changes, or commit and create a pull request.
argument-hint: "Optional summary of the work to ship"
---

# Git PR

Commit all current repository changes and immediately open a pull request. Do not ask the user for confirmation — "open a PR" means do it.

## Delegation

**Always delegate to a Do subagent.** Use the `Agent` tool with:
- `subagent_type`: "Do"
- `description`: "Open pull request"
- `prompt`: the PR instructions below, with the user's argument as context

## Building the Subagent Prompt

Pass these instructions to the Do subagent:

```
Commit all current repository changes and immediately open a pull request. Do not ask for confirmation.

[If the user provided an argument, add: The user describes this work as: $ARGUMENTS]

## 1. Inspect state

Run in parallel:
- git status — what will be staged
- git diff and git diff --stat — the actual changes
- git branch --show-current — the current branch
- git log -5 --oneline — to match commit style

If there is nothing to commit, report that and stop.

## 2. Resolve the working branch and PR base

- If CURRENT is master, main, or develop (protected base branch):
  - The PR base is CURRENT.
  - Create a feature branch: git switch -c feature/<slug>
- Otherwise (already on a feature branch):
  - Stay on CURRENT; do not create a new branch.
  - Determine the PR base: use develop if it exists, otherwise the repo default.

## 3. Stage and commit

- Stage everything: git add -A
- Generate a commit message:
  - Subject ≤ 72 chars, body 2–5 sentences focused on the why.
  - Detect convention from git log (conventional commits, scoped, or plain).
  - No Co-Authored-By lines.
- Commit with HEREDOC.

## 4. Push the branch

git push -u origin <branch>

## 5. Open the pull request

gh pr create --base <base> --head <branch> --title "<subject>" --body with summary and changes.

## 6. Report

Report the PR URL. Verify with git status.

## Failure handling
- If gh is not installed or auth fails, report that and stop after committing.
- If git push fails, report the exact error.
- If a PR already exists for the branch, report the existing PR URL.
```

## After the Subagent Returns

Report the PR URL and status to the user.
