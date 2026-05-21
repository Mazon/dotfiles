---
name: git-commit
description: Stage all repository changes and create a git commit with an auto-generated message after inspecting status, diff, and recent commit style. Use when the user asks to commit changes, save changes in git, stage and commit, or create a commit without needing confirmation.
argument-hint: "Optional summary of the work to commit"
---

# Git Commit

Commit all current repository changes with an auto-generated message. Do not ask the user for confirmation.

## Delegation

**Always delegate to a Do subagent.** Use the `Agent` tool with:
- `subagent_type`: "Do"
- `description`: "Git commit"
- `prompt`: the commit instructions below, with the user's argument as context

## Building the Subagent Prompt

Pass these instructions to the Do subagent:

```
Commit all current repository changes with an auto-generated message. Do not ask the user for confirmation.

If this repo contains app/data/changelog.json, treat changelog maintenance as part of the commit workflow for shipped user-facing changes.

[If the user provided an argument, add: The user describes this work as: $ARGUMENTS]

## Workflow

1. Inspect state in parallel:
   - git status --short — what will be staged
   - git diff --stat and git diff — the actual changes
   - git log -5 --oneline — to match the repo's existing commit style
2. If there is nothing to commit, report that and stop. Do not create an empty commit.
3. If app/data/changelog.json exists, decide whether the staged changes are user-facing enough to warrant a changelog entry
4. If a changelog entry is needed and app/data/changelog.json exists:
   - read the current file format before editing
   - add a new top entry summarizing the shipped behavior in added and fixed
   - use the short hash of the main commit as the version
   - stage the changelog update and create a second focused commit for it
5. Stage everything from the repository root:
   - git add -A
6. Generate a commit message:
   - Detect the commit convention — Check git log -20 --oneline for one of these patterns:
     - Conventional Commits (e.g. feat:, fix:, chore:) — if ≥30% of recent commits follow this style, use it.
     - Prefix-with-scope (e.g. (scope) message, module: message)
     - Plain — no prefix, just a subject line.
   - Subject line is ≤ 72 characters.
   - Body is 2–5 sentences focused on the why more than the what.
   - Do not include Co-Authored-By lines.
7. Commit using a HEREDOC so formatting is preserved.
8. Run git status after the commit to verify success.

## Failure handling
- If a pre-commit hook modifies files, fails, or leaves staged/unstaged changes, report that state.
- Never include Co-Authored-By lines in commit messages.
```

## After the Subagent Returns

Report the commit result to the user — the hash, subject line, and any issues encountered.
