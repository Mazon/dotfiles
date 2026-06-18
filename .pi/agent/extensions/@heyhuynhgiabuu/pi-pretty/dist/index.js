"use strict";
/**
 * pi-pretty — Pretty terminal output for pi built-in tools.
 *
 * Enhances read, bash, ls, find, grep, multi_grep with:
 *   • Syntax-highlighted file content (Shiki)
 *   • Colored bash exit status + output
 *   • Tree-view directory listings with file-type icons
 *   • FFF-accelerated find/grep with SDK fallback
 *   • Custom ANSI rendering for all tools
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.__imageInternals = void 0;
exports.default = piPrettyExtension;
// Re-export for tests
var image_js_1 = require("./image.js");
Object.defineProperty(exports, "__imageInternals", { enumerable: true, get: function () { return image_js_1.__imageInternals; } });
const fff_js_1 = require("./fff.js");
const read_js_1 = require("./tools/read.js");
const bash_js_1 = require("./tools/bash.js");
const ls_js_1 = require("./tools/ls.js");
const find_js_1 = require("./tools/find.js");
const grep_js_1 = require("./tools/grep.js");
const multi_grep_js_1 = require("./tools/multi-grep.js");
const multi_grep_fallback_js_1 = require("./multi-grep-fallback.js");
const config_js_1 = require("./config.js");
const autocomplete_js_1 = require("./autocomplete.js");
// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------
function envDisabledTools() {
    return new Set((process.env.PRETTY_DISABLE_TOOLS ?? "")
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .filter(Boolean));
}
function piPrettyExtension(pi, deps) {
    const disabledTools = envDisabledTools();
    const isToolEnabled = (name) => !disabledTools.has(name.toLowerCase());
    const cwd = process.cwd();
    // ------------------------------------------------------------------
    // Resolve SDK tools
    // ------------------------------------------------------------------
    let sdk;
    let createReadTool;
    let createBashTool;
    let createLsTool;
    let createFindTool;
    let createGrepTool;
    let getAgentDir;
    if (deps) {
        sdk = deps.sdk ?? {};
        createReadTool = sdk.createReadTool ?? sdk.createReadToolDefinition;
        createBashTool = sdk.createBashTool ?? sdk.createBashToolDefinition;
        createLsTool = sdk.createLsTool ?? sdk.createLsToolDefinition;
        createFindTool = sdk.createFindTool ?? sdk.createFindToolDefinition;
        createGrepTool = sdk.createGrepTool ?? sdk.createGrepToolDefinition;
        getAgentDir = sdk.getAgentDir;
    }
    else {
        try {
            sdk = require("@earendil-works/pi-coding-agent");
            createReadTool = sdk.createReadToolDefinition ?? sdk.createReadTool;
            createBashTool = sdk.createBashToolDefinition ?? sdk.createBashTool;
            createLsTool = sdk.createLsToolDefinition ?? sdk.createLsTool;
            createFindTool = sdk.createFindToolDefinition ?? sdk.createFindTool;
            createGrepTool = sdk.createGrepToolDefinition ?? sdk.createGrepTool;
        }
        catch {
            return; // pi SDK not available
        }
    }
    if (!createReadTool)
        return;
    // ------------------------------------------------------------------
    // FFF service init
    // ------------------------------------------------------------------
    const agentDir = getAgentDir ? getAgentDir() : (0, config_js_1.getDefaultAgentDir)();
    let fffService = new fff_js_1.FffService(undefined, agentDir);
    if (deps?.fffModule) {
        fffService = new fff_js_1.FffService(deps.fffModule, agentDir);
    }
    // Ripgrep fallback for multi_grep
    const multiGrepFallback = deps?.multiGrepRipgrepFallback ?? multi_grep_fallback_js_1.runMultiGrepRipgrepFallback;
    // Text component for custom rendering (DI-friendly)
    const TextComp = deps?.TextComponent;
    // ------------------------------------------------------------------
    // Tool registration
    // ------------------------------------------------------------------
    if (isToolEnabled("read") && createReadTool) {
        (0, read_js_1.registerReadTool)(pi, cwd, null, createReadTool(cwd), TextComp);
    }
    if (isToolEnabled("bash") && createBashTool) {
        (0, bash_js_1.registerBashTool)(pi, cwd, null, createBashTool(cwd), TextComp);
    }
    if (isToolEnabled("ls") && createLsTool) {
        (0, ls_js_1.registerLsTool)(pi, cwd, null, createLsTool(cwd), TextComp);
    }
    if (isToolEnabled("find") && createFindTool) {
        (0, find_js_1.registerFindTool)(pi, cwd, fffService, createFindTool(cwd), TextComp);
    }
    if (isToolEnabled("grep") && createGrepTool) {
        (0, grep_js_1.registerGrepTool)(pi, cwd, fffService, createGrepTool(cwd), TextComp);
    }
    if (isToolEnabled("multi_grep") && (fffService || createGrepTool)) {
        (0, multi_grep_js_1.registerMultiGrepTool)(pi, cwd, fffService, createGrepTool ? createGrepTool(cwd) : undefined, multiGrepFallback, TextComp);
    }
    // ------------------------------------------------------------------
    // FFF commands
    // ------------------------------------------------------------------
    if (fffService) {
        pi.registerCommand("fff-health", {
            description: "Show FFF file finder health and indexer status",
            handler: async (_args, ctx) => {
                const fff = fffService;
                if (!fff.isAvailable) {
                    ctx.ui.notify("FFF not initialized", "warning");
                    return;
                }
                const finder = fff.getFinder();
                if (!finder) {
                    ctx.ui.notify("FFF not initialized", "warning");
                    return;
                }
                const health = finder.healthCheck();
                if (!health.ok) {
                    ctx.ui.notify(`Health check failed: ${health.error}`, "error");
                    return;
                }
                const h = health.value;
                const lines = [
                    `FFF v${h.version}`,
                    `Git: ${h.git.repositoryFound ? `yes (${h.git.workdir ?? "unknown"})` : "no"}`,
                    `Picker: ${h.filePicker.initialized ? `${h.filePicker.indexedFiles ?? 0} files` : "not initialized"}`,
                    `Frecency: ${h.frecency.initialized ? "active" : "disabled"}`,
                    `Query tracker: ${h.queryTracker.initialized ? "active" : "disabled"}`,
                    `Partial index: ${fff.partialIndex ? "yes (scan timed out)" : "no"}`,
                ];
                const progress = finder.getScanProgress();
                if (progress.ok) {
                    lines.push(`Scanning: ${progress.value.isScanning ? "yes" : "no"} (${progress.value.scannedFilesCount} files)`);
                }
                ctx.ui.notify(lines.join("\n"), "info");
            },
        });
        pi.registerCommand("fff-rescan", {
            description: "Trigger FFF to rescan files",
            handler: async (_args, ctx) => {
                const fff = fffService;
                if (!fff.isAvailable) {
                    ctx.ui.notify("FFF not initialized", "warning");
                    return;
                }
                const finder = fff.getFinder();
                if (!finder) {
                    ctx.ui.notify("FFF not initialized", "warning");
                    return;
                }
                const result = finder.scanFiles();
                if (!result.ok) {
                    ctx.ui.notify(`Rescan failed: ${result.error}`, "error");
                    return;
                }
                fff.partialIndex = false;
                ctx.ui.notify("FFF rescan triggered", "info");
            },
        });
    }
    // ------------------------------------------------------------------
    // Session lifecycle
    // ------------------------------------------------------------------
    pi.on("session_start", async (_event, ctx) => {
        if (!fffService)
            return;
        // Try dynamic import if sync require failed
        if (!fffService.isModuleLoaded()) {
            const loaded = await fffService.tryLoadModule();
            if (!loaded)
                return;
        }
        try {
            await fffService.ensureFinder(ctx.cwd);
            if (fffService.partialIndex) {
                ctx.ui?.notify?.("FFF: scan timed out — using partial index. Run /fff-rescan when ready.", "warning");
            }
            else {
                const ui = ctx.ui;
                ui?.setStatus?.("fff", "FFF indexed");
                setTimeout(() => ui?.setStatus?.("fff", undefined), 3000);
            }
        }
        catch (error) {
            ctx.ui?.notify?.(`FFF init failed: ${error instanceof Error ? error.message : String(error)}`, "error");
        }
        // Register FFF-backed @-mention autocomplete
        ctx.ui?.addAutocompleteProvider?.((current) => (0, autocomplete_js_1.createFffAutocompleteProvider)(current, () => fffService?.getFinder() ?? null));
    });
    pi.on("session_shutdown", async () => {
        fffService?.destroy();
    });
    // Fallback padding for SDK-rendered tool bodies. The SDK reads
    // result.content[0].text and slices collapsed output to roughly the first
    // 10 lines, so insert bottom padding inside that visible slice.
    const PADDED_TOOLS = new Set(["read", "grep", "bash"]);
    const RESULT_LEFT_PAD = "    ";
    const BOTTOM_PADDING_BY_TOOL = { read: 2, grep: 2, bash: 0 };
    pi.on("tool_result", (event, _ctx) => {
        if (!PADDED_TOOLS.has(event.toolName))
            return undefined;
        const first = event.content[0];
        if (!first || first.type !== "text")
            return undefined;
        const lines = first.text.split("\n").map((line) => `${RESULT_LEFT_PAD}${line}`);
        if (lines.length === 0)
            return undefined;
        const padCount = BOTTOM_PADDING_BY_TOOL[event.toolName] ?? 0;
        lines.push(...Array.from({ length: padCount }, () => RESULT_LEFT_PAD));
        return {
            content: [{ type: "text", text: lines.join("\n") }, ...event.content.slice(1)],
        };
    });
}
//# sourceMappingURL=index.js.map