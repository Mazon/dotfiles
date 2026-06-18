import type { ReviewDiff, ReviewDiffMode, ReviewFileDiff, ReviewHunk } from "./git.js";
export declare const REVIEW_DIFF_SESSION_TYPE = "review-diff-session";
export type ReviewCommentStatus = "approved" | "dismissed" | "edited";
export interface ReviewDraftComment {
    id: string;
    file: string;
    line?: number;
    hunkId?: string;
    previewLineId?: string;
    oldNum?: number | null;
    newNum?: number | null;
    lineType?: ReviewHunk["lines"][number]["type"];
    body: string;
    createdAt: string;
    status: ReviewCommentStatus;
    originalBody?: string;
}
export interface ReviewDiffSession {
    mode: ReviewDiffMode;
    selectedFile?: string;
    selectedHunk?: string;
    selectedPreviewLineId?: string;
    previewScrollTop?: number;
    selectedCommentId?: string;
    comments: ReviewDraftComment[];
    updatedAt: number;
    submittedAt?: number;
}
export declare function createReviewDiffSession(mode: ReviewDiffMode): ReviewDiffSession;
export declare function cloneReviewDiffSession(session: ReviewDiffSession): ReviewDiffSession;
export declare function getLatestReviewDiffSession(ctx: {
    sessionManager: {
        getBranch(): Array<{
            type: string;
            customType?: string;
            data?: unknown;
        }>;
    };
}): ReviewDiffSession | null;
export declare function persistReviewDiffSession(pi: {
    appendEntry(customType: string, data?: unknown): void;
}, session: ReviewDiffSession): void;
export declare function syncReviewDiffSession(session: ReviewDiffSession, diff: ReviewDiff): ReviewDiffSession;
export declare function getSelectedFile(diff: ReviewDiff, session: ReviewDiffSession): ReviewFileDiff | null;
export declare function getSelectedHunk(diff: ReviewDiff, session: ReviewDiffSession): ReviewHunk | null;
export declare function getSelectedComment(session: ReviewDiffSession): ReviewDraftComment | null;
export declare function moveSelectedFile(session: ReviewDiffSession, diff: ReviewDiff, delta: number): void;
export declare function moveSelectedHunk(session: ReviewDiffSession, diff: ReviewDiff, delta: number): void;
export declare function moveSelectedComment(session: ReviewDiffSession, delta: number): void;
export declare function createDraftComment(input: {
    session: ReviewDiffSession;
    file: string;
    body: string;
    line?: number;
    hunkId?: string;
    previewLineId?: string;
    oldNum?: number | null;
    newNum?: number | null;
    lineType?: ReviewHunk["lines"][number]["type"];
    now?: Date;
}): ReviewDraftComment;
export declare function addDraftComment(session: ReviewDiffSession, comment: ReviewDraftComment): void;
export declare function editSelectedComment(session: ReviewDiffSession, body: string): ReviewDraftComment | null;
export declare function deleteSelectedComment(session: ReviewDiffSession): ReviewDraftComment | null;
export declare function toggleSelectedCommentStatus(session: ReviewDiffSession, status: Exclude<ReviewCommentStatus, "edited">): ReviewDraftComment | null;
export declare function approveAllComments(session: ReviewDiffSession): void;
export declare function getSubmittableComments(session: ReviewDiffSession): ReviewDraftComment[];
export declare function countCommentStatuses(session: ReviewDiffSession): Record<ReviewCommentStatus, number>;
//# sourceMappingURL=session.d.ts.map