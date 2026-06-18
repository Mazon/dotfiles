"use strict";
/* pi-pretty: find tool -- FFF-backed file search with SDK fallback. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerFindTool = registerFindTool;
const node_path_1 = require("node:path");
const config_js_1 = require("../config.js");
const helpers_js_1 = require("../helpers.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
function registerFindTool(pi, cwd, fffService, sdkTool, TextComp) {
    if (!TextComp) {
        const { Text } = require("@earendil-works/pi-tui");
        TextComp = Text;
    }
    const home = process.env.HOME ?? "";
    pi.registerTool({
        name: "find",
        label: "Find",
        description: sdkTool.description ?? "Find files matching a glob pattern",
        parameters: sdkTool.parameters,
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            const pattern = String(params.pattern ?? "");
            const path = params.path ? String(params.path) : undefined;
            const limit = params.limit;
            const glob = params.glob;
            const fff = fffService?.isAvailable ? fffService.getFinder() : null;
            if (fff) {
                try {
                    const effectiveLimit = Math.max(1, typeof limit === "number" ? limit : 100);
                    const basePathResult = fff.getBasePath();
                    const basePath = basePathResult.ok ? basePathResult.value : null;
                    let cleanPath = path ?? "";
                    if (cleanPath && (0, node_path_1.isAbsolute)(cleanPath) && basePath) {
                        cleanPath = (0, node_path_1.relative)(basePath, cleanPath) || "";
                    }
                    cleanPath = cleanPath.replace(/\/$/, "");
                    const cleanPattern = pattern.startsWith("/") ? pattern.slice(1) : pattern;
                    const globPattern = cleanPath
                        ? `${cleanPath}/**/${cleanPattern}`
                        : `**/${cleanPattern}`;
                    const searchResult = fff.glob(globPattern, { pageSize: effectiveLimit });
                    if (searchResult.ok) {
                        const items = searchResult.value.items.slice(0, effectiveLimit);
                        const notices = [];
                        if (fffService?.partialIndex)
                            notices.push("Warning: partial file index");
                        if (items.length >= effectiveLimit)
                            notices.push(`${effectiveLimit} limit reached`);
                        if (searchResult.value.totalMatched > items.length)
                            notices.push(`${searchResult.value.totalMatched} total matches`);
                        const paths = items.map((i) => i.relativePath).join("\n");
                        return { content: [{ type: "text", text: paths }], details: { _type: "findResult", text: paths, pattern, matchCount: items.length, notices } };
                    }
                }
                catch { /* fall through to SDK */ }
            }
            const result = await sdkTool.execute(tid, params, sig, undefined, ctx);
            const tc = getText(result);
            result.details = { _type: "findResult", text: tc, pattern, matchCount: tc ? tc.trim().split("\n").filter(Boolean).length : 0 };
            return result;
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TextComp("", 0, 0);
            const pattern = args.pattern === null || args.pattern === undefined ? "" : String(args.pattern);
            const path = args.path === null || args.path === undefined ? "<missing>" : (0, helpers_js_1.shortPath)(cwd, home, String(args.path));
            const limit = args.limit;
            const glob = args.glob;
            const findLabel = theme.fg("toolTitle", theme.bold("find"));
            const patternPart = pattern ? theme.fg("accent", pattern) : "";
            const inPart = theme.fg("dim", " in ");
            const pathPart = theme.fg("toolOutput", path);
            const limitPart = limit !== undefined && limit !== null ? theme.fg("dim", ` limit ${limit}`) : "";
            const out = `${findLabel} ${patternPart}${inPart}${pathPart}${limitPart}`;
            text.setText((0, render_js_1.fillToolBackground)(`  \n  ${out}`, ctx.isError ? config_js_1.BG_ERROR : undefined));
            return text;
        },
        renderResult(result, _opt, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TextComp("", 0, 0);
            if (ctx.isError) {
                text.setText((0, render_js_1.renderToolError)(getText(result) || "Error", theme));
                return text;
            }
            const d = result.details;
            if (d?._type === "findResult") {
                if (!d.text.trim()) {
                    const notices = d.notices;
                    const noticeStr = notices?.length ? `\n  ${theme.fg("warning", `[${notices.join(". ")}]`)}` : "";
                    text.setText((0, render_js_1.fillToolBackground)(`  \n  ${theme.fg("dim", "0 files")}${noticeStr}\n  `));
                    return text;
                }
                const rendered = (0, render_js_1.renderFindResults)(d.text, theme).split("\n").map(l => `  ${l}`).join("\n");
                const notices = d.notices;
                const noticeStr = notices?.length ? `\n  ${theme.fg("warning", `[${notices.join(". ")}]`)}` : "";
                text.setText((0, render_js_1.fillToolBackground)(`  \n  ${theme.fg("dim", `${d.matchCount} files`)}${(0, render_js_1.renderToolMetrics)(result)}\n${rendered}${noticeStr}\n  `));
                return text;
            }
            const fc = result.content?.[0];
            text.setText((0, render_js_1.fillToolBackground)(`  \n  ${theme.fg("dim", fc && "text" in fc ? String(fc.text).slice(0, 120) : "0 files")}\n  `));
            return text;
        },
    });
}
function appendNotices(text, notices) { return notices.length ? `${text}\n\n[${notices.join(". ")}]` : text; }
function getText(result) { return (result.content ?? []).filter((c) => c.type === "text").map((c) => c.text ?? "").join("\n") ?? ""; }
//# sourceMappingURL=find.js.map