export const REVIEW_DIFF_SESSION_TYPE = "review-diff-session";
export function createReviewDiffSession(mode) {
    return {
        mode,
        comments: [],
        previewScrollTop: 0,
        updatedAt: Date.now(),
    };
}
export function cloneReviewDiffSession(session) {
    return {
        ...session,
        comments: session.comments.map((comment) => ({ ...comment })),
    };
}
export function getLatestReviewDiffSession(ctx) {
    const entries = ctx.sessionManager.getBranch();
    for (let i = entries.length - 1; i >= 0; i--) {
        const entry = entries[i];
        if (entry.type === "custom" && entry.customType === REVIEW_DIFF_SESSION_TYPE && entry.data?.mode) {
            return entry.data;
        }
    }
    return null;
}
export function persistReviewDiffSession(pi, session) {
    session.updatedAt = Date.now();
    pi.appendEntry(REVIEW_DIFF_SESSION_TYPE, session);
}
export function syncReviewDiffSession(session, diff) {
    const next = cloneReviewDiffSession(session);
    const previousFile = next.selectedFile;
    const previousHunk = next.selectedHunk;
    const selectedFile = getSelectedFile(diff, next) ?? diff.files[0] ?? null;
    next.selectedFile = selectedFile?.path;
    const selectedHunk = selectedFile ? (getSelectedHunk(diff, next) ?? selectedFile.hunks[0] ?? null) : null;
    next.selectedHunk = selectedHunk?.id;
    if (next.selectedFile !== previousFile || next.selectedHunk !== previousHunk) {
        next.previewScrollTop = 0;
    }
    if (next.comments.length === 0) {
        next.selectedCommentId = undefined;
    }
    else if (!next.selectedCommentId || !next.comments.some((comment) => comment.id === next.selectedCommentId)) {
        next.selectedCommentId = next.comments[0]?.id;
    }
    return next;
}
export function getSelectedFile(diff, session) {
    if (!session.selectedFile)
        return null;
    return diff.files.find((file) => file.path === session.selectedFile || file.oldPath === session.selectedFile) ?? null;
}
export function getSelectedHunk(diff, session) {
    const file = getSelectedFile(diff, session);
    if (!file || !session.selectedHunk)
        return null;
    return file.hunks.find((hunk) => hunk.id === session.selectedHunk) ?? null;
}
export function getSelectedComment(session) {
    if (!session.selectedCommentId)
        return null;
    return session.comments.find((comment) => comment.id === session.selectedCommentId) ?? null;
}
export function moveSelectedFile(session, diff, delta) {
    if (diff.files.length === 0) {
        session.selectedFile = undefined;
        session.selectedHunk = undefined;
        session.previewScrollTop = 0;
        return;
    }
    const currentPath = getSelectedFile(diff, session)?.path;
    const currentIndex = Math.max(0, diff.files.findIndex((file) => file.path === currentPath));
    const nextIndex = clampIndex(currentIndex + delta, diff.files.length);
    const file = diff.files[nextIndex];
    session.selectedFile = file?.path;
    session.selectedHunk = file?.hunks[0]?.id;
    session.selectedPreviewLineId = undefined;
    session.previewScrollTop = 0;
}
export function moveSelectedHunk(session, diff, delta) {
    const file = getSelectedFile(diff, session);
    if (!file || file.hunks.length === 0) {
        session.selectedHunk = undefined;
        session.previewScrollTop = 0;
        return;
    }
    const currentId = getSelectedHunk(diff, session)?.id;
    const currentIndex = Math.max(0, file.hunks.findIndex((hunk) => hunk.id === currentId));
    const nextIndex = clampIndex(currentIndex + delta, file.hunks.length);
    session.selectedHunk = file.hunks[nextIndex]?.id;
    session.selectedPreviewLineId = undefined;
    session.previewScrollTop = 0;
}
export function moveSelectedComment(session, delta) {
    if (session.comments.length === 0) {
        session.selectedCommentId = undefined;
        return;
    }
    const currentIndex = Math.max(0, session.comments.findIndex((comment) => comment.id === session.selectedCommentId));
    const nextIndex = clampIndex(currentIndex + delta, session.comments.length);
    session.selectedCommentId = session.comments[nextIndex]?.id;
}
export function createDraftComment(input) {
    const next = input.session.comments.length + 1;
    return {
        id: `C${String(next).padStart(3, "0")}`,
        file: input.file,
        line: input.line,
        hunkId: input.hunkId,
        previewLineId: input.previewLineId,
        oldNum: input.oldNum,
        newNum: input.newNum,
        lineType: input.lineType,
        body: input.body,
        createdAt: (input.now ?? new Date()).toISOString(),
        status: "approved",
    };
}
export function addDraftComment(session, comment) {
    session.comments.push(comment);
    session.selectedCommentId = comment.id;
}
export function editSelectedComment(session, body) {
    const comment = getSelectedComment(session);
    if (!comment)
        return null;
    if (comment.body !== body) {
        comment.originalBody ??= comment.body;
        comment.body = body;
        comment.status = "edited";
    }
    return comment;
}
export function deleteSelectedComment(session) {
    const currentIndex = session.comments.findIndex((comment) => comment.id === session.selectedCommentId);
    if (currentIndex < 0)
        return null;
    const [removed] = session.comments.splice(currentIndex, 1);
    session.selectedCommentId = session.comments[Math.min(currentIndex, session.comments.length - 1)]?.id;
    return removed ?? null;
}
export function toggleSelectedCommentStatus(session, status) {
    const comment = getSelectedComment(session);
    if (!comment)
        return null;
    comment.status = comment.status === status ? "approved" : status;
    return comment;
}
export function approveAllComments(session) {
    for (const comment of session.comments) {
        comment.status = comment.status === "edited" ? "edited" : "approved";
    }
}
export function getSubmittableComments(session) {
    return session.comments.filter((comment) => comment.status === "approved" || comment.status === "edited");
}
export function countCommentStatuses(session) {
    return {
        approved: session.comments.filter((comment) => comment.status === "approved").length,
        dismissed: session.comments.filter((comment) => comment.status === "dismissed").length,
        edited: session.comments.filter((comment) => comment.status === "edited").length,
    };
}
function clampIndex(index, length) {
    return Math.max(0, Math.min(index, length - 1));
}
//# sourceMappingURL=session.js.map