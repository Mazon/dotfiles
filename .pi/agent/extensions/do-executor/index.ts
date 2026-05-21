/**
 * Do Executor Extension — Unified plan execution via the Agent tool
 *
 * Registers /do command with modes:
 *   /do <plan-file | task-id>   — auto-detect: multi if waves exist, single otherwise
 *   /do -single <plan|task>     — one agent for the whole plan
 *   /do -multi <plan|task>      — agents per wave (parallel within waves)
 *   /do <task-id>               — execute task by ID (uses plan if exists, otherwise runs directly)
 *
 * Task IDs can be bare numbers (5) or #prefixed (#5).
 *
 * The extension parses the plan programmatically and generates precise
 * instructions for the LLM to call the Agent tool. After completion,
 * it instructs the LLM to merge worktree branches into main, clean up merged branches,
 * to code-review.
 *
 * This approach avoids deadlocking pi's event loop by delegating the
 * actual subagent spawning to the LLM via the existing Agent tool.
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

// --- Task ID extraction ---

function extractTaskIdFromPath(planPath: string): number | null {
	const filename = basename(planPath);
	const match = filename.match(/^task-(\d+)-/);
	return match ? parseInt(match[1], 10) : null;
}

// --- Mode detection ---

type ExecutionMode = "single" | "multi" | "auto";

function parseArgs(args: string): { mode: ExecutionMode; planPath: string; taskId: number | null } {
	const trimmed = (args ?? "").trim();
	if (!trimmed) return { mode: "auto", planPath: "", taskId: null };

	let mode: ExecutionMode = "auto";
	let remaining = trimmed;

	if (remaining.startsWith("-single ")) {
		mode = "single";
		remaining = remaining.slice(8).trim();
	} else if (remaining.startsWith("-multi ")) {
		mode = "multi";
		remaining = remaining.slice(7).trim();
	}

	// Detect task ID: bare number or #prefixed number, but NOT a path
	const taskIdMatch = remaining.match(/^#?(\d+)$/);
	const isPath = remaining.includes("/") || remaining.includes(".");

	if (taskIdMatch && !isPath) {
		return { mode, planPath: "", taskId: parseInt(taskIdMatch[1], 10) };
	}

	return { mode, planPath: remaining, taskId: null };
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
	msg += `**1. Wait for the agent to complete** using \`get_subagent_result\` with \`wait: true\`.\n\n`;
	msg += `**2. Merge the branch into the primary branch** — The agent's result will indicate if it created a branch (e.g. "Changes saved to branch \`pi-agent-xxx\`"). If so:\n`;
	msg += `   - Determine the primary branch (e.g. by running \`git branch --show-current\` before, or falling back to main/master/develop)\n`;
	msg += `   - Run \`git checkout <primary-branch> && git merge <branch-name>\`\n`;
	msg += `   - Resolve any conflicts if they arise\n`;
	msg += `   - Run \`git branch -d <branch-name>\` to delete the merged branch\n`;
	msg += `   - Run \`git worktree prune\` to clean up any stale worktree metadata\n\n`;

	msg += `**3. Update the task**\n`;
	if (taskId !== null) {
		msg += `- Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "in_progress", "metadata": { "reviewStatus": "code-review" } }\`\n`;
		msg += `- Append a summary of what was done to the task's description.\n\n`;
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

		msg += `**Step C — Merge** wave ${wave.index} branches into the primary branch. For each completed agent that created a branch (shown in its result as "Changes saved to branch \`...\`"):\n`;
		msg += `- Determine the primary branch (e.g., \`git branch --show-current\` or main/master/develop)\n`;
		msg += `- Run \`git checkout <primary-branch> && git merge <branch-name>\`\n`;
		msg += `- Resolve any conflicts before proceeding to the next wave\n`;
		msg += `- Run \`git branch -d <branch-name>\` to delete the merged branch\n`;
		msg += `- Run \`git worktree prune\` to clean up any stale worktree metadata\n`;
		msg += `- If any merge fails, report the issue and ask whether to continue\n\n`;
	}

	msg += `### After all waves complete:\n\n`;

	msg += `**Update the task:**\n`;
	if (taskId !== null) {
		msg += `- Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "in_progress", "metadata": { "reviewStatus": "code-review" } }\`\n`;
		msg += `- Append a summary of what was done to the task's description.\n\n`;
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
			"Execute a plan or task: /do <plan-file | task-id> (auto), /do -single <plan-file | task-id>, /do -multi <plan-file | task-id>. Task IDs can be bare numbers (5) or #prefixed (#5).",
		handler: async (args, ctx) => {
			const { mode, planPath, taskId } = parseArgs(args);

			if (!planPath && taskId === null) {
				ctx.ui.notify(
					"Usage: /do [-single|-multi] <plan-file | task-id>\n" +
					"Examples:\n" +
					"  /do .pi/plans/task-5-fix-bug.md    — execute a plan file\n" +
					"  /do 5                                — execute task #5 (uses plan if exists, otherwise runs directly)\n" +
					"  /do -single 5                        — force single-agent mode for task #5",
					"warning",
				);
				return;
			}

			// --- Task ID path ---
			if (taskId !== null) {
				const planFilePattern = new RegExp(`^task-${taskId}-.*\\.md$`);

				// Try to find an existing plan file matching .pi/plans/task-<ID>-*.md
				const plansDir = join(ctx.cwd, ".pi", "plans");
				let foundPlan: string | null = null;

				if (existsSync(plansDir)) {
					try {
						const files = readdirSync(plansDir);
						for (const file of files) {
							if (planFilePattern.test(file)) {
								foundPlan = join(".pi", "plans", file);
								break;
							}
						}
					} catch {
						// ignore read errors, treat as no plan found
					}
				}

				if (foundPlan) {
					// Plan file exists — instruct LLM to fetch task details then execute the plan
					pi.sendUserMessage(
						`Execute task #${taskId} using its existing plan.\n\n` +
						`1. Call \`TaskGet\` with task ID ${taskId} to get the task's subject and description.\n` +
						`2. Execute the plan at \`${foundPlan}\` using the existing /do plan execution flow.\n` +
						`3. The plan file is already on disk — read it and proceed.\n\n` +
						`After the agent completes:\n` +
						`- Merge the worktree branch into main\n` +
						`- Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "in_progress", "metadata": { "reviewStatus": "code-review" } }\`\n` +
						`- Report a summary`,
					);
				} else {
					// No plan file — instruct LLM to fetch task details and run directly
					pi.sendUserMessage(
						`Execute task #${taskId} directly (no plan file exists yet).\n\n` +
						`Execute these steps:\n\n` +
						`1. Call \`TaskGet\` with task ID ${taskId} to get the task's subject and description.\n` +
						`2. If the task has \`metadata.planPath\`, use that as the plan file and execute it instead.\n` +
						`3. If no plan exists, launch a single Do agent directly using the task's subject and description:\n\n` +
						`   Use the \`Agent\` tool with:\n` +
						`   - \`subagent_type\`: "Do"\n` +
						`   - \`description\`: "<task subject>"\n` +
						`   - \`prompt\`: "Execute this task: <task subject>\n\n<task description>\n\nImplement this step by step. After each step, verify before proceeding. Report a summary when complete."\n` +
						`   - \`run_in_background\`: true\n` +
						`   - \`isolation\`: "worktree"\n\n` +
						`4. Wait for the agent to complete using \`get_subagent_result\` with \`wait: true\`.\n` +
						`5. After the agent completes:\n` +
						`   - Determine the primary branch (e.g. by running \`git branch --show-current\` before, or falling back to main/master/develop)\n` +
						`   - Merge the worktree branch into the primary branch\n` +
						`   - Call \`TaskUpdate\` with \`{ "taskId": "${taskId}", "status": "in_progress", "metadata": { "reviewStatus": "code-review" } }\`\n` +
						`   - Report a summary`,
					);
				}
				return;
			}

			// --- Plan file path (existing behavior) ---
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

			const extractedTaskId = extractTaskIdFromPath(planPath);

			// Build instructions and delegate to the LLM
			const instructions =
				effectiveMode === "single"
					? buildSingleInstructions(planPath, parsed, extractedTaskId)
					: buildMultiInstructions(planPath, parsed, extractedTaskId);

			pi.sendUserMessage(instructions);
		},
	});
}
