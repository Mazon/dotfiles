---
description: Initialize the project with git, .gitignore, AGENTS.md, and README.md
---

Initialize this project with sensible defaults by delegating to a subagent.

Use the `Agent` tool with:
- `subagent_type`: "Do"
- `description`: "Initialize project"
- `prompt`: "Initialize this project with sensible defaults.\n\n## 1. .gitignore\n\nIf .gitignore doesn't exist, create one covering: env files (.env, .env.*), dependencies (node_modules/, vendor/, __pycache__/), build outputs (dist/, build/, target/), IDE files (.idea/, .vscode/, .DS_Store), logs (*.log), and coverage (coverage/). Skip if already present.\n\n## 2. Git repo\n\nIf not a git repo, run git init. If there are zero commits, create one:\n```bash\ngit add .gitignore\ngit commit -m \"Initial commit with .gitignore\"\n```\n\n## 3. AGENTS.md\n\nIf AGENTS.md doesn't exist, explore the codebase and write a concise one covering: project overview, tech stack, directory structure, build/test/run commands, conventions, and gotchas. Base it on what you find — if the project is empty, write a minimal template.\n\n## 4. README.md\n\nIf README.md doesn't exist, write one based on the codebase and AGENTS.md: project name, prerequisites, getting started, usage, and development. Keep it concise.\n\n## 5. Commit\n\nIf you created or modified files, commit them:\n```bash\ngit add .gitignore AGENTS.md README.md\ngit commit -m \"Add .gitignore, AGENTS.md, and README.md\"\n```\n\n## Report\n\nBriefly state what was created vs. already existed, and any commits made."
