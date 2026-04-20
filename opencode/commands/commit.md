# Commit Command

Commit and push changes with proper formatting. Delegates all git operations to the `git-helper` subagent.

## Usage

`/commit`                  — Stage all changes, generate a commit message from the diff, commit and push
`/commit <message>`        — Commit with the provided message and push
`/commit --amend`          — Amend the last commit (only if not yet pushed)

## Implementation Instructions

When this command is invoked by the Prime agent:

### 1. Spawn git-helper subagent

Use the Task tool to spawn a `git-helper` subagent:

Task(
  description="Commit and push changes",
  prompt="## Assignment: Commit Workflow

Execute the commit workflow.

**User-provided message:** [none / the message the user provided]
**Amend mode:** [no / yes if --amend flag present]

**Process:**
1. Run `git status --short` to see what changed
2. Run `git diff` and `git diff --cached` to review changes
3. Generate or use the commit message:
   - If user provided a message: validate it has a proper prefix, use as-is
   - If no message: analyze the diff, select a prefix, write a concise message (under 72 chars)
4. Run `git add -A`
5. Run `git commit -m \"<message>\"`  (or `git commit --amend -m \"<message>\"` if amend mode)
6. Detect upstream and push:
   - Run `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
   - If succeeds: Run `git push`
   - If fails: Run `git push -u origin <branch>`

**Commit Prefixes:** feat, fix, refactor, test, perf, ci, deps, docs, wip, ignore

**Rules:**
- NEVER update git config
- NEVER use --no-verify or --no-gpg-sign
- NEVER use force push unless explicitly requested
- NEVER skip pre-commit hooks

**Error handling:**
- No changes → report 'Nothing to commit — working tree clean'
- Pre-commit hook failure → report the failure
- Push rejected → report and suggest git pull --rebase
- Merge conflicts → DO NOT FIX, notify user

Report results in the commit report format defined in your instructions.",
  subagent_type="git-helper"
)

### 2. Present results

After the git-helper subagent returns:
- Display the commit message, hash, push status, and changed files
- If errors occurred, display them clearly
- Suggest next steps

## Examples

### Example 1: Simple feature commit

User: /commit

Agent (Prime) actions:
1. Spawn git-helper subagent for commit workflow
2. git-helper runs: git status → sees changes
3. git-helper runs: git diff → analyzes changes
4. git-helper generates: "feat: add OAuth2 PKCE authentication flow"
5. git-helper runs: git add -A && git commit && git push
6. git-helper returns: commit hash, push status

Agent presents: "Committed and pushed: feat: add OAuth2 PKCE authentication flow (abc1234)"

### Example 2: No changes

User: /commit

Agent (Prime) actions:
1. Spawn git-helper subagent for commit workflow
2. git-helper runs: git status → clean tree
3. Returns: "Nothing to commit"

Agent presents: "Nothing to commit — working tree clean."
