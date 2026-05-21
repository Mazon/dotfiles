---
description: Create an implementation plan using the Plan subagent
argument-hint: "<goal description | task-id>"
---

If the argument ($ARGUMENTS) is a bare number or #prefixed number (e.g. "5" or "#5"), this is a **task ID**. Follow the **Task-ID workflow** below. Otherwise, treat it as a goal description and follow the **Normal workflow**.

---

## Normal Workflow

**Goal:**

$ARGUMENTS

**Instructions:**

Use the `Agent` tool with:
- `subagent_type`: "Plan"
- `description`: "Plan: <brief summary of the goal>"
- `prompt`: the full goal text above, prefixed with: "Analyze this goal and create a comprehensive, step-by-step implementation plan. Explore the codebase to understand the current architecture and dependencies. Break the plan into concrete, ordered steps with clear acceptance criteria. Identify risks, edge cases, and dependencies between steps.\n\n"

Do NOT create the plan yourself. Delegate entirely to the subagent. Once the subagent finishes, present the plan to the user for review and ask if they'd like to proceed with execution using /do.

---

## Task-ID Workflow

The argument is a task ID. Resolve it and plan it:

**Step 1 — Resolve the task**

Strip any leading `#` from `$ARGUMENTS` to get the numeric task ID. Call `TaskGet` with that ID to retrieve the task's `subject` and `description`.

**Step 2 — Build the goal**

Construct the goal text from the resolved task:
- Start with the task `subject`
- If the task has a `description`, append it as additional context

**Step 3 — Launch the Plan agent**

Use the `Agent` tool with:
- `subagent_type`: "Plan"
- `description`: "Plan task #<ID>: <subject>"
- `prompt`: the goal text from Step 2, prefixed with: "Analyze this goal and create a comprehensive, step-by-step implementation plan. Explore the codebase to understand the current architecture and dependencies. Break the plan into concrete, ordered steps with clear acceptance criteria. Identify risks, edge cases, and dependencies between steps.\n\n"
- **Important**: Instruct the subagent to save the resulting plan file to `.pi/plans/task-<ID>-<slug>.md`, where `<slug>` is derived from the task subject: lowercase, spaces replaced with hyphens, all special characters removed (only a-z, 0-9, and hyphens). For example, task #5 with subject "Fix login bug" → `.pi/plans/task-5-fix-login-bug.md`.

**Step 4 — Update the task**

After the subagent finishes and the plan file is saved, call `TaskUpdate` with the task ID and set `metadata.planPath` to the saved plan file path (e.g. `.pi/plans/task-5-fix-login-bug.md`).

**Step 5 — Present to user**

Present the plan to the user for review. Include the task ID and subject in your summary. Ask if they'd like to proceed with execution using `/do`.
