const DEFAULT_VIEWPORT_WINDOW = 18;
export function createPreviewLineId(filePath, hunkId, line, lineIndex) {
    return `${filePath}:${hunkId}:${line.type}:${line.oldNum ?? "_"}:${line.newNum ?? "_"}:${lineIndex}`;
}
export function createHeaderLineId(filePath, hunkId) {
    return `${filePath}:${hunkId}:header`;
}
export function buildViewportLines(file, comments, hunkId) {
    if (!file)
        return [];
    const hunks = hunkId ? file.hunks.filter((hunk) => hunk.id === hunkId) : file.hunks;
    const lines = [];
    for (const hunk of hunks) {
        lines.push({
            id: createHeaderLineId(file.path, hunk.id),
            filePath: file.path,
            hunkId: hunk.id,
            kind: "hunk-header",
            oldNum: hunk.oldStart,
            newNum: hunk.newStart,
            content: hunk.header,
            commentCount: comments.filter((comment) => comment.hunkId === hunk.id && !comment.previewLineId).length,
            isSelectable: false,
        });
        hunk.lines.forEach((line, index) => {
            const id = createPreviewLineId(file.path, hunk.id, line, index);
            lines.push({
                id,
                filePath: file.path,
                hunkId: hunk.id,
                kind: line.type,
                oldNum: line.oldNum,
                newNum: line.newNum,
                content: line.content,
                commentCount: comments.filter((comment) => comment.previewLineId === id).length,
                isSelectable: true,
            });
        });
    }
    return lines;
}
export function getSelectedPreviewLine(diff, session) {
    const file = getSelectedFile(diff, session);
    const hunk = getSelectedHunk(diff, session);
    if (!file || !hunk)
        return null;
    const lines = buildViewportLines(file, session.comments, hunk.id);
    if (lines.length === 0)
        return null;
    if (session.selectedPreviewLineId) {
        const selected = lines.find((line) => line.id === session.selectedPreviewLineId);
        if (selected)
            return selected;
    }
    const scrollIndex = clampIndex(session.previewScrollTop ?? 0, lines.length);
    const scrolledLine = lines[scrollIndex];
    if (scrolledLine?.isSelectable)
        return scrolledLine;
    return firstSelectableLine(lines) ?? scrolledLine ?? null;
}
export function syncPreviewSelection(session, diff) {
    const file = getSelectedFile(diff, session);
    const hunk = getSelectedHunk(diff, session);
    if (!file || !hunk) {
        session.selectedPreviewLineId = undefined;
        session.previewScrollTop = 0;
        return;
    }
    const lines = buildViewportLines(file, session.comments, hunk.id);
    if (lines.length === 0) {
        session.selectedPreviewLineId = undefined;
        session.previewScrollTop = 0;
        return;
    }
    const selected = session.selectedPreviewLineId
        ? lines.find((line) => line.id === session.selectedPreviewLineId && line.isSelectable)
        : null;
    if (!selected) {
        session.selectedPreviewLineId = firstSelectableLine(lines)?.id;
    }
    clampPreviewScroll(session, lines.length, DEFAULT_VIEWPORT_WINDOW);
}
export function moveSelectedPreviewLine(session, diff, delta, windowSize = DEFAULT_VIEWPORT_WINDOW) {
    const file = getSelectedFile(diff, session);
    const hunk = getSelectedHunk(diff, session);
    if (!file || !hunk) {
        session.previewScrollTop = 0;
        return;
    }
    const lines = buildViewportLines(file, session.comments, hunk.id);
    if (lines.length === 0) {
        session.previewScrollTop = 0;
        return;
    }
    const selectableLines = lines.filter((l) => l.isSelectable);
    if (selectableLines.length === 0)
        return;
    const currentPos = session.selectedPreviewLineId
        ? Math.max(0, selectableLines.findIndex((l) => l.id === session.selectedPreviewLineId))
        : 0;
    const newPos = clampIndex(currentPos + delta, selectableLines.length);
    const newLine = selectableLines[newPos];
    session.selectedPreviewLineId = newLine?.id;
    const cursorIndex = lines.findIndex((l) => l.id === newLine?.id);
    session.previewScrollTop =
        cursorIndex >= 0 ? clampScrollTop(Math.max(0, cursorIndex - 1), lines.length, windowSize) : 0;
}
export function selectPreviewLineForHunk(session, diff, hunkId) {
    const file = getSelectedFile(diff, session);
    if (!file) {
        session.selectedPreviewLineId = undefined;
        session.previewScrollTop = 0;
        return;
    }
    const lines = buildViewportLines(file, session.comments, hunkId);
    const selected = firstSelectableLine(lines, hunkId);
    session.selectedPreviewLineId = selected?.id;
    session.previewScrollTop = 0;
    if (selected?.hunkId)
        session.selectedHunk = selected.hunkId;
}
export function selectPreviewLineForComment(session, diff) {
    const comment = getSelectedComment(session);
    if (!comment)
        return;
    const file = getSelectedFile(diff, session);
    if (!file || file.path !== comment.file) {
        session.selectedFile = comment.file;
    }
    if (comment.hunkId)
        session.selectedHunk = comment.hunkId;
    const nextFile = getSelectedFile(diff, session);
    const nextHunk = getSelectedHunk(diff, session);
    if (!nextFile || !nextHunk)
        return;
    const lines = buildViewportLines(nextFile, session.comments, nextHunk.id);
    if (comment.previewLineId) {
        session.selectedPreviewLineId = comment.previewLineId;
        const selectedIndex = lines.findIndex((line) => line.id === comment.previewLineId);
        session.previewScrollTop = clampScrollTop(Math.max(0, selectedIndex - 1), lines.length, DEFAULT_VIEWPORT_WINDOW);
        return;
    }
    syncPreviewSelection(session, diff);
}
export function getViewportState(diff, session, windowSize = DEFAULT_VIEWPORT_WINDOW) {
    const file = getSelectedFile(diff, session);
    const hunk = getSelectedHunk(diff, session);
    const lines = buildViewportLines(file, session.comments, hunk?.id);
    const selectedLine = getSelectedPreviewLine(diff, session);
    const selectedLineIndex = Math.max(0, lines.findIndex((line) => line.id === selectedLine?.id));
    const windowStart = clampScrollTop(session.previewScrollTop ?? 0, lines.length, windowSize);
    const windowEnd = Math.min(lines.length, windowStart + windowSize);
    return {
        file,
        hunk,
        lines,
        selectedLine,
        visibleLines: lines.slice(windowStart, windowEnd),
        selectedLineIndex,
        windowStart,
        windowEnd,
    };
}
function clampPreviewScroll(session, lineCount, windowSize) {
    session.previewScrollTop = clampScrollTop(session.previewScrollTop ?? 0, lineCount, windowSize);
}
function clampScrollTop(scrollTop, lineCount, windowSize) {
    if (lineCount <= 0)
        return 0;
    const maxScrollTop = Math.max(0, lineCount - Math.max(1, windowSize));
    return Math.max(0, Math.min(scrollTop, maxScrollTop));
}
function firstSelectableLine(lines, hunkId) {
    return lines.find((line) => line.isSelectable && (!hunkId || line.hunkId === hunkId)) ?? null;
}
function clampIndex(index, length) {
    return Math.max(0, Math.min(index, Math.max(0, length - 1)));
}
function getSelectedFile(diff, session) {
    if (!session.selectedFile)
        return diff.files[0] ?? null;
    return diff.files.find((file) => file.path === session.selectedFile || file.oldPath === session.selectedFile) ?? null;
}
function getSelectedHunk(diff, session) {
    const file = getSelectedFile(diff, session);
    if (!file)
        return null;
    if (!session.selectedHunk)
        return file.hunks[0] ?? null;
    return file.hunks.find((hunk) => hunk.id === session.selectedHunk) ?? file.hunks[0] ?? null;
}
function getSelectedComment(session) {
    if (!session.selectedCommentId)
        return null;
    return session.comments.find((comment) => comment.id === session.selectedCommentId) ?? null;
}
//# sourceMappingURL=model.js.map