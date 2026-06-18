import type { Theme } from "@earendil-works/pi-coding-agent";
import { renderReviewFilePreview } from "./file-preview.js";
import { type ReviewDiff } from "./git.js";
import { type ReviewDiffSession } from "./session.js";
export type ReviewDiffPaneAction = {
    type: "cancel";
} | {
    type: "refresh";
} | {
    type: "add-comment";
} | {
    type: "edit-comment";
} | {
    type: "open-location";
} | {
    type: "copy-location";
} | {
    type: "delete-comment";
} | {
    type: "approve-all";
} | {
    type: "submit";
};
interface ReviewDiffPaneOptions {
    requestRender?: () => void;
    renderFilePreview?: typeof renderReviewFilePreview;
}
export declare class ReviewDiffPane {
    private diff;
    private session;
    private theme;
    private onDone;
    private cachedWidth?;
    private cachedLines?;
    private focus;
    private previewKey?;
    private previewLines?;
    private previewPending;
    private previewRenderCache;
    private readonly requestRender?;
    private readonly renderFilePreview;
    constructor(diff: ReviewDiff, session: ReviewDiffSession, theme: Theme, onDone: (action: ReviewDiffPaneAction) => void, options?: ReviewDiffPaneOptions);
    handleInput(data: string): void;
    render(width: number): string[];
    invalidate(): void;
    updateReviewState(diff: ReviewDiff, session: ReviewDiffSession): void;
    private ensurePreview;
    private renderFixedPreviewRows;
    private applyPreviewSelection;
    private move;
    private movePage;
    private moveToBoundary;
    private focusHeader;
    private styleForFocus;
}
export {};
//# sourceMappingURL=tui.d.ts.map