---
description: Add a new task to the board backlog
argument-hint: "<task title>"
---

Create a new task in the board backlog.

Call `board_create_task` with:
- `title`: "$ARGUMENTS"
- `status`: "backlog"

After creating the task, report the task ID and title. You can then run `/next-task` to pick it up, plan it, and start working on it.
