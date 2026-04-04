---
description: Branch strategies, commit conventions, PR workflows, and git best practices
---

# Git Workflows Skill

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/description` | `feature/add-auth` |
| Fix | `fix/description` | `fix/login-error` |
| Docs | `docs/description` | `docs/api-reference` |
| Refactor | `refactor/description` | `refactor/user-service` |
| Chore | `chore/description` | `chore/update-deps` |

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting (no code change)
- `refactor` - Code restructuring
- `test` - Adding tests
- `chore` - Maintenance

### Examples
```
feat(auth): add OAuth2 login support

- Add Google OAuth provider
- Add session management
- Update login UI

Closes #123
```

## PR Description Template

```markdown
## What
Brief description of changes.

## Why
Business context / problem being solved.

## How
Technical approach taken.

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Documentation updated

## Screenshots
(If UI changes)
```

## Workflow Patterns

### Feature Branch
1. Create branch from main
2. Develop with small commits
3. Open PR for review
4. Squash merge to main

### Gitflow
- `main` - Production
- `develop` - Integration
- `feature/*` - Features
- `release/*` - Release prep
- `hotfix/*` - Emergency fixes
