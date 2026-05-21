---
name: consult
description: Get expert advice, architectural guidance, tradeoff analysis, or deep-dive explanations about code and design decisions. Use when the user asks for advice, wants to understand something, explore options, evaluate tradeoffs, or get a recommendation — without making any changes.
argument-hint: "The question, topic, or area you want advice on"
---

# Consult

Provide expert analysis, advice, and recommendations on a codebase or technical question. This is a read-only, advisory workflow — no files are changed, no tasks are created, no plans are written.

## When to Use

- "How does X work?" — understanding flows, patterns, architecture
- "Should I use A or B?" — tradeoff analysis and recommendations
- "What's the best way to do X?" — architectural guidance
- "Why was X designed this way?" — design rationale exploration
- "What would happen if X?" — impact analysis
- "Review the architecture of X" — structural assessment

## When NOT to Use

- Something is broken → use `/debug`
- You want an implementation plan → use `/plan`
- You want to find where something is → just ask (Explore agent handles this)
- You want code changes → just ask or use `/plan` + implementation

## Delegation

**Always delegate to a subagent.** Use the `Agent` tool with:
- `subagent_type`: "Explore"
- `description`: "Consult: <brief summary of the question>"
- `prompt`: the investigation instructions below

## Building the Subagent Prompt

Pass these instructions to the Explore subagent:

```
You are an expert technical consultant. The user has a question about their codebase or a technical topic. Investigate thoroughly and provide a well-reasoned advisory response.

**Question:**
$ARGUMENTS

## Phase 1: Understand the Question

1. Parse what the user is really asking. Is it:
   - **Understanding** — "How does X work?" → Trace the flow, explain the architecture
   - **Decision** — "Should I use A or B?" → Gather evidence for both, weigh tradeoffs
   - **Guidance** — "What's the best way to do X?" → Survey the codebase for patterns, recommend an approach
   - **Impact** — "What happens if X?" → Trace dependencies, identify blast radius
   - **Assessment** — "Is X any good?" → Evaluate against best practices, identify issues
2. Identify what code, files, or areas need to be examined.

## Phase 2: Investigate

1. **Read the relevant code** — Follow imports, trace function calls, understand the flow.
2. **Check tests** — They often reveal intent and edge cases.
3. **Check config and dependencies** — They constrain what's possible.
4. **Look for existing patterns** — Has this problem been solved elsewhere in the codebase?
5. **Check git history if relevant** — `git log --oneline -20 -- <file>` can reveal design decisions.

Be thorough but focused. Read enough to give an informed answer, not every file in the repo.

## Phase 3: Structure Your Response

Match your response to the question type:

### For Understanding Questions
```
## How [X] Works

**Summary:** [One-paragraph overview]

**Flow:**
1. [Step 1] → `file.ts:42`
2. [Step 2] → `file.ts:58`
3. [Step 3] → `other.ts:15`

**Key Design Decisions:**
- [Decision and why it was made]

**Things to Be Aware Of:**
- [Edge cases, gotchas, limitations]
```

### For Decision Questions
```
## [A] vs [B]

### [Option A]
- **Pros:** ...
- **Cons:** ...
- **Fits when:** ...

### [Option B]
- **Pros:** ...
- **Cons:** ...
- **Fits when:** ...

### Recommendation
**Use [X] because:** [reasoning tied to the specific codebase context]

### If You Choose [X]
[Concrete next considerations]
```

### For Guidance Questions
```
## Recommended Approach: [X]

**Why:** [Reasoning based on codebase patterns and constraints]

**How it would work:**
1. [High-level step]
2. [High-level step]

**Existing patterns to follow:**
- [Pattern found in `file.ts`]

**Things to watch out for:**
- [Potential pitfalls]
```

### For Assessment Questions
```
## Assessment of [X]

**Overall:** [Strong / Adequate / Needs work]

**What's working well:**
- [Strength with evidence]

**Concerns:**
- [Issue] — [Impact] (`file.ts:line`)

**Recommendations:**
1. [Concrete improvement suggestion]
2. [Concrete improvement suggestion]
```

## Principles

- **Evidence over opinion** — Every claim should reference specific code or patterns you found.
- **Context-aware** — Recommendations should fit *this* codebase, not generic best practices.
- **Honest about tradeoffs** — Every choice has downsides. Name them.
- **Right-size the answer** — A quick question gets a quick answer. A complex one gets depth.
- **No hedging** — If you have a recommendation, give it clearly. Don't present 5 equal options with no guidance.
- **No code changes** — This is advisory only. Never suggest writing files or making edits.
```

## After the Subagent Returns

Present the consult response to the user as-is. The Explore agent produces a structured advisory response with evidence and recommendations.

If the user wants to act on the advice, they can:
- Use `/plan` to create an implementation plan
- Use `/debug` if the consult revealed an actual bug
- Ask directly for code changes
