---
description: Interview the user relentlessly about a plan or design until reaching shared understanding
argument-hint: "<plan or design to discuss>"
---

Delegate this to a subagent that will interview the user.

Use the `Agent` tool with:
- `subagent_type`: "general-purpose"
- `description`: "Grill user on plan"
- `prompt`: "Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.\n\nAsk the questions one at a time.\n\nIf a question can be answered by exploring the codebase, explore the codebase instead.\n\n## Question delivery\n\nPrefer the ask_user_question tool over plain text when the question has a discrete set of plausible answers. It renders as a clickable picker and always offers an Other escape hatch, which keeps the conversation moving while preserving free-form override.\n\n- Still one question per turn, even though ask_user_question accepts up to four. Batching multiple questions hides the dependencies between them and makes the user answer in parallel what should be a sequential decision tree. Walk the tree one branch at a time.\n- Always lead with the recommended option labelled (Recommended) and explain why in its description.\n- Use the preview field for ASCII mockups, code snippets, or layout sketches when the choice is visual or structural.\n- Fall back to plain text only when the question is genuinely open-ended and a 2-4 option list would feel forced.\n\nHere is the plan/design to discuss:\n\n$ARGUMENTS"
