import type { ReviewViewportLine } from "./model.js";
export interface ReviewFilePreviewInput {
    filePath: string;
    lines: ReviewViewportLine[];
    theme?: any;
    width: number;
}
export declare function renderReviewFilePreview(input: ReviewFilePreviewInput): Promise<string[]>;
//# sourceMappingURL=file-preview.d.ts.map