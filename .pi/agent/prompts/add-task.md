---
description: Add a new pending task using pi-tasks
argument-hint: "<task title>"
---

Add a new pending task directly using the `TaskCreate` tool.

Use the `TaskCreate` tool with:
- `subject`: "$ARGUMENTS"
- `description`: "Added from /add-task command."

Report the result (including the task ID and subject) to the user. They can then run `/plan` to plan it and `/do` to start working on it.
