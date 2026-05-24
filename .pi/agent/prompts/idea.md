---
description: Capture an idea or thought as a pending task for later refinement
argument-hint: "<your idea or task title>"
---

Capture this idea as a pending task for later planning and execution.

Use `TaskCreate` with:
- `subject`: "💡 $ARGUMENTS"
- `description`: "Captured idea. Use /plan #<id> to refine into an actionable plan, or /do #<id> to execute directly."
- `metadata`: { "type": "idea" }

Report the task ID and subject to the user. Suggest: "Run /plan #<id> when ready to refine into a plan, or /do #<id> to start working on it right away."
