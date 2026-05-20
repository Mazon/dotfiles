/**
 * Next Task Extension — Pick the oldest backlog task and plan it
 *
 * Registers /next-task command that deterministically picks the oldest
 * backlog task, moves it to in-progress, and launches the Plan agent.
 * The plan filename includes the task ID so /do can auto-track board status.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("next-task", {
		description:
			"Pick the oldest backlog task, move to in-progress, and plan it",
		handler: async (_args, ctx) => {
			// Try to read board data directly via pi.exec
			// Board data is stored by pi-board in the project's data directory
			let boardData: unknown = null;
			try {
				const result = await pi.exec("cat", [".pi-board/data.json"], {
					signal: ctx.signal,
					timeout: 2000,
				});
				if (result.code === 0) {
					boardData = JSON.parse(result.stdout);
				}
			} catch {
				// Board file may not exist at this path — fall through
			}

			if (boardData) {
				// If we could read board data directly, extract task info
				// and send a concise, precise prompt to the LLM
				const tasks = extractBacklogTasks(boardData);
				if (!tasks || tasks.length === 0) {
					ctx.ui.notify("No backlog tasks found", "info");
					return;
				}
				const oldest = tasks[0];
				pi.sendUserMessage(
					`Pick up the oldest backlog task and plan it:\n\n` +
						`1. Call \`board_update_task\` with \`{ "id": ${oldest.id}, "status": "in-progress" }\`\n` +
						`2. Launch Plan agent for: Task #${oldest.id}: ${oldest.title}\n` +
						`   Save plan to \`.pi/plans/task-${oldest.id}-<slugified-title>.md\`\n` +
						`3. Report: task ID, plan path, and summary. Tell the user to run /do to execute.`,
				);
			} else {
				// Fallback: send concise instructions for the LLM to call board tools
				pi.sendUserMessage(
					`Pick up the oldest backlog task and plan it. Execute these steps:\n\n` +
						`1. Call \`board_list_tasks\` with \`{ "status": "backlog", "sortBy": "created_at", "sortOrder": "asc" }\`\n` +
						`2. Take the FIRST task. If empty, say "No backlog tasks found" and STOP.\n` +
						`3. Call \`board_update_task\` with \`{ "id": <task_id>, "status": "in-progress" }\`\n` +
						`4. Launch Plan agent for the task. Save plan to \`.pi/plans/task-<ID>-<slug>.md\`\n` +
						`5. Report: task ID, plan path, and brief summary. Tell the user to run /do to execute.`,
				);
			}
		},
	});
}

interface BoardTask {
	id: number;
	title: string;
	description?: string;
	status: string;
}

function extractBacklogTasks(data: unknown): BoardTask[] | null {
	// Attempt to parse common pi-board data shapes
	if (!data || typeof data !== "object") return null;
	const obj = data as Record<string, unknown>;

	// Try common locations for task arrays
	const candidates: unknown[] = [];
	if (Array.isArray(obj.tasks)) candidates.push(...obj.tasks);
	if (Array.isArray(obj.items)) candidates.push(...obj.items);

	const tasks: BoardTask[] = [];
	for (const item of candidates) {
		if (
			item &&
			typeof item === "object" &&
			"status" in (item as object) &&
			(item as BoardTask).status === "backlog"
		) {
			tasks.push(item as BoardTask);
		}
	}

	// Sort by created_at if available
	tasks.sort((a, b) => {
		const aId = typeof a.id === "number" ? a.id : 0;
		const bId = typeof b.id === "number" ? b.id : 0;
		return aId - bId;
	});

	return tasks;
}
