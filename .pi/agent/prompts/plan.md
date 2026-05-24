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
- `prompt`: the full goal text above, prefixed with: "Analyze this goal and create a comprehensive, step-by-step implementation plan. Explore the codebase to understand the current architecture and dependencies. Break the plan into concrete, ordered steps with clear acceptance criteria. Identify risks, edge cases, and dependencies between steps.\n\nSave the plan to .pi/plans/ and create tasks in the task tracker with proper dependency links.\n\n"

The Plan agent will explore the codebase, save the plan to `.pi/plans/`, create tasks with dependencies, and return a summary. Present the summary to the user.

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
- `prompt`: the goal text from Step 2, prefixed with: "Analyze this goal and create a comprehensive, step-by-step implementation plan. Explore the codebase to understand the current architecture and dependencies. Break the plan into concrete, ordered steps with clear acceptance criteria. Identify risks, edge cases, and dependencies between steps.\n\nSave the plan to .pi/plans/ and create tasks in the task tracker with proper dependency links.\n\n"

The Plan agent will handle saving and task creation. Present the summary to the user.
