---
description: Create an implementation plan using the Plan subagent
argument-hint: "<goal or feature description>"
---

Create a detailed implementation plan by launching the Plan agent as a subagent.

**Goal:**

$@

**Instructions:**

Use the `Agent` tool with:
- `subagent_type`: "Plan"
- `description`: "Plan: <brief summary of the goal>"
- `prompt`: the full goal text above, prefixed with: "Analyze this goal and create a comprehensive, step-by-step implementation plan. Explore the codebase to understand the current architecture and dependencies. Break the plan into concrete, ordered steps with clear acceptance criteria. Identify risks, edge cases, and dependencies between steps.\n\n"

Do NOT create the plan yourself. Delegate entirely to the subagent. Once the subagent finishes, present the plan to the user for review and ask if they'd like to proceed with execution using /do.
