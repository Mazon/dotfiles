import type { ReviewDiff } from "./git.js";
export interface ReviewPanelOptions {
    file?: string;
    hunkId?: string;
    maxFiles?: number;
    maxHunks?: number;
    maxLinesPerHunk?: number;
}
export interface ReviewComment {
    id: string;
    file: string;
    line?: number;
    hunkId?: string;
    body: string;
    createdAt: string;
}
export declare function formatInteractiveReviewPanel(diff: ReviewDiff, comments?: ReviewComment[], options?: ReviewPanelOptions): string;
export declare function formatReviewComments(comments: ReviewComment[]): string;
export declare function createReviewComment(input: {
    comments: ReviewComment[];
    file: string;
    body: string;
    line?: number;
    hunkId?: string;
    now?: Date;
}): ReviewComment;
//# sourceMappingURL=interactive.d.ts.map