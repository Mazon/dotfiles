# Defects Command

Triage security findings from DefectDojo by bridging the gap between reports and the live codebase.

## Usage

### Triage findings for current repo
```
/defects
```

### Triage findings for a specific repo
```
/defects <repo>
```

---

## Implementation Instructions

When this command is invoked by the Prime agent:

### 1. Identify Environment

First, identify the current git repository name. If a `<repo>` argument was provided, use that instead.

### 2. Fetch Findings

Use the DefectDojo MCP to find the Product or Engagement matching this repository name. Retrieve only all active and open findings for this scope.

### 3. Analysis & Discovery

For each finding retrieved:

- Identify the CVE/CWE, the vulnerable component (library/version), and the specific vulnerable function or logic flaw.
- Search the current codebase for instances of this component or function.

### 4. Reachability Investigation (Source-to-Sink)

Trace the data flow to determine exploitability:

- **Presence:** Is the vulnerable library actually imported or linked?
- **Execution:** Is the specific vulnerable function/method called anywhere in the code?
- **Controllability:** Can user-controlled input (source) reach the vulnerable function (sink) without proper sanitization?
- **Mitigation:** Are there existing architectural safeguards (e.g., WAF rules, middleware, or sandboxing) that neutralize the threat?

### 5. VEX Categorization

Classify each finding into one of the following VEX (Vulnerability-Exploitability eXchange) statuses:

| VEX Status | Meaning |
|------------|---------|
| `not_affected` | The code does not use the vulnerable sub-component or function |
| `affected` | The vulnerability is reachable and potentially exploitable |
| `fixed` | The version in the codebase is already patched or upgraded |
| `under_investigation` | The analysis is inconclusive and requires manual review |

### 6. Output Report

For each finding, provide:

- **Finding ID & CVE:** [ID] ([CVE-YYYY-XXXX])
- **VEX Status:** [Category]
- **Justification:** A concise technical explanation (e.g., "Library X is present, but we only utilize the 'StringHelper' module; the vulnerable 'XMLParser' module is never invoked.")
- **Action Plan:**
  - If `affected`: Provide a remediation code snippet or upgrade command.
  - If `not_affected`: Provide the specific VEX justification string to be updated in DefectDojo.

### 7. Optional Ignore Files

Communicate and ask if the user would like to create or update `.trivyignore` or `.semgrepignore` file with the findings that were `not_affected`.

## Error Handling

**DefectDojo MCP unavailable:**
If the DefectDojo MCP connection fails or returns API errors, inform the user and suggest checking the MCP configuration and API token.

**No active findings found:**
If no active or open findings are found for the repository, inform the user that no triage is needed.

**Repository not matched:**
If no matching Product or Engagement is found in DefectDojo, suggest the user provide an explicit repo name via `/defects <repo>`.

**Inconclusive analysis:**
If the reachability investigation cannot determine exploitability with confidence, categorize the finding as `under_investigation` and recommend manual review by a security engineer.
