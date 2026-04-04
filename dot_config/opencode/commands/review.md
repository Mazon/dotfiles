# Review Command

Trigger ensemble code review. All git operations are delegated to the `git-helper` subagent for gathering, then routed to the reviewer ensemble for analysis.

## Usage

`/review`                   — Review uncommitted changes
`/review <file1> <file2>`   — Review specific files
`/review commit`            — Review the most recent commit
`/review commit <hash>`     — Review a specific commit
`/review staged`            — Review staged changes

## Implementation Instructions

When this command is invoked by the Prime agent:

### 1. Determine Review Scope

| Command Variant | What git-helper Does |
|-----------------|----------------------|
| `/review` | `git diff` (uncommitted changes) |
| `/review <files>` | Read the specified files |
| `/review commit` | `git show HEAD` |
| `/review commit <hash>` | `git show <hash>` |
| `/review staged` | `git diff --cached` |

### 2. Spawn git-helper to Gather Context

Task(
  description="Gather review context",
  prompt="## Assignment: Review Gather

Collect git diff/show output for code review.

**Variant:** [default/files/commit/commit-hash/staged]
[If files variant: **Files:** file1.ts, file2.ts]
[If commit-hash variant: **Hash:** the-hash]

Run the appropriate git command and return the raw output.
If no changes found, report 'No changes found.'

Report results in the review gather format defined in your instructions.",
  subagent_type="git-helper"
)

Wait for git-helper to return the diff content.

**If no changes found:** Inform the user and stop. No reviewers needed.

### 3. Spawn Ensemble Reviewers

Use the Task tool to invoke all 3 reviewer subagents **in parallel** with the diff content. Include ALL 3 Task invocations in one response for parallelism.

```markdown
You are participating in an ensemble code review. Please thoroughly review the following code changes:

**Review Scope:** [Brief description: e.g., "Uncommitted changes in auth module"]

**Changes:**
[Insert diff content from git-helper here]

**Review Requirements:**

1. **Analyze thoroughly** using all focus areas:
   - Logic & Correctness (null handling, async issues, race conditions)
   - Security (injection vulnerabilities, auth gaps, secrets)
   - Performance (N+1 queries, memory leaks, blocking operations)
   - API Contracts (breaking changes, type errors)
   - Error Handling (swallowed exceptions, missing cleanup)
   - TypeScript Specific (any usage, unsafe type assertions)

2. **Provide specific findings** in your standard output format with:
   - Severity level (critical/high/medium/low/info)
   - File path and line number
   - Category
   - Clear issue description
   - Code evidence
   - Actionable recommendation

3. **Follow your personality guidelines:**
   - [Alpha] Be conservative - only flag definite issues
   - [Beta] Be balanced - catch obvious and subtle issues
   - [Gamma] Be exploratory - think about edge cases

4. **Return your findings** in the structured format specified in your agent instructions.
```

### 4. Aggregate Findings

Wait for all 3 subagents to complete, then:

1. **Analyze overlap** - Identify:
   - Consensus: Issues found by all 3 reviewers
   - Majority: Issues found by 2/3 reviewers
   - Unique: Issues found by only 1 reviewer

2. **Create ensemble report** using the format:

```markdown
# Ensemble Review Report

**Review Scope:** [Description from step 1]
**Files Reviewed:** N files
**Total Findings:** N critical, N high, N medium, N low, N info

---

## 🔥 Consensus Findings (All 3 Agree)

These issues were flagged by all reviewers - **high confidence**.

### [SEVERITY] Issue Title

**Found by:** Alpha, Beta, Gamma

**File:** `path/to/file.ts:LINE`
**Category:** [Category]

**Issue:**
[Description]

**Evidence:**
```typescript
[code snippet]
```

**Recommendation:**
[What should be done]

---

## ⚡ Majority Findings (2/3 Agree)

These issues were flagged by 2 of 3 reviewers - **strong evidence**.

[Same format as above]

---

## 💡 Unique Catches

Issues found by only one reviewer - valuable insights worth investigating.

### Found by Alpha Only

[Alpha-only findings]

### Found by Beta Only

[Beta-only findings]

### Found by Gamma Only

[Gamma-only findings]

---

## Summary Statistics

| Reviewer | Critical | High | Medium | Low | Info | Total |
|----------|----------|------|---------|-----|------|-------|
| Alpha    | N        | N    | N       | N   | N    | N     |
| Beta     | N        | N    | N       | N   | N    | N     |
| Gamma    | N        | N    | N       | N   | N    | N     |
| **All**  | N        | N    | N       | N   | N    | N     |

**Overlap Analysis:**
- Findings all 3 agree on: N
- Findings 2/3 agree on: N
- Unique findings (1 reviewer): N

---

## Recommendations

1. **Immediate action required:**
   - [List critical issues]

2. **High priority:**
   - [List high-severity issues]

3. **Consider addressing:**
   - [List medium/low issues with consensus]

4. **Investigate further:**
   - [List unique catches worth checking]

---

## Next Steps

- If issues found: Use `/do` to spawn do for fixes
- If approved: Consider using `/commit` to commit changes
- If clarification needed: Continue discussion in Prime agent
```

### 5. Present Results

- Display the complete ensemble report
- Include a clear summary at the top
- Highlight consensus findings prominently
- Suggest appropriate next step (do via /do for fixes, /commit for approval, etc.)

---

## Error Handling

- **No changes found**: If git-helper reports no changes, inform the user
- **File not found**: If specified files don't exist, list available files
- **Invalid commit hash**: If commit hash doesn't exist, show recent commits

---

## Examples

### Example 1: Review uncommitted changes
```
User: /review

Agent (Prime) actions:
1. Spawn git-helper to gather context → git diff
2. git-helper returns diff content
3. Spawn 3 reviewers in parallel with the diff
4. Aggregate findings into ensemble report
5. Present report

Output:
# Ensemble Review Report

**Review Scope:** Uncommitted changes (5 files modified)
**Files Reviewed:** 5
**Total Findings:** 1 critical, 2 high, 1 medium

---

## 🔥 Consensus Findings (All 3 Agree)

### [Critical] SQL injection vulnerability in user query

**Found by:** Alpha, Beta, Gamma

**File:** `src/auth/login.ts:42`
**Category:** Security

**Issue:**
User input is directly interpolated into SQL query without sanitization.

**Evidence:**
```typescript
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

**Recommendation:**
Use parameterized queries or an ORM.

---

[Rest of report...]
```

### Example 2: Review specific files
```
User: /review src/api.ts src/db.ts

Agent (Prime) actions:
1. Spawn git-helper to read the specified files
2. git-helper returns file contents
3. Spawn 3 reviewers in parallel
4. Aggregate findings
5. Present report

Output:
# Ensemble Review Report

**Review Scope:** 2 specified files
**Files Reviewed:** 2
**Total Findings:** 2 high, 1 low

---

[Report continues...]
```
