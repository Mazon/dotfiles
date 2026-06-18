import type { ReviewDiff, ReviewFileDiff, ReviewHunk, ReviewLine } from "./git.js";
import type { ReviewDiffSession, ReviewDraftComment } from "./session.js";
export interface ReviewViewportLine {
    id: string;
    filePath: string;
    hunkId: string;
    kind: "hunk-header" | ReviewLine["type"];
    oldNum: number | null;
    newNum: number | null;
    content: string;
    commentCount: number;
    isSelectable: boolean;
}
export interface ReviewViewportState {
    file: ReviewFileDiff | null;
    hunk: ReviewHunk | null;
    lines: ReviewViewportLine[];
    selectedLine: ReviewViewportLine | null;
    visibleLines: ReviewViewportLine[];
    selectedLineIndex: number;
    windowStart: number;
    windowEnd: number;
}
export declare function createPreviewLineId(filePath: string, hunkId: string, line: ReviewLine, lineIndex: number): string;
export declare function createHeaderLineId(filePath: string, hunkId: string): string;
export declare function buildViewportLines(file: ReviewFileDiff | null, comments: ReviewDraftComment[], hunkId?: string): ReviewViewportLine[];
export declare function getSelectedPreviewLine(diff: ReviewDiff, session: ReviewDiffSession): ReviewViewportLine | null;
export declare function syncPreviewSelection(session: ReviewDiffSession, diff: ReviewDiff): void;
export declare function moveSelectedPreviewLine(session: ReviewDiffSession, diff: ReviewDiff, delta: number, windowSize?: number): void;
export declare function selectPreviewLineForHunk(session: ReviewDiffSession, diff: ReviewDiff, hunkId?: string): void;
export declare function selectPreviewLineForComment(session: ReviewDiffSession, diff: ReviewDiff): void;
export declare function getViewportState(diff: ReviewDiff, session: ReviewDiffSession, windowSize?: number): ReviewViewportState;
//# sourceMappingURL=model.d.ts.map