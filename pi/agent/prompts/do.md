---
description: Execute a plan sequentially (use /do-parallel for parallel wave execution)
argument-hint: "<plan>"
---

Execute the following plan **sequentially** by launching the Do agent as a subagent. Pass the plan as the prompt.

**Plan to execute:**

$@

**Instructions:**

Use the `Agent` tool with:
- `subagent_type`: "Do"
- `description`: "Execute plan"
- `prompt`: the full plan text above, prefixed with: "Execute this plan step by step. After each step, verify the result before moving to the next. Report a summary when complete.\n\n"

Do NOT implement the plan yourself. Delegate entirely to the subagent. Once the subagent finishes, report a brief summary of what was accomplished.

**Note:** This executes steps sequentially, one at a time. Use `/do-parallel` if you want wave-based parallel execution.
