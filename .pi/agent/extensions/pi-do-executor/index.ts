/**
 * Do Executor Extension — Unified plan execution via the Agent tool
 *
 * Registers commands:
 *   /do <task-id>    — execute a single task by ID
 *   /do-next         — find and execute the next unblocked pending task
 *   /do-all          — execute all pending tasks in dependency/wave order
 *
 * Task IDs can be bare numbers (5) or #prefixed (#5).
 *
 * The extension programmatically generates precise instructions for the LLM
 * to call the Agent tool with worktree isolation. After completion, it
 * instructs the LLM to merge worktree branches, clean up, and review.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";

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

// --- Shared Helpers ---

function buildTaskExecutionPrompt(taskId: number, subject: string, description: string, planPath?: string): string {
	return (
		`Execute task #${taskId}: ${subject}\n\n` +
		`${description}\n\n` +
		(planPath ? `Full plan context is available at: ${planPath}\n\n` : "") +
		`Implement this step by step. After each step, verify before proceeding. Report a summary when complete.`
	);
}

function buildAgentInstructions(taskId: number, planPath?: string): string {
	return (
		`Execute task #${taskId}.\n\n` +
		`Steps:\n\n` +
		`1. Call \`TaskGet\` with task ID ${taskId} to get the task's subject, description, and metadata.\n` +
		`2. Launch a single Do agent:\n` +
		`   - \`subagent_type\`: "Do"\n` +
		`   - \`description\`: "<task subject>"\n` +
		`   - \`prompt\`: The task subject + description + plan path reference\n` +
		`   - \`run_in_background\`: true\n` +
		`   - \`isolation\`: "worktree"\n\n` +
		`3. Wait for the agent to complete using \`get_subagent_result\` with \`wait: true\`.\n` +
		`4. After completion:\n` +
		`   - Merge the worktree branch into the primary branch (main/master/develop)\n` +
		`   - Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "completed" }\`\n` +
		`   - Report a summary`
	);
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

	// --- /do <task-id> ---
	pi.registerCommand("do", {
		description:
			"Execute a single task by ID. Usage: /do <task-id>. Task IDs can be bare numbers (5) or #prefixed (#5).",
		handler: async (args, ctx) => {
			const trimmed = (args ?? "").trim();
			const taskIdMatch = trimmed.match(/^#?(\d+)$/);

			if (!taskIdMatch) {
				ctx.ui.notify(
					"Usage: /do <task-id>\n" +
						"Examples:\n" +
						"  /do 5    — execute task #5\n" +
						"  /do #12  — execute task #12\n\n" +
						"Also available:\n" +
						"  /do-next — execute the next available task\n" +
						"  /do-all  — execute all pending tasks in wave order",
					"warning",
				);
				return;
			}

			const taskId = parseInt(taskIdMatch[1], 10);
			pi.sendUserMessage(buildAgentInstructions(taskId));
		},
	});

	// --- /do-next ---
	pi.registerCommand("do-next", {
		description:
			"Find the next unblocked pending task and execute it. If no tasks are available, reports the current board status.",
		handler: async (_args, _ctx) => {
			pi.sendUserMessage(
				"Find and execute the next available task.\n\n" +
					"Steps:\n\n" +
					"1. Call `TaskList` to get all tasks.\n" +
					"2. Find the first task that is `pending` with an empty `blockedBy` list (no unmet dependencies).\n" +
					"3. If found:\n" +
					"   - Call `TaskGet` to get full details\n" +
					"   - Launch a Do agent with worktree isolation\n" +
					"   - Wait for completion, merge branch, mark task completed\n" +
					"   - Report summary\n" +
					"4. If no unblocked pending task found:\n" +
					"   - Report which tasks are pending and what they're blocked by\n" +
					"   - Suggest: add tasks with /idea, plan with /plan, or check /tasks",
			);
		},
	});

	// --- /do-all ---
	pi.registerCommand("do-all", {
		description:
			"Execute all pending tasks respecting dependency/wave order. Tasks within the same wave run in parallel. Stops on failure.",
		handler: async (_args, _ctx) => {
			pi.sendUserMessage(
				"Execute all pending tasks in wave/dependency order.\n\n" +
					"Steps:\n\n" +
					"1. Call `TaskList` to get all tasks with their statuses and dependencies.\n" +
					"2. Group pending tasks by their wave/dependency level:\n" +
					"   - Tasks with no dependencies → Wave 1 (can run in parallel)\n" +
					"   - Tasks blocked only by Wave 1 tasks → Wave 2\n" +
					"   - And so on...\n" +
					"3. If no pending tasks, report that and stop.\n" +
					"4. For each wave, in order:\n" +
					"   a. Launch Do agents for all tasks in the wave simultaneously (run_in_background: true, isolation: worktree)\n" +
					"   b. Wait for all agents in the wave to complete using `get_subagent_result`\n" +
					"   c. If any agent fails:\n" +
					"      - Report the failure\n" +
					"      - Mark the failed task as in_progress with error details\n" +
					"      - STOP — do not proceed to the next wave\n" +
					"   d. For each successful agent:\n" +
					"      - Merge the worktree branch into the primary branch\n" +
					"      - Call `TaskUpdate` with status: completed\n" +
					"5. After all waves complete, report a full summary:\n" +
					"   - Tasks completed vs failed\n" +
					"   - Suggest running /skill:review on completed tasks\n\n" +
					"Important: Within a wave, launch all agents FIRST, then wait for all of them. Do not launch and wait one at a time within a wave.",
			);
		},
	});
}
