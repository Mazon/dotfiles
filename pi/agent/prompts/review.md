---
description: Review current changes and complete the board task
---

Review the current code changes using the Reviewer agent, then update the board task status based on findings.

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

**Step 4 — Conditionally update task status**
After the review completes, check the findings:

- If the reviewer found **no critical or high** issues → call `board_update_task` with `{ "id": <task_id>, "status": "completed" }` and add a comment: `board_add_comment({ taskId: <task_id>, body: "✅ Reviewed and approved" })`
- If the reviewer found **critical or high** issues → call `board_update_task` with `{ "id": <task_id>, "status": "in-progress" }` and add a comment listing each critical/high issue: `board_add_comment({ taskId: <task_id>, body: "⚠️ Review found issues:\n- [list each critical/high finding]" })`

**Step 5 — Report**
Report the review findings summary and the task's new status. If issues were found, clearly list what needs to be fixed before the task can be completed.
