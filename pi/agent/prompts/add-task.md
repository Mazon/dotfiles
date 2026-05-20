---
description: Add a new task to the board backlog
argument-hint: "<task title>"
---

Add a new task to the board backlog by delegating to a subagent.

Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Add task to board"
- `prompt`: "Create a new task in the board backlog using the board_create_task tool with title: \"$ARGUMENTS\" and status: \"backlog\". After creating the task, report the task ID and title."

Report the result to the user. They can then run `/plan` to plan it and `/do` to start working on it.
