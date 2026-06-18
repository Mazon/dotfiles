/**
 * hunk-bridge.ts — Thin subprocess wrapper for the `hunk` CLI.
 *
 * Detects availability of the `hunk` binary, pipes unified diff content to
 * `hunk patch -` for interactive review, and extracts session comments
 * after the review completes.
 */
export interface HunkComment {
    filePath: string;
    newLine: number;
    oldLine: number;
    summary: string;
}
export interface HunkReviewResult {
    available: boolean;
    comments?: HunkComment[];
}
/**
 * Check whether the `hunk` CLI is available on the current PATH.
 *
 * Runs `hunk --version` with a short timeout and returns `true` if it
 * succeeds, `false` otherwise.
 */
export declare function checkHunkAvailable(): Promise<boolean>;
/**
 * Parse raw JSON output from `hunk session comment list --json` into
 * `HunkComment[]`.
 *
 * Handles both snake_case and camelCase field names emitted by the CLI.
 */
export declare function parseHunkComments(rawJson: string): HunkComment[];
/**
 * Run `hunk session comment list --repo <cwd> --json` and return parsed
 * comments. Returns an empty array on any failure (CLI not found,
 * no active session, parse error, etc.).
 */
export declare function extractComments(cwd: string): HunkComment[];
/**
 * Launch an interactive `hunk patch -` review session.
 *
 * If the `hunk` CLI is not available, returns `{ available: false }`
 * immediately without throwing.
 *
 * Otherwise:
 *  1. Spawns `hunk patch -` in the given `cwd` with `diffRaw` piped to
 *     stdin while inheriting the parent process TTY (stdout / stderr).
 *  2. Waits for the subprocess to exit.
 *  3. Extracts any session comments left during the review via
 *     `hunk session comment list --repo <cwd> --json`.
 *
 * @returns A `HunkReviewResult` with availability flag and any comments.
 */
export declare function launchHunkReview(cwd: string, diffRaw: string): Promise<HunkReviewResult>;
//# sourceMappingURL=hunk-bridge.d.ts.map