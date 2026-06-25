---
name: review
description: Review code changes for a task, PR, branch, or current working tree. Auto-detects the target and runs a structured review with severity ratings. For task reviews, manages the full review lifecycle including status updates and optional fix loops.
argument-hint: "<PR URL, branch name, task ID, or nothing to auto-detect>"
---

# Review

Unified code review skill. Reviews code changes and manages the review lifecycle.

## Target Detection

Determine the review target from the argument:

1. **GitHub PR URL** (e.g. `https://github.com/OWNER/REPO/pull/123`) → PR review
2. **PR number** (e.g. `#123`) → PR review
3. **Task ID** (bare number or `#5`) → Task review
4. **No arguments** → Auto-detect: find first task with `metadata.reviewStatus == "code-review"`, or fall back to local branch review

## Delegation

**Always delegate to the general-purpose subagent.** Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Review: <brief description of target>"
- `prompt`: the review instructions below, customized for the target

## Workflow

### Step 1 — Identify the Target

Parse the argument to determine review mode:

| Argument | Mode | Action |
|----------|------|--------|
| PR URL or `#123` | PR review | Gather diff via `gh pr diff` |
| Task ID (`5` or `#5`) | Task review | Fetch task via `TaskGet`, review its changes |
| None | Auto-detect | Check for tasks with `reviewStatus == "code-review"`, else local branch review |

### Step 2 — Gather the Diff

**For PR reviews:**

```
gh auth status
gh pr view <url-or-number> --json title,body,author,baseRefName,headRefName,files,commits,url
gh pr diff <url-or-number>
```

**For task reviews:**

1. Call `TaskGet({ taskId: "<id>" })` to get task details
2. Find the relevant changes — check recent commits and uncommitted changes on the current branch

**For local branch reviews:**

```
git status --short
git branch --show-current
git merge-base HEAD origin/<primary-branch> 2>/dev/null || git merge-base HEAD <primary-branch>
git diff <merge-base>...HEAD
```

### Step 3 — Launch the Review Subagent

Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Review: <target description>"
- `prompt`: "Review the following code changes. Focus on:
  1. Intent — What is the change trying to accomplish?
  2. Correctness — Logic errors, invalid assumptions, broken edge cases
  3. Security — Auth/authz, injection, unsafe input handling, secrets
  4. Reliability — Error handling, retries, null/undefined handling
  5. Data & API compatibility — Breaking changes, schema changes
  6. Testing — Missing coverage for new logic
  7. Performance — N+1 queries, hot path regressions
  8. Maintainability — Unnecessary complexity, duplicated logic

  Use the severity scale: Critical, High, Medium, Low/Nit.

  [Include the diff content or instructions to read the relevant files]"
- `run_in_background`: false

### Step 4 — Handle Results by Mode

#### PR Review

Present the review findings to the user. If the review was for a direct GitHub PR URL and the user hasn't said "do not post", ask if they'd like to post the review as a PR comment.

#### Task Review

After the subagent returns, check its findings:

**If NO critical or high issues:**
- `TaskUpdate({ taskId: <task_id>, status: "completed" })`
- Append review comment: `TaskUpdate({ taskId: <task_id>, description: "<existing>\n\n---\n✅ Reviewed and approved\n\n<review summary>" })`

**If critical or high issues found:**
- `TaskUpdate({ taskId: <task_id>, status: "in_progress" })`
- Append issues: `TaskUpdate({ taskId: <task_id>, description: "<existing>\n\n---\n⚠️ Review found issues:\n\n<list critical/high findings>" })`
- Ask user: "Fix issues now?" via `ask_user_question`

#### Local Branch Review

Present findings as-is. No task lifecycle management.

### Step 5 — Fix & Re-review Loop (task reviews only)

If the user chose to fix issues:

1. **Delegate to a `Do` subagent** with `isolation: "worktree"`:
   - `subagent_type`: "Do"
   - `description`: "Fix review issues: <task title>"
   - `prompt`: Include original task description + full list of critical/high issues with file, line, and suggested fix

2. **After the Do subagent returns:**
   - Merge the worktree branch back
   - `TaskUpdate({ taskId, status: "in_progress", metadata: { reviewStatus: "code-review" } })`
   - Append fix comment to task description
   - Loop back to **Step 3** for re-review

3. **Loop limit:** After 3 fix+review cycles, stop and report that manual intervention is needed.

## Edge Cases

- **All issues are Low/Nit:** Approve and complete (task mode). No fix offer needed.
- **Mixed severity:** Only include Critical and High issues in the fix prompt.
- **No tasks with reviewStatus:** Fall back to local branch review.
- **Multiple tasks awaiting review:** Ask the user which one to review.
- **gh not installed/authed:** Report and stop. Still show review findings.
