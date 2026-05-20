/**
 * Do Executor Extension — Unified plan execution via the Agent tool
 *
 * Registers /do command with modes:
 *   /do <plan-file>            — auto-detect: multi if waves exist, single otherwise
 *   /do -single <plan-file>    — one agent for the whole plan
 *   /do -multi <plan-file>     — agents per wave (parallel within waves)
 *
 * The extension parses the plan programmatically and generates precise
 * instructions for the LLM to call the Agent tool. After completion,
 * it instructs the LLM to merge worktree branches and move board tasks
 * to code-review.
 *
 * This approach avoids deadlocking pi's event loop by delegating the
 * actual subagent spawning to the LLM via the existing Agent tool.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { readFileSync, existsSync } from "node:fs";
import { resolve, basename } from "node:path";

// --- Types ---

interface PlanTask {
	index: number;
	title: string;
	spec: string;
}

interface PlanWave {
	index: number;
	name: string;
	tasks: PlanTask[];
}

interface ParsedPlan {
	title: string;
	waves: PlanWave[];
	totalTasks: number;
}

// --- Plan Parser ---

function parsePlan(content: string): ParsedPlan {
	const titleMatch = content.match(/^#\s+Plan:\s+(.+)$/m);
	const title = titleMatch?.[1]?.trim() ?? "Untitled Plan";

	const waves: PlanWave[] = [];
	let totalTasks = 0;

	const waveRegex = /^### Wave (\d+)\s*[—\-–]?\s*(.*)$/gm;
	const waveMatches: Array<{ index: number; name: string; start: number }> = [];

	let match: RegExpExecArray | null;
	while ((match = waveRegex.exec(content)) !== null) {
		waveMatches.push({
			index: parseInt(match[1], 10),
			name: match[2]?.trim() || `Wave ${match[1]}`,
			start: match.index + match[0].length,
		});
	}

	for (let i = 0; i < waveMatches.length; i++) {
		const waveStart = waveMatches[i].start;
		const waveEnd = i + 1 < waveMatches.length ? waveMatches[i + 1].start : content.length;
		const waveContent = content.slice(waveStart, waveEnd);

		const taskRegex = /^- \[[ x]\]\s+(.+)$/gm;
		const tasks: PlanTask[] = [];

		while ((match = taskRegex.exec(waveContent)) !== null) {
			const taskTitle = match[1].trim();
			const spec = findSpec(content, taskTitle);
			tasks.push({ index: tasks.length + 1, title: taskTitle, spec });
			totalTasks++;
		}

		waves.push({ index: waveMatches[i].index, name: waveMatches[i].name, tasks });
	}

	if (waves.length === 0) {
		const taskRegex = /^- \[ \]\s+(.+)$/gm;
		const tasks: PlanTask[] = [];
		while ((match = taskRegex.exec(content)) !== null) {
			const taskTitle = match[1].trim();
			const spec = findSpec(content, taskTitle);
			tasks.push({ index: tasks.length + 1, title: taskTitle, spec });
			totalTasks++;
		}
		if (tasks.length > 0) {
			waves.push({ index: 1, name: "All tasks (sequential)", tasks });
		}
	}

	return { title, waves, totalTasks };
}

function findSpec(content: string, taskTitle: string): string {
	const specSection = content.match(
		/##\s+Detailed Specifications([\s\S]*?)(?=##\s+(?:Surprises|Decision|Outcomes|$))/i,
	);
	if (!specSection) return "";

	const specs = specSection[1];

	const exactRegex = new RegExp(
		`^#{2,4}\\s+.*${escapeRegex(taskTitle)}.*$([\\s\\S]*?)(?=^#{2,3}\\s|$$)`,
		"im",
	);
	const exactMatch = specs.match(exactRegex);
	if (exactMatch) return exactMatch[0].trim();

	const words = taskTitle
		.split(/\s+/)
		.filter(
			(w) =>
				w.length > 3 &&
				!["with", "from", "into", "that", "this", "the", "for"].includes(w.toLowerCase()),
		);
	if (words.length > 0) {
		const partialRegex = new RegExp(
			`^#{2,4}\\s+.*(?:${words.map(escapeRegex).join("|")}).*$([\\s\\S]*?)(?=^#{2,3}\\s|$$)`,
			"im",
		);
		const partialMatch = specs.match(partialRegex);
		if (partialMatch) return partialMatch[0].trim();
	}

	return "";
}

function escapeRegex(str: string): string {
	return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// --- Task ID extraction ---

function extractTaskIdFromPath(planPath: string): number | null {
	const filename = basename(planPath);
	const match = filename.match(/^task-(\d+)-/);
	return match ? parseInt(match[1], 10) : null;
}

// --- Mode detection ---

type ExecutionMode = "single" | "multi" | "auto";

function parseArgs(args: string): { mode: ExecutionMode; planPath: string } {
	const trimmed = (args ?? "").trim();
	if (!trimmed) return { mode: "auto", planPath: "" };
	if (trimmed.startsWith("-single ")) return { mode: "single", planPath: trimmed.slice(8).trim() };
	if (trimmed.startsWith("-multi ")) return { mode: "multi", planPath: trimmed.slice(7).trim() };
	return { mode: "auto", planPath: trimmed };
}

// --- Instruction builders ---

function buildSingleInstructions(
	planPath: string,
	parsed: ParsedPlan,
	taskId: number | null,
): string {
	let msg = `Execute the plan at \`${planPath}\` using a single agent.\n\n`;
	msg += `**Plan:** ${parsed.title} (${parsed.totalTasks} tasks)\n\n`;
	msg += `Use the \`Agent\` tool with:\n`;
	msg += `- \`subagent_type\`: "Do"\n`;
	msg += `- \`description\`: "Execute plan: ${parsed.title}"\n`;
	msg += `- \`prompt\`: "Execute this plan step by step. After each step, verify the result before moving to the next. Report a summary when complete.\\n\\n`;
	msg += `The full plan content is in the file \`${planPath}\`. Read it first, then execute every task.\\n"\n`;
	msg += `- \`run_in_background\`: true\n`;
	msg += `- \`isolation\`: "worktree"\n\n`;

	msg += `### After the agent completes:\n\n`;
	msg += `**1. Merge the branch** — The agent's result will indicate if it created a branch (e.g. "Changes saved to branch \`pi-agent-xxx\`"). If so:\n`;
	msg += `   - Run \`git merge <branch-name>\`\n`;
	msg += `   - Resolve any conflicts if they arise\n\n`;

	msg += `**2. Update the board**\n`;
	if (taskId !== null) {
		msg += `- Call \`board_update_task\` with \`{ "id": ${taskId}, "status": "code-review" }\`\n`;
		msg += `- Call \`board_add_comment\` with \`{ "taskId": ${taskId}, "body": "✅ Implementation complete. Moved to code review." }\`\n\n`;
	}

	msg += `**3. Report** a summary of what was accomplished.\n`;

	return msg;
}

function buildMultiInstructions(
	planPath: string,
	parsed: ParsedPlan,
	taskId: number | null,
): string {
	let msg = `Execute the plan at \`${planPath}\` in parallel waves.\n\n`;
	msg += `**Plan:** ${parsed.title} (${parsed.waves.length} waves, ${parsed.totalTasks} tasks)\n\n`;

	msg += `Execute waves sequentially, tasks within each wave in parallel:\n\n`;

	for (const wave of parsed.waves) {
		msg += `### Wave ${wave.index}: ${wave.name}\n\n`;
		msg += `**Step A — Launch** ALL ${wave.tasks.length} task(s) simultaneously using the Agent tool:\n\n`;

		for (const task of wave.tasks) {
			const promptContent = `Execute this task step by step. After each step, verify the result before moving to the next. Report a summary when complete.\\n\\n## Task: ${task.title}\\n\\n${task.spec || "See plan file for details."}`;
			msg += `**Task: ${task.title}**\n`;
			msg += `  - \`subagent_type\`: "Do"\n`;
			msg += `  - \`description\`: "${task.title}"\n`;
			msg += `  - \`prompt\`: "${promptContent.replace(/"/g, '\\"')}"\n`;
			msg += `  - \`run_in_background\`: true\n`;
			msg += `  - \`isolation\`: "worktree"\n\n`;
		}

		msg += `**Step B — Wait** for ALL tasks in wave ${wave.index} to complete (use \`get_subagent_result\` with \`wait: true\` for each agent).\n\n`;

		msg += `**Step C — Merge** wave ${wave.index} branches. For each completed agent that created a branch (shown in its result as "Changes saved to branch \`...\`"):\n`;
		msg += `- Run \`git merge <branch-name>\`\n`;
		msg += `- Resolve any conflicts before proceeding to the next wave\n`;
		msg += `- If any merge fails, report the issue and ask whether to continue\n\n`;
	}

	msg += `### After all waves complete:\n\n`;

	msg += `**Update the board:**\n`;
	if (taskId !== null) {
		msg += `- Call \`board_update_task\` with \`{ "id": ${taskId}, "status": "code-review" }\`\n`;
		msg += `- Call \`board_add_comment\` with \`{ "taskId": ${taskId}, "body": "✅ Implementation complete. Moved to code review." }\`\n\n`;
	}

	msg += `**Report** a summary table:\n\n`;
	msg += "| Wave | Tasks | Status | Branches Merged | Notes |\n";
	msg += "|------|-------|--------|-----------------|-------|\n";
	for (const wave of parsed.waves) {
		msg += `| ${wave.index} | ${wave.tasks.length} | ✅ | | |\n`;
	}
	msg += `\n### Next Steps\n- Run /review to review the changes\n`;

	msg += `\n**Rules:**\n`;
	msg += `- All tasks in a wave MUST launch before waiting on any (true parallelism)\n`;
	msg += `- Waves are sequential — complete Wave N (including merges) before starting Wave N+1\n`;
	msg += `- If any task fails, report which and ask whether to continue\n`;
	msg += `- Always merge branches after each wave to avoid conflicts accumulating\n`;

	return msg;
}

// --- Extension ---

export default function (pi: ExtensionAPI) {
	// Register the parse_plan_waves tool for LLM use
	pi.registerTool({
		name: "parse_plan_waves",
		label: "Parse Plan Waves",
		description:
			"Read a plan file and extract waves with their tasks and specs. " +
			"Returns structured data so you can launch subagents for each wave. " +
			"Use this before dispatching parallel Do subagents.",
		promptSnippet: "Parse a plan file into structured waves for parallel execution",
		promptGuidelines: [
			"Use parse_plan_waves before dispatching Do subagents for a plan.",
			"Use the returned wave/task data to launch subagents with precise prompts.",
		],
		parameters: Type.Object({
			planPath: Type.String({
				description: "Path to the plan file (relative to cwd or absolute)",
			}),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const absPath = resolve(ctx.cwd, params.planPath);
			if (!existsSync(absPath)) {
				throw new Error(`Plan file not found: ${params.planPath}`);
			}

			const content = readFileSync(absPath, "utf-8");
			const parsed = parsePlan(content);

			if (parsed.waves.length === 0) {
				throw new Error(
					"No waves found in plan. Ensure the plan has `### Wave N` sections with `- [ ]` checkboxes.",
				);
			}

			const summary = parsed.waves
				.map((w) => `Wave ${w.index} (${w.name}): ${w.tasks.length} task(s)`)
				.join(" | ");

			return {
				content: [
					{
						type: "text",
						text: `Parsed ${parsed.waves.length} wave(s), ${parsed.totalTasks} task(s) from ${params.planPath}\n${summary}`,
					},
				],
				details: parsed,
			};
		},
	});

	// Register /do command
	pi.registerCommand("do", {
		description:
			"Execute a plan: /do <plan> (auto), /do -single <plan>, /do -multi <plan>",
		handler: async (args, ctx) => {
			const { mode, planPath } = parseArgs(args);

			if (!planPath) {
				ctx.ui.notify("Usage: /do [-single|-multi] <plan-file-path>", "warning");
				return;
			}

			const absPath = resolve(ctx.cwd, planPath);
			if (!existsSync(absPath)) {
				ctx.ui.notify(`Plan file not found: ${planPath}`, "error");
				return;
			}

			// Read and parse plan synchronously
			const content = readFileSync(absPath, "utf-8");
			const parsed = parsePlan(content);

			if (parsed.waves.length === 0 || parsed.totalTasks === 0) {
				ctx.ui.notify("No tasks found in plan", "warning");
				return;
			}

			// Determine effective mode
			let effectiveMode = mode;
			if (mode === "auto") {
				effectiveMode = parsed.waves.length > 1 ? "multi" : "single";
			}

			const taskId = extractTaskIdFromPath(planPath);

			// Build instructions and delegate to the LLM
			const instructions =
				effectiveMode === "single"
					? buildSingleInstructions(planPath, parsed, taskId)
					: buildMultiInstructions(planPath, parsed, taskId);

			pi.sendUserMessage(instructions);
		},
	});
}
