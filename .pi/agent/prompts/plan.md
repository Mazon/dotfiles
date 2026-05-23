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

The Plan agent is read-only and will return the full plan in its response. After the subagent finishes:

1. **Present the summary** — Show the Planning Summary section to the user.
2. **Suggest next steps** — Ask the user if they'd like to proceed by running `/save-plan` to save the plan to a file and populate the task tracker.

Do NOT save the plan yourself. Delegate saving and task creation to `/save-plan`.

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

The Plan agent is read-only and will return the full plan in its response. **You are responsible for persisting the plan.**

**Step 4 — Present to user**

Show the Planning Summary to the user. Explain that the plan is ready, and ask if they'd like to proceed by running `/save-plan` to persist the plan and create the required execution tasks in the task tracker.
