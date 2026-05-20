/**
 * Next Task Extension — Pick the oldest backlog task and plan it
 *
 * Registers /next-task command that deterministically picks the oldest
 * backlog task, moves it to in-progress, and launches the Plan agent.
 * The plan filename includes the task ID so /do can auto-transition
 * the board status after execution.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("next-task", {
		description:
			"Pick the oldest backlog task, move to in-progress, and plan it",
		handler: async (_args, _ctx) => {
			pi.sendUserMessage(`Execute these steps exactly in order. Do not skip any step.

**Step 1 — List backlog tasks**
Call \`board_list_tasks\` with parameters:
\`\`\`json
{ "status": "backlog", "sortBy": "created_at", "sortOrder": "asc" }
\`\`\`

**Step 2 — Select the oldest task**
Take the FIRST task from the results. If the list is empty, say "No backlog tasks found" and STOP. Do not continue to step 3.

**Step 3 — Get full details**
Call \`board_get_task\` with \`{ "id": <task_id> }\`.

**Step 4 — Move to in-progress**
Call \`board_update_task\` with \`{ "id": <task_id>, "status": "in-progress" }\`.

**Step 5 — Launch Plan agent**
Use the \`Agent\` tool with:
- \`subagent_type\`: "Plan"
- \`description\`: "Plan: <task title>"
- \`prompt\`:
\`\`\`
Create a detailed implementation plan for this task:

Task #<ID>: <TITLE>

<DESCRIPTION>

Save the plan file to .pi/plans/task-<ID>-<slugified-title>.md
The filename MUST start with "task-<ID>-" so the /do command can auto-track board status.
\`\`\`

**Step 6 — Report**
After the Plan agent completes, report:
- Task #<ID>: <title>
- Plan file: <path>
- Brief plan summary (waves, task count)
- "Run /do to execute the plan"`);
		},
	});
}
