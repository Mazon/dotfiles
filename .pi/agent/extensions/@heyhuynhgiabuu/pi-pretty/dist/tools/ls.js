"use strict";
/* pi-pretty: ls tool -- directory listing with styled output. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerLsTool = registerLsTool;
const config_js_1 = require("../config.js");
const helpers_js_1 = require("../helpers.js");
const metrics_js_1 = require("./metrics.js");
const render_js_1 = require("../render.js");
function registerLsTool(pi, cwd, _fffService, sdkTool, TextComp) {
    const home = process.env.HOME ?? "";
    const TC = TextComp ?? (() => {
        const { Text } = require("@earendil-works/pi-tui");
        return Text;
    })();
    pi.registerTool({
        name: "ls",
        label: "List",
        description: sdkTool.description ?? "List directory contents",
        parameters: sdkTool.parameters,
        renderShell: "self",
        execute: (0, metrics_js_1.wrapExecuteWithMetrics)(async (tid, params, sig, _upd, ctx) => {
            const result = await sdkTool.execute(tid, params, sig, undefined, ctx);
            const tc = getText(result);
            result.details = { _type: "lsResult", text: tc, path: String(params.path ?? ""), entryCount: tc ? tc.trim().split("\n").filter(Boolean).length : 0 };
            return result;
        }),
        renderCall(args, theme, ctx) {
            (0, config_js_1.resolveBaseBackground)(theme);
            const text = ctx.lastComponent ?? new TC("", 0, 0);
            const rawPath = args.path;
            const path = rawPath === null || rawPath === undefined || String(rawPath).length === 0 ? "" : (0, helpers_js_1.shortPath)(cwd, home, String(rawPath));
            const limit = args.limit;
            let out = theme.fg("toolTitle", theme.bold("ls"));
            if (path)
                out += ` ${theme.fg("accent", path)}`;
            if (limit !== undefined && limit !== null)
                out += theme.fg("toolOutput", ` (limit ${limit})`);
            text.setText((0, render_js_1.fillToolBackground)(`  \n  ${out}`, ctx.isError ? config_js_1.BG_ERROR : undefined));
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
            if (d?._type === "lsResult" && d.text) {
                const rendered = (0, render_js_1.renderTree)(d.text, d.path).split("\n").map(l => `  ${l}`).join("\n");
                text.setText((0, render_js_1.fillToolBackground)(`  \n  ${config_js_1.FG_DIM}${d.entryCount} entries${config_js_1.RST}${(0, render_js_1.renderToolMetrics)(result)}\n${rendered}\n  `));
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
//# sourceMappingURL=ls.js.map