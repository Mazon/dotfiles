---
description: Initialize the project with git, AGENTS.md, and README.md
---

Initialize this project. Do the following in order:

## 1. Ensure git repo with initial commit

Check if the current directory is a git repository. If not, initialize one:

```bash
git init
```

Then check if there is at least one commit. If there are zero commits (e.g. `git log` fails or shows nothing), create an initial commit so that git worktrees can be used later:

```bash
git add -A
git commit -m "Initial commit"
```

If there are already commits, skip this step.

## 2. Create AGENTS.md

Create an `AGENTS.md` file in the project root if it doesn't already exist. This file should describe the project for AI agents. Look at the codebase to understand what the project is about, then write a concise `AGENTS.md` with:

- **Project overview**: What this project is and does.
- **Tech stack**: Languages, frameworks, build tools.
- **Project structure**: Key directories and their purposes.
- **Build & run commands**: How to build, test, and run the project.
- **Conventions**: Code style, naming conventions, patterns used.
- **Gotchas**: Anything non-obvious that an AI agent should know.

Keep it factual and based on what you find in the codebase. If the project is empty or just starting, write a minimal `AGENTS.md` as a starting template.

## 3. Create README.md

Create a `README.md` file in the project root if it doesn't already exist. This is the human-facing documentation. Look at the codebase and the `AGENTS.md` you just created, then write a `README.md` with:

- **Project name & description**
- **Prerequisites**: What's needed to build/run (language version, tools, etc.)
- **Getting started**: Clone, install, build, run instructions.
- **Usage**: How to use the project.
- **Development**: How to develop, test, and contribute.

Keep it concise and accurate. If the project is empty, write a minimal starter `README.md`.

## 4. Commit if needed

If you created or modified files, commit them:

```bash
git add AGENTS.md README.md
git commit -m "Add AGENTS.md and README.md"
```

If both files already existed and are unchanged, skip this step.

## Final output

Report what you did:
- Whether git was already initialized or you ran `git init`.
- Whether an initial commit was created or already existed.
- Whether `AGENTS.md` and `README.md` were created or already existed.
- Any commits made.
