---
name: code-review
description: Perform deep, context-aware code reviews for GitHub pull requests or local branch changes. Use when the user asks to review a PR, analyze pull request changes, review current branch changes, run automated code review, or mentions PR.
argument-hint: "<PR URL, branch, or nothing for current changes>"
---

# Code Review

Review code like a senior engineer: understand the intent, inspect the diff in context, run available checks, identify real risks, and produce actionable feedback with copy-paste-ready handoff prompts.

## Delegation

**Always delegate to the Reviewer subagent.** Use the `Agent` tool with:
- `subagent_type`: "Reviewer"
- `description`: "Code review: <brief description of target>"
- `prompt`: the review instructions below, customized for the target

## Use Cases

```bash
/skill:code-review https://github.com/OWNER/REPO/pull/123
/skill:code-review
Review the current branch against the primary branch
```

## Review Target Detection

Determine the review target from the arguments:

1. **GitHub PR URL** (e.g. `https://github.com/OWNER/REPO/pull/123`) — PR review mode
2. **PR number** (e.g. `PR #123`) — PR review mode
3. **No arguments** — Local branch review mode (current branch against main)

## Building the Subagent Prompt

Pass these instructions to the Reviewer subagent:

### For PR Reviews

```
Review this GitHub pull request. Gather the diff and metadata with:

gh auth status
gh pr view <url-or-number> --json title,body,author,baseRefName,headRefName,files,commits,url
gh pr diff <url-or-number>

Then review the changes following your standard review process. Focus on:
1. Intent — What is the PR trying to accomplish?
2. Correctness — Logic errors, invalid assumptions, broken edge cases
3. Security — Auth/authz, injection, unsafe input handling, secrets
4. Reliability — Error handling, retries, null/undefined handling
5. Data & API compatibility — Breaking changes, schema changes
6. Testing — Missing coverage for new logic
7. Performance — N+1 queries, hot path regressions
8. Maintainability — Unnecessary complexity, duplicated logic

Use the severity scale: Critical, High, Medium, Low/Nit.
```

### For Local Branch Reviews

```
Review the current branch changes against the primary branch (main, master, or develop). Gather the diff with:

git status --short
git branch --show-current
# Determine primary branch (e.g. main, master, or develop)
git merge-base HEAD origin/<primary-branch> 2>/dev/null || git merge-base HEAD <primary-branch>
git diff <merge-base>...HEAD

Then review the changes following your standard review process. Focus on:
1. Intent — What is the change trying to accomplish?
2. Correctness — Logic errors, invalid assumptions, broken edge cases
3. Security — Auth/authz, injection, unsafe input handling, secrets
4. Reliability — Error handling, retries, null/undefined handling
5. Data & API compatibility — Breaking changes, schema changes
6. Testing — Missing coverage for new logic
7. Performance — N+1 queries, hot path regressions
8. Maintainability — Unnecessary complexity, duplicated logic

Use the severity scale: Critical, High, Medium, Low/Nit.
```

## After the Subagent Returns

Present the review findings to the user as-is. The Reviewer produces a structured report with severity ratings, file locations, and recommendations.

If the review was for a direct GitHub PR URL and the user hasn't said "do not post", ask if they'd like to post the review as a PR comment.
