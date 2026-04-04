---
description: Writing clear documentation, READMEs, API docs, and guides
---

# Documentation Skill

## Documentation Types

| Type | Purpose | Key Elements |
|------|---------|--------------|
| README | Project overview | Install, usage, examples |
| API Docs | Interface reference | Params, returns, examples |
| CHANGELOG | Version history | Changes, breaking changes |
| Contributing | Dev guidelines | Setup, standards, PR process |

## Writing Principles

- **Lead with the answer** - Summary first, details after
- **Show, don't tell** - Code examples over explanations
- **Be scannable** - Headers, lists, code blocks
- **Update as you go** - Docs drift from code quickly

## README Template

```markdown
# Project Name

One-line description.

## Installation

\`\`\`bash
npm install project-name
\`\`\`

## Quick Start

\`\`\`typescript
import { foo } from 'project-name'
foo()
\`\`\`

## API Reference

### `functionName(param: Type): ReturnType`

Description of what it does.

## License

MIT
```

## API Doc Format

```markdown
### `functionName(param1: Type, param2?: OptionalType): ReturnType`

Brief description.

**Parameters:**
- `param1` - Description
- `param2` - Optional. Description

**Returns:** Description of return value

**Example:**
\`\`\`typescript
const result = functionName('value')
\`\`\`
```
