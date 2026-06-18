"use strict";
/* pi-pretty: bash tool -- command execution with styled output. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerBashTool = registerBashTool;
const config_js_1 = require("../config.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
const helpers_js_1 = require("../helpers.js");
function registerBashTool(pi, _cwd, _fffService, sdkTool, TextComp) {
    const TC = TextComp ?? (() => {
        const { Text } = require("@earendil-works/pi-tui");
        return Text;
    })();
    pi.registerTool({
        name: "bash",
        label: "Bash",
        description: sdkTool.description ?? "Execute shell commands",
        parameters: sdkTool.parameters,
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            try {
                return await sdkTool.execute(tid, params, sig, undefined, ctx);
            }
            catch (error) {
                const msg = error instanceof Error ? error.message : String(error);
                return { content: [{ type: "text", text: msg }], isError: true, details: { _type: "bashResult", text: msg, exitCode: 1, command: String(params.command ?? "") } };
            }
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            const t = typeof args.timeout === "number" ? ` ${theme.fg("muted", `(timeout ${args.timeout}s)`)}` : "";
            const tw = (0, config_js_1.termWidth)() || 80;
            const rawCmd = String(args.command ?? "");
            const cmd = rawCmd.length === 0 ? theme.fg("toolOutput", "...") : (rawCmd.length > tw - 20 ? rawCmd.slice(0, Math.max(1, tw - 20)) + "…" : rawCmd);
            const toolWidth = ctx.expanded ? undefined : tw;
            text.setText((0, render_js_1.fillToolBackground)(`\n  ${theme.fg("toolTitle", theme.bold(`$ ${cmd}`))}${t}`, ctx.isError ? config_js_1.BG_ERROR : undefined, toolWidth));
            return text;
        },
        renderResult(result, _opt, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            const details = result.details;
            const tc = getText(result);
            const d = details?._type === "bashResult" ? details
                : tc || ctx.isError
                    ? { _type: "bashResult", text: tc || "Error", exitCode: (0, helpers_js_1.inferBashExitCode)(tc, ctx.isError ? 1 : 0), command: "" }
                    : undefined;
            if (d?._type === "bashResult") {
                const isErr = ctx.isError || (d.exitCode !== null && d.exitCode !== 0);
                const bg = isErr ? config_js_1.BG_ERROR : undefined;
                const cleaned = (0, helpers_js_1.stripBashExitStatusLine)(d.text);
                const output = isErr ? (0, helpers_js_1.compactErrorLines)(cleaned).join("\n") : cleaned;
                const { summary } = (0, render_js_1.renderBashOutput)(output, d.exitCode);
                const lineCount = output.split("\n").length;
                const info = lineCount > 1 ? `  ${config_js_1.FG_DIM}(${lineCount} lines)${config_js_1.RST} ${(0, render_js_1.renderToolMetrics)(result)}` : ` ${(0, render_js_1.renderToolMetrics)(result)}`;
                const header = `  ${summary}${info}`;
                const rw = (0, config_js_1.termWidth)();
                const renderFn = (w) => {
                    if (!output.trim())
                        return (0, render_js_1.fillToolBackground)(header, bg, w);
                    const max = ctx.expanded ? lineCount : config_js_1.MAX_PREVIEW_LINES;
                    const show = output.split("\n").slice(0, max);
                    const out = [header, rule(w), ...show.map((l) => `  ${l}`)];
                    if (lineCount > max)
                        out.push(`${config_js_1.FG_DIM}  \u2026 ${lineCount - max} more lines${config_js_1.RST}`);
                    return (0, render_js_1.fillToolBackground)(out.join("\n"), bg, w);
                };
                text.setText(renderFn(rw));
                const baseRender = typeof text.render === "function"
                    ? text.render.bind(text)
                    : null;
                if (baseRender) {
                    let key;
                    text.render = (w) => {
                        const width = Math.max(1, Math.floor(w || (0, config_js_1.termWidth)()));
                        const k = `bash:${ctx.expanded ? "1" : "0"}:${width}:${d.exitCode ?? "killed"}:${output.length}:${(0, render_js_1.renderToolMetrics)(result)}`;
                        if (key !== k) {
                            text.setText(renderFn(width));
                            key = k;
                        }
                        return baseRender(width);
                    };
                }
                return text;
            }
            if (ctx.isError) {
                text.setText((0, render_js_1.renderToolError)(tc || "Error", theme));
                return text;
            }
            const fc = result.content?.[0];
            text.setText((0, render_js_1.fillToolBackground)(`  ${theme.fg("dim", fc && "text" in fc ? String(fc.text).slice(0, 120) : "done")}`));
            return text;
        },
    });
}
function rule(w) { return `${config_js_1.FG_RULE}${"\u2500".repeat(w)}${config_js_1.RST}`; }
function getText(result) {
    return (result.content ?? []).filter((c) => c.type === "text").map((c) => c.text).join("\n") ?? "";
}
//# sourceMappingURL=bash.js.map