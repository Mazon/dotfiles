/**
 * Next Task Extension — Pick the oldest pending task and plan it
 *
 * Registers /next-task command that instructs the LLM to use TaskList/TaskUpdate
 * to find the oldest pending task, move it to in_progress, and create a plan.
 * Uses sendUserMessage to delegate all task operations to the LLM.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("next-task", {
		description:
			"Pick the oldest pending task, move to in_progress, and plan it",
		handler: async (_args, _ctx) => {
			pi.sendUserMessage(
				`Pick up the oldest pending task and plan it. Execute these steps:\n\n` +
					`1. Call \`TaskList\` to get all pending tasks\n` +
					`2. Sort by ID ascending, take the first task. If none, say "No pending tasks found" and STOP.\n` +
					`3. Call \`TaskUpdate\` with \`{ "taskId": "<task_id>", "status": "in_progress" }\`\n` +
					`4. Create a plan using the Plan agent. Save to \`.pi/plans/task-<ID>-<slug>.md\`\n` +
					`5. Call \`TaskUpdate\` with \`{ "taskId": "<task_id>", "metadata": { "planPath": ".pi/plans/task-<ID>-<slug>.md" } }\` to link the plan back to the task.\n` +
					`6. Report: task ID, subject, plan path, summary. Tell the user to run /do to execute.`,
			);
		},
	});
}
