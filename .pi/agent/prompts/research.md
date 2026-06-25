---
description: Research a question via a general-purpose subagent (web, docs, comparisons — runs in background)
argument-hint: "<question or topic>"
---

**Question:**

$ARGUMENTS

**Instructions:**

If no question was provided (empty `$ARGUMENTS`), ask the user what they'd like researched and stop.

Otherwise, delegate this to a general-purpose agent so the main context stays clean. Use the `Agent` tool with:

- `subagent_type`: "general-purpose"
- `description`: "Research: <brief summary of the question>"
- `prompt`: the full question text above, plus any context from this conversation that the research would need
- `run_in_background`: true

The research agent will search the web and/or source code, synthesize an evidence-backed answer with citations, and return a single self-contained report. When it completes, present its summary to the user — do not re-research or rephrase it into something larger. If it flagged caveats or uncertainty, surface those faithfully.
