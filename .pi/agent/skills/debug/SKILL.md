---
name: debug
description: Dig into an error or problem, perform root-cause analysis, and create independent fix tasks for each root cause. Use when the user asks to debug an error, investigate a problem, or troubleshoot an issue.
argument-hint: "The error message, stack trace, or problem description to investigate"
---

# Debug

Investigate an error or problem, trace it to its root causes, and create independent actionable fix tasks for each root cause.

## Delegation

**Always delegate to a subagent.** Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Debug: <brief summary of the problem>"
- `prompt`: the investigation instructions below

## Principles

- **Go deep, not wide.** Follow the causal chain until you reach the true root cause.
- **Be evidence-based.** Read the actual code, logs, stack traces. State what you found, not what you assume.
- **One root cause = one task.** Create one task per root cause, each independently fixable.
- **Tasks must be actionable.** Include exact file(s), the problem, and a concrete fix description.
- **Do not fix anything during investigation.** This skill is for analysis and task creation only.

## Building the Subagent Prompt

Pass these instructions to the general-purpose subagent:

```
Investigate this error/problem and trace it to root causes, then create fix tasks for each root cause.

**Problem to investigate:**
$ARGUMENTS

## Phase 1: Reproduce & Understand the Symptom

1. Parse the input — error message, stack trace, problem description, or scenario.
2. If a stack trace is provided, extract the file paths and line numbers.
3. If a scenario is described, identify the relevant code area (endpoint, component, module, service).
4. Read the relevant files and surrounding context to understand what's happening at the failure point.

## Phase 2: Trace the Causal Chain

Follow the chain backward from the symptom:

1. Start at the failure point — the error location, the broken behavior, the failing test.
2. Ask "why?" — What caused this to fail? Bad input? Missing null check? Wrong assumption? Race condition? Missing config?
3. Follow the data flow — trace inputs backward. Where did the data come from? Was it transformed correctly upstream?
4. Check for contributing factors — environment config, missing migrations, dependency versions, timing issues, edge cases.
5. Stop when you reach a root cause — something that, if fixed, would prevent the symptom.

For each step, read the relevant code. Do not guess — verify by reading the actual implementation.

## Phase 3: Summarize Findings

Present a clear root-cause analysis:

### Symptom
[What was reported]

### Investigation Trail
1. [What you checked and found]
2. [What that led you to check next]
3. [Continue until root cause]

### Root Cause(s)

**Root Cause 1: [Title]**
- **File:** path/to/file.ext:line
- **What's wrong:** [Precise description]
- **Why it matters:** [Impact if unfixed]

## Phase 4: Create Fix Tasks

For each root cause, create a task using TaskCreate:

1. Create one task per root cause with:
   - **subject:** prefixed with [debug] (e.g. "[debug] Add null guard before mapping orders response")
   - **description:** file path, line range, what's wrong, the concrete fix needed, edge cases, how to verify
   - **metadata:** { priority: "urgent"|"high"|"medium"|"low", type: "bug"|"chore" }
   - **activeForm:** "Fixing [brief description]" 

## Phase 5: Ask What's Next

After creating tasks, use ask_user_question to ask:
- "Fix tasks one by one" — Start fixing the highest-priority task immediately, then the next sequentially.
- "Just the tasks for now" — Stop here. Tasks are created for later.

If the user chooses to fix: pick highest-priority first, implement the fix, set metadata.reviewStatus to code-review via TaskUpdate, then move to next.

## Edge Cases
- No root cause found: report what was checked, what's unclear, suggest next steps. Create a task for the investigation itself.
- Single root cause: fine — create one task.
- Symptom is external: create a task noting it as external.
- Insufficient info: ask clarifying questions before deep investigation.
```

## After the Subagent Returns

Present the debug analysis and task creation results to the user.
