"use strict";
/* pi-pretty: grep tool -- FFF-backed text search with SDK fallback. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerGrepTool = registerGrepTool;
const pi_coding_agent_1 = require("@earendil-works/pi-coding-agent");
const config_js_1 = require("../config.js");
const helpers_js_1 = require("../helpers.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
const fff_helpers_js_1 = require("../fff-helpers.js");
const invalidArg = "<missing>";
function registerGrepTool(pi, cwd, fffService, sdkTool, TextComp) {
    const T = TextComp ?? (() => { const m = require("@earendil-works/pi-tui"); return m.Text; })();
    const home = process.env.HOME ?? "";
    pi.registerTool({
        name: "grep",
        label: "Grep",
        description: sdkTool.description ?? "Search file contents by pattern",
        parameters: sdkTool.parameters,
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            const p = params;
            const pattern = String(p.pattern ?? "");
            const path = p.path ? String(p.path) : undefined;
            const glob = p.glob ? String(p.glob) : undefined;
            const context = typeof p.context === "number" ? p.context : 0;
            const limit = typeof p.limit === "number" ? p.limit : 200;
            const literal = p.literal === true;
            if (fffService?.isAvailable && !path && !glob) {
                try {
                    const fff = fffService.getFinder();
                    if (!fff)
                        throw new Error("FFF finder not available");
                    const effectiveLimit = Math.max(1, limit);
                    const grepResult = fff.grep(pattern, { pageSize: effectiveLimit, mode: literal ? "plain" : "regex", beforeContext: context, afterContext: context });
                    if (grepResult.ok) {
                        const grep = grepResult.value;
                        const items = grep.items.slice(0, effectiveLimit);
                        const cursorStore = fffService.getCursorStore();
                        const notices = [];
                        if (fffService.partialIndex)
                            notices.push("Warning: partial file index");
                        if (items.length >= effectiveLimit)
                            notices.push(`${effectiveLimit} limit reached`);
                        if (grep.regexFallbackError)
                            notices.push(`Regex failed: ${grep.regexFallbackError}, used literal match`);
                        if (grep.nextCursor) {
                            const cursorId = cursorStore.store(grep.nextCursor);
                            notices.push(`More results available: cursor="${cursorId}"`);
                        }
                        const text = appendNotices((0, fff_helpers_js_1.fffFormatGrepText)(items, effectiveLimit), notices);
                        return { content: [{ type: "text", text }], details: { _type: "grepResult", text, pattern, matchCount: items.length } };
                    }
                }
                catch { /* fall through */ }
            }
            const result = await sdkTool.execute(tid, p, sig, undefined, ctx);
            for (const c of (result.content ?? [])) {
                if (c.type === "text")
                    c.text = (0, helpers_js_1.normalizeLineEndings)(c.text);
            }
            const tc = (result.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n") ?? "";
            result.details = { _type: "grepResult", text: tc, pattern, matchCount: tc ? tc.trim().split("\n").filter(Boolean).length : 0 };
            return result;
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new T("", 0, 0);
            const pattern = args.pattern === null || args.pattern === undefined ? invalidArg : String(args.pattern);
            const path = args.path === null || args.path === undefined ? invalidArg : (0, helpers_js_1.shortPath)(cwd, home, String(args.path));
            const glob = args.glob;
            const limit = args.limit;
            const literal = args.literal === true;
            const caseInsensitive = args.caseInsensitive === true || args.ignoreCase === true;
            let out = `${theme.fg("toolTitle", theme.bold("grep"))} ${theme.fg("accent", `/${pattern || ""}/`)}${theme.fg("toolOutput", ` in ${path}`)}`;
            if (glob)
                out += theme.fg("dim", ` (${String(glob)})`);
            if (limit !== undefined && limit !== null)
                out += theme.fg("dim", ` limit ${limit}`);
            if (literal)
                out += theme.fg("dim", ` (literal)`);
            if (caseInsensitive)
                out += theme.fg("dim", ` (case-insensitive)`);
            text.setText((0, render_js_1.fillToolBackground)(`\n  ${out}`, ctx.isError ? config_js_1.BG_ERROR : undefined));
            return text;
        },
        renderResult(result, _opt, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new T("", 0, 0);
            if (ctx.isError) {
                text.setText((0, render_js_1.renderToolError)((result.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n") || "Error", theme));
                return text;
            }
            const d = result.details;
            if (d?._type === "grepResult" && d.text) {
                const lines = d.text.split("\n");
                const maxShow = ctx.expanded ? lines.length : Math.min(lines.length, config_js_1.MAX_PREVIEW_LINES);
                const show = lines.slice(0, maxShow);
                const remaining = lines.length - maxShow;
                const out = [];
                for (const line of show) {
                    if (!line)
                        continue;
                    out.push(theme.fg("toolOutput", line));
                }
                if (remaining > 0) {
                    out.push(theme.fg("muted", `… (${remaining} more ${remaining === 1 ? "line" : "lines"}, ${(0, pi_coding_agent_1.keyHint)("app.tools.expand", "to expand")})`));
                }
                const body = out.map((l) => `  ${l}`).join("\n") + "\n\n";
                text.setText((0, render_js_1.fillToolBackground)(body, ctx.isError ? config_js_1.BG_ERROR : undefined));
                return text;
            }
            const fc = result.content?.[0];
            const fallback = fc && "text" in fc ? String(fc.text).slice(0, 120) : "no matches";
            text.setText((0, render_js_1.fillToolBackground)(`  ${theme.fg("dim", fallback)}`, ctx.isError ? config_js_1.BG_ERROR : undefined));
            return text;
        },
    });
}
function appendNotices(text, notices) { return notices.length ? `${text}\n\n[${notices.join(". ")}]` : text; }
//# sourceMappingURL=grep.js.map