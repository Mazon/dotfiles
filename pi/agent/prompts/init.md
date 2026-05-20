---
description: Initialize the project with git, .gitignore, AGENTS.md, and README.md
---

Initialize this project with sensible defaults.

## 1. .gitignore

If `.gitignore` doesn't exist, create one covering: env files (`.env`, `.env.*`), dependencies (`node_modules/`, `vendor/`, `__pycache__/`), build outputs (`dist/`, `build/`, `target/`), IDE files (`.idea/`, `.vscode/`, `.DS_Store`), logs (`*.log`), and coverage (`coverage/`). Skip if already present.

## 2. Git repo

If not a git repo, run `git init`. If there are zero commits, create one:
```bash
git add .gitignore
git commit -m "Initial commit with .gitignore"
```

## 3. AGENTS.md

If `AGENTS.md` doesn't exist, explore the codebase and write a concise one covering: project overview, tech stack, directory structure, build/test/run commands, conventions, and gotchas. Base it on what you find — if the project is empty, write a minimal template.

## 4. README.md

If `README.md` doesn't exist, write one based on the codebase and `AGENTS.md`: project name, prerequisites, getting started, usage, and development. Keep it concise.

## 5. Commit

If you created or modified files, commit them:
```bash
git add .gitignore AGENTS.md README.md
git commit -m "Add .gitignore, AGENTS.md, and README.md"
```

## Report

Briefly state what was created vs. already existed, and any commits made.
