"use strict";
/* pi-pretty: multi_grep tool -- FFF-backed multi-pattern search with ripgrep/SDK fallback. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerMultiGrepTool = registerMultiGrepTool;
const typebox_1 = require("typebox");
const config_js_1 = require("../config.js");
const helpers_js_1 = require("../helpers.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
const fff_helpers_js_1 = require("../fff-helpers.js");
const multi_grep_fallback_js_1 = require("../multi-grep-fallback.js");
const noopFallback = async () => ({ text: "", matchCount: 0, limitReached: false });
function registerMultiGrepTool(pi, cwd, fffService, sdkGrepTool, ripgrepFallback = noopFallback, TextComp) {
    const TC = TextComp ?? (() => {
        const { Text } = require("@earendil-works/pi-tui");
        return Text;
    })();
    const home = process.env.HOME ?? "";
    pi.registerTool({
        name: "multi_grep",
        label: "Multi Grep",
        description: "Search file contents using multiple patterns (OR logic)",
        parameters: typebox_1.Type.Object({
            patterns: typebox_1.Type.Array(typebox_1.Type.String()),
            path: typebox_1.Type.Optional(typebox_1.Type.String()),
            constraints: typebox_1.Type.Optional(typebox_1.Type.String()),
            context: typebox_1.Type.Optional(typebox_1.Type.Number()),
            limit: typebox_1.Type.Optional(typebox_1.Type.Number()),
        }),
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            const p = params;
            const patterns = Array.isArray(p.patterns) ? p.patterns.map(String) : [String(p.patterns ?? "")];
            // Guard: empty patterns
            if (!patterns.length || (patterns.length === 1 && !patterns[0])) {
                return { content: [{ text: "patterns array must have at least 1 element", type: "text" }], details: { _type: "grepResult" } };
            }
            // Guard: aborted signal
            if (sig?.aborted) {
                return { content: [{ text: "Aborted", type: "text" }], details: { _type: "grepResult" } };
            }
            const constraintsStr = p.constraints ? String(p.constraints) : undefined;
            const context = typeof p.context === "number" ? p.context : undefined;
            const effectiveLimit = typeof p.limit === "number" ? p.limit : 200;
            const alternationPattern = patterns.length === 1 ? patterns[0] : patterns.join("|");
            const hasNativeConstraints = Boolean(constraintsStr);
            const parsedConstraints = constraintsStr ? (0, multi_grep_fallback_js_1.parseMultiGrepConstraints)(constraintsStr) : null;
            const requestedConstraints = parsedConstraints?.ok ? constraintsStr : undefined;
            let effectivePath = p.path ? String(p.path) : undefined;
            const requestedPath = parsedConstraints?.ok ? parsedConstraints.tokens[0] : undefined;
            if (requestedPath && !effectivePath)
                effectivePath = requestedPath;
            // 1. FFF multiGrep (no constraints AND no path)
            if (fffService?.isAvailable && !hasNativeConstraints && !effectivePath) {
                try {
                    const fff = fffService.getFinder();
                    if (!fff)
                        throw new Error("FFF finder not available");
                    const grepResult = fff.multiGrep({
                        patterns,
                        pageSize: effectiveLimit,
                        smartCase: !shouldIgnoreCase(patterns),
                        beforeContext: context ?? 0,
                        afterContext: context ?? 0,
                    });
                    if (grepResult.ok) {
                        const grep = grepResult.value;
                        const items = grep.items.slice(0, effectiveLimit);
                        const cursorStore = fffService.getCursorStore();
                        const notices = [];
                        if (fffService.partialIndex)
                            notices.push("Warning: partial file index");
                        if (items.length >= effectiveLimit)
                            notices.push(`${effectiveLimit} limit reached`);
                        if (grep.nextCursor) {
                            const cursorId = cursorStore.store(grep.nextCursor);
                            notices.push(`More results available: cursor="${cursorId}"`);
                        }
                        const text = appendNotices((0, fff_helpers_js_1.fffFormatGrepText)(items, effectiveLimit), notices);
                        return { content: [{ type: "text", text }], details: { _type: "grepResult", text, pattern: alternationPattern, matchCount: items.length } };
                    }
                    // FFF failure -> return error directly
                    return { content: [{ type: "text", text: grepResult.error || "multi_grep failed" }], details: { _type: "grepResult", text: "", pattern: alternationPattern, matchCount: 0 } };
                }
                catch { /* fall through */ }
            }
            // 2. Ripgrep fallback
            if (requestedConstraints || !sdkGrepTool) {
                try {
                    const pathBacked = Boolean(requestedConstraints && requestedPath && !Boolean(p.path) && !requestedConstraints.includes("*") && !requestedConstraints.includes("?"));
                    const constraintsForRg = pathBacked ? undefined : requestedConstraints;
                    const notices = [];
                    if (!fffService?.isAvailable)
                        notices.push("FFF unavailable, used ripgrep fallback");
                    else if (hasNativeConstraints)
                        notices.push("Used ripgrep fallback for constrained search");
                    else
                        notices.push("Used ripgrep fallback");
                    const rgResult = await ripgrepFallback({
                        cwd, patterns, path: effectivePath, constraints: constraintsForRg,
                        ignoreCase: shouldIgnoreCase(patterns), context, limit: effectiveLimit, signal: sig,
                    });
                    const text = (0, helpers_js_1.normalizeLineEndings)(rgResult.text) || "No matches found";
                    if (rgResult.limitReached)
                        notices.push(`${effectiveLimit} limit reached`);
                    return { content: [{ type: "text", text: appendNotices(text, notices) }], details: { _type: "grepResult", text, pattern: alternationPattern, matchCount: rgResult.matchCount } };
                }
                catch (error) {
                    return { content: [{ type: "text", text: `multi_grep error: ${error instanceof Error ? error.message : String(error)}` }], details: { _type: "grepResult", text: "", pattern: alternationPattern, matchCount: 0 } };
                }
            }
            // 3. SDK grep fallback
            try {
                const notices = [];
                if (!fffService?.isAvailable)
                    notices.push("FFF unavailable, used SDK grep fallback");
                const result = await sdkGrepTool.execute(tid, { pattern: alternationPattern, path: effectivePath, ignoreCase: shouldIgnoreCase(patterns), context, limit: effectiveLimit }, sig, null, ctx);
                const tc = getText(result);
                result.content = [{ type: "text", text: appendNotices(tc, notices) }];
                result.details = { _type: "grepResult", text: tc, pattern: alternationPattern, matchCount: tc ? tc.trim().split("\n").filter(Boolean).length : 0 };
                return result;
            }
            catch (error) {
                return { content: [{ type: "text", text: `multi_grep error: ${error instanceof Error ? error.message : String(error)}` }], details: { _type: "grepResult", text: "", pattern: alternationPattern, matchCount: 0 } };
            }
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            const patterns = Array.isArray(args.patterns) ? args.patterns.map((p) => String(p)) : [];
            const limit = typeof args.limit === "number" ? args.limit : undefined;
            const path = args.path === null || args.path === undefined ? "<missing>" : (0, helpers_js_1.shortPath)(cwd, home, String(args.path));
            const literal = args.literal === true;
            const patternStr = patterns.length === 0 ? "" : patterns.length === 1 ? patterns[0] : patterns.length === 2 ? `${patterns[0]}|${patterns[1]}` : `${patterns[0]}|${patterns[1]}|+${patterns.length - 2}`;
            let out = `${theme.fg("toolTitle", theme.bold("mgrep"))} ${theme.fg("accent", `/${patternStr || ""}/`)}${theme.fg("toolOutput", ` in ${path}`)}`;
            if (literal)
                out += theme.fg("dim", ` (literal)`);
            if (limit !== undefined)
                out += theme.fg("dim", ` limit ${limit}`);
            text.setText((0, render_js_1.fillToolBackground)(`\n  ${out}`, ctx.isError ? config_js_1.BG_ERROR : undefined));
            return text;
        },
        renderResult(result, _opt, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            if (ctx.isError) {
                text.setText((0, render_js_1.renderToolError)(getText(result) || "Error", theme));
                return text;
            }
            const d = result.details;
            if (d?._type === "grepResult" && d.text) {
                const lines = d.text.split("\n");
                const maxShow = ctx.expanded ? lines.length : Math.min(lines.length, config_js_1.MAX_PREVIEW_LINES);
                const show = lines.slice(0, maxShow);
                const nw = Math.max(3, 5);
                let hlRe = null;
                try {
                    hlRe = new RegExp(`(${d.pattern})`, "gi");
                }
                catch { }
                const out = [];
                let currentFile = "";
                for (const line of show) {
                    const fileMatch = line.match(/^(.+?)[:-](\d+)[:-](.*)$/);
                    if (fileMatch) {
                        const [, file, lineNo, content] = fileMatch;
                        if (file !== currentFile) {
                            if (currentFile)
                                out.push("");
                            out.push(`  ${theme.fg("accent", theme.bold(file))}`);
                            currentFile = file;
                        }
                        let display = content;
                        if (hlRe)
                            display = content.replace(hlRe, (m) => `${config_js_1.RST}${theme.fg("warning", theme.bold(m))}${config_js_1.RST}`);
                        const padded = `${config_js_1.FG_LNUM}${String(lineNo).padStart(nw)}${config_js_1.RST} ${config_js_1.FG_RULE}│${config_js_1.RST} ${display}${config_js_1.RST}`;
                        out.push(`  ${padded}`);
                    }
                    else if (line.trim()) {
                        out.push(`  ${config_js_1.FG_DIM}  ${line.trim()}${config_js_1.RST}`);
                    }
                }
                const preview = out.join("\n");
                const more = lines.length > maxShow ? `\n${config_js_1.FG_DIM}  ... ${lines.length - maxShow} more lines${config_js_1.RST}` : "";
                text.setText((0, render_js_1.fillToolBackground)(`  ${config_js_1.FG_DIM}${d.matchCount} matches${config_js_1.RST}${(0, render_js_1.renderToolMetrics)(result)}\n${preview}${more}`));
                return text;
            }
            const fc = result.content?.[0];
            text.setText((0, render_js_1.fillToolBackground)(`  ${theme.fg("dim", fc && "text" in fc ? String(fc.text).slice(0, 120) : "no matches")}`));
            return text;
        },
    });
}
function shouldIgnoreCase(patterns) { return !patterns.some((p) => /[A-Z]/.test(p)); }
function appendNotices(text, notices) { return notices.length ? `${text}\n\n[${notices.join(". ")}]` : text; }
function getText(result) { return (result.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n") ?? ""; }
//# sourceMappingURL=multi-grep.js.map