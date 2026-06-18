"use strict";
/* pi-pretty: read tool -- file reading with syntax highlighting and inline image support. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerReadTool = registerReadTool;
const config_js_1 = require("../config.js");
const helpers_js_1 = require("../helpers.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
// Simple terminal image support check
function isImageTerminal() {
    const term = (process.env.TERM_PROGRAM ?? process.env.TERM ?? "").toLowerCase();
    const proto = (process.env.PRETTY_IMAGE_PROTOCOL ?? "").toLowerCase();
    if (proto === "kitty" || proto === "iterm2")
        return true;
    if (proto === "none")
        return false;
    return ["ghostty", "kitty", "iterm.app", "wezterm", "mintty"].some((t) => term.includes(t)) || process.env.LC_TERMINAL === "iTerm2";
}
function registerReadTool(pi, cwd, _fffService, sdkTool, TextComp) {
    const TC = TextComp ?? (() => {
        const { Text } = require("@earendil-works/pi-tui");
        return Text;
    })();
    const home = process.env.HOME ?? "";
    pi.registerTool({
        name: "read",
        label: "Read",
        description: sdkTool.description ?? "Read file contents",
        parameters: sdkTool.parameters,
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            const p = params;
            const result = await sdkTool.execute(tid, p, sig, undefined, ctx);
            const imageBlock = result.content?.find((c) => c.type === "image");
            if (imageBlock) {
                result.details = { _type: "readImage", filePath: String(p.path ?? ""), data: imageBlock.data, mimeType: imageBlock.mimeType ?? "image/png" };
                return result;
            }
            const tc = (0, helpers_js_1.normalizeLineEndings)(getText(result));
            result.details = { _type: "readFile", filePath: String(p.path ?? ""), content: tc, offset: typeof p.offset === "number" ? p.offset : 0, lineCount: tc ? tc.split("\n").length : 0 };
            return result;
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            text.setText("");
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
            // Image rendering
            if (d?._type === "readImage") {
                if (ctx.showImages && isImageTerminal()) {
                    try {
                        const T = require("@earendil-works/pi-tui").Text;
                        const img = new T("", 0, 0);
                        if (d.mimeType.startsWith("image/svg")) {
                            img.setText(d.data);
                        }
                        else {
                            const pngData = require("@earendil-works/pi-coding-agent").convertToPng?.(d.data) ?? d.data;
                            img.setText(`\x1b_Ga=T,f=100,m=${d.mimeType === "image/png" ? "1" : "0"};${pngData}\x1b\\\\`);
                        }
                        return img;
                    }
                    catch { /* fall through */ }
                }
                const fc = result.content?.[0];
                text.setText((0, render_js_1.fillToolBackground)(`  ${theme.fg("dim", fc && "text" in fc ? String(fc.text).slice(0, 80) : `[image: ${d.filePath}]`)}`));
                return text;
            }
            // File content — line-numbered display
            if (d?._type === "readFile" && d.content) {
                const tw = (0, config_js_1.termWidth)();
                const lines = d.content.split("\n");
                const total = lines.length;
                const maxShow = ctx.expanded ? lines.length : Math.min(lines.length, config_js_1.MAX_PREVIEW_LINES);
                const show = lines.slice(0, maxShow);
                const nw = Math.max(3, String(total).length);
                const gw = nw + 3;
                const cw = Math.max(1, tw - gw);
                const p2 = (0, helpers_js_1.shortPath)(cwd, home, String(d.filePath ?? ""));
                const off2 = typeof d.offset === "number" ? `:${d.offset}` : "";
                const header = `${theme.fg("toolTitle", theme.bold("read"))} ${theme.fg("accent", p2)}${theme.fg("dim", off2)}`;
                const out = ["", `  ${header}`];
                out.push(`  ${config_js_1.FG_RULE}${"─".repeat(tw - 2)}${config_js_1.RST}`);
                for (let i = 0; i < show.length; i++) {
                    const ln = (d.offset || 0) + i + 1;
                    const code = show[i] ?? "";
                    const display = code.length > cw ? code.slice(0, cw) + `${config_js_1.FG_DIM}›${config_js_1.RST}` : code;
                    const lineNo = String(ln);
                    out.push(`  ${config_js_1.FG_LNUM}${" ".repeat(Math.max(0, nw - lineNo.length))}${lineNo}${config_js_1.RST} ${config_js_1.FG_RULE}│${config_js_1.RST} ${display}${config_js_1.RST}`);
                }
                if (total > maxShow) {
                    out.push(`  ${config_js_1.FG_DIM}  … ${total - maxShow} more lines (${total} total)${config_js_1.RST}`);
                }
                out.push("");
                const rendered = out.join("\n");
                text.setText((0, render_js_1.fillToolBackground)(rendered));
                ctx.state._rt = rendered;
                // Async syntax highlighting via Shiki
                (0, render_js_1.renderFileContent)(d.content, d.filePath, d.offset || 0, maxShow, tw).then(hl => {
                    const padded = hl.split("\n").map(l => `  ${l}`).join("\n");
                    const rendered = `\n  ${header}\n${padded}\n`;
                    text.setText((0, render_js_1.fillToolBackground)(rendered));
                    ctx.state._rt = rendered;
                }).catch(() => { });
                return text;
            }
            const fc = result.content?.[0];
            text.setText((0, render_js_1.fillToolBackground)(`  ${theme.fg("dim", fc && "text" in fc ? String(fc.text).slice(0, 120) : "done")}`));
            return text;
        },
    });
}
function getText(result) {
    return (result.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n") ?? "";
}
//# sourceMappingURL=read.js.map