---
description: Add a new pending task using pi-tasks
argument-hint: "<task title>"
---

Add a new pending task by delegating to a subagent.

Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Add task"
- `prompt`: "Create a new task using the TaskCreate tool with subject: \"$ARGUMENTS\" and description: \"Added from /add-task command.\". After creating the task, report the task ID and subject."

Report the result to the user. They can then run `/plan` to plan it and `/do` to start working on it.
