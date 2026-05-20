---
description: Review current changes and complete the board task
---

Review the current code changes using the Reviewer agent, then move the associated board task to completed.

Execute these steps exactly in order:

**Step 1 — Find tasks in code-review**
Call `board_list_tasks` with `{ "status": "code-review" }`.

**Step 2 — Select the task**
Take the FIRST task from the results. If the list is empty, say "No tasks to review" and STOP. If there are multiple, ask which one to review.

**Step 3 — Launch Reviewer agent**
Use the `Agent` tool with:
- `subagent_type`: "Reviewer"
- `description`: "Review: <task title>"
- `prompt`: "Review the current code changes in this repository. Focus on the most recent commits and any uncommitted changes. Provide your findings in the standard review format."

**Step 4 — Move to completed**
After the review completes, call `board_update_task` with `{ "id": <task_id>, "status": "completed" }`.

**Step 5 — Report**
Report the review findings summary and confirm the task has been moved to completed. If the reviewer found critical or high-severity issues, flag them prominently.
