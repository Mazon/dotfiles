/**
 * resolve-lines.ts — Hunk-based line number resolution
 *
 * Matches an `existing_code` snippet from an LLM review comment against
 * parsed diff hunks to backfill `startLine`/`endLine`. Ported from
 * alibaba/open-code-review's internal/diff/resolver.go three-tier approach.
 *
 * Tiers:
 *   1. New-side match (context + added lines with new-file line numbers)
 *   2. Old-side match (context + deleted lines with old-file line numbers)
 *   3. File-content scan (consecutive match in full new-file content)
 */
import type { ParsedDiff } from "./diff.js";
export interface ResolvedLines {
    startLine: number;
    endLine: number;
}
export interface Unresolved {
    unresolved: true;
}
export type LinesResult = ResolvedLines | Unresolved;
/**
 * Resolve line numbers for an `existing_code` snippet against a parsed diff.
 *
 * Tries three tiers:
 *   1. New-side hunk match (context + added lines)
 *   2. Old-side hunk match (context + deleted lines)
 *   3. Full file-content scan (if `fileContent` is provided)
 *
 * @param existingCode - The code snippet from the LLM comment
 * @param parsedDiff   - Parsed diff for the file (from parsePatchFiles or parseDiff)
 * @param fileContent  - Optional full new-file content for fallback scan
 * @returns Resolved line numbers or Unresolved
 */
export declare function resolveLines(existingCode: string, parsedDiff: ParsedDiff, fileContent?: string): LinesResult;
/**
 * Convenience wrapper: resolve from a raw unified diff string instead of
 * a pre-parsed ParsedDiff. Parses the diff internally.
 *
 * @param existingCode - The code snippet from the LLM comment
 * @param unifiedDiff  - Raw unified diff text (single file)
 * @param fileContent  - Optional full new-file content for fallback scan
 */
export declare function resolveLinesFromPatch(existingCode: string, unifiedDiff: string, fileContent?: string): LinesResult;
//# sourceMappingURL=resolve-lines.d.ts.map