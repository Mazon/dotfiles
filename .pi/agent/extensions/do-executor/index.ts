/**
 * Do Executor Extension — Unified plan execution via the Agent tool
 *
 * Registers /do command with modes:
 *   /do <task-id>               — execute task by ID
 *
 * Task IDs can be bare numbers (5) or #prefixed (#5).
 *
 * The extension programmatically generates precise
 * instructions for the LLM to call the Agent tool. After completion,
 * it instructs the LLM to merge worktree branches into main, clean up merged branches,
 * to code-review.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { readFileSync, existsSync, readdirSync } from "node:fs";
import { resolve, basename, join } from "node:path";

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
		description: "Execute a task: /do <task-id>. Task IDs can be bare numbers (5) or #prefixed (#5).",
		handler: async (args, ctx) => {
			const trimmed = (args ?? "").trim();
			const taskIdMatch = trimmed.match(/^#?(\d+)$/);
			
			if (!taskIdMatch) {
				ctx.ui.notify(
					"Usage: /do <task-id>\n" +
					"Examples:\n" +
					"  /do 5    — execute task #5\n" +
					"  /do #12  — execute task #12",
					"warning"
				);
				return;
			}
			
			const taskId = parseInt(taskIdMatch[1], 10);
			
			pi.sendUserMessage(
				`Execute task #${taskId}.\n\n` +
				`Execute these steps:\n\n` +
				`1. Call \`TaskGet\` with task ID ${taskId} to get the task's subject, description, and metadata.\n` +
				`2. Launch a single Do agent directly using the task's details:\n\n` +
				`   Use the \`Agent\` tool with:\n` +
				`   - \`subagent_type\`: "Do"\n` +
				`   - \`description\`: "<task subject>"\n` +
				`   - \`prompt\`: "Execute this task: <task subject>\\n\\n<task description>\\n\\n<if metadata.planPath exists, include: 'Full plan context is available at: metadata.planPath'>\\n\\nImplement this step by step. After each step, verify before proceeding. Report a summary when complete."\n` +
				`   - \`isBackground\`: true\n` +
				`   - \`isolation\`: "worktree"\n\n` +
				`3. Wait for the agent to complete using \`get_subagent_result\` with \`wait: true\`.\n` +
				`4. After the agent completes:\n` +
				`   - Determine the primary branch (e.g. by running \`git branch --show-current\` before, or falling back to main/master/develop)\n` +
				`   - Merge the worktree branch into the primary branch\n` +
				`   - Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "completed" }\`\n` +
				`   - Report a summary`
			);
		},
	});
}
