import type { ReviewDiff } from "./git.js";
export interface ReviewExportOptions {
    includeRawDiff?: boolean;
    maxLinesPerHunk?: number;
}
export declare function formatReviewMarkdown(diff: ReviewDiff, options?: ReviewExportOptions): string;
//# sourceMappingURL=export.d.ts.map