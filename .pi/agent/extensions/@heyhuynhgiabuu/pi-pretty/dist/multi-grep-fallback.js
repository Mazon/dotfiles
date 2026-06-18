"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseMultiGrepConstraints = parseMultiGrepConstraints;
exports.getMultiGrepRipgrepArgs = getMultiGrepRipgrepArgs;
exports.runMultiGrepRipgrepFallback = runMultiGrepRipgrepFallback;
const node_child_process_1 = require("node:child_process");
const GLOB_META_RE = /[*?[{]/;
function trimSlashes(value) {
    return value.replace(/^\/+/, "").replace(/\/+$/, "");
}
function normalizeConstraintPath(value) {
    let normalized = value.replace(/\\/g, "/").trim();
    while (normalized.startsWith("./"))
        normalized = normalized.slice(2);
    return normalized;
}
function tokenizeConstraints(constraints) {
    const tokens = [];
    let current = "";
    let quote = null;
    for (let i = 0; i < constraints.length; i++) {
        const char = constraints[i];
        if (quote) {
            if (char === quote)
                quote = null;
            else
                current += char;
            continue;
        }
        if (char === '"' || char === "'") {
            quote = char;
            continue;
        }
        if (/\s/.test(char)) {
            if (current) {
                tokens.push(current);
                current = "";
            }
            continue;
        }
        current += char;
    }
    if (quote)
        return { ok: false, error: "unterminated quoted constraint" };
    if (current)
        tokens.push(current);
    return { ok: true, globs: [], tokens };
}
function tokenToRipgrepGlob(token) {
    let negated = false;
    let body = token;
    if (body.startsWith("!")) {
        negated = true;
        body = body.slice(1);
    }
    body = normalizeConstraintPath(body);
    if (!body)
        return { ok: false, error: `empty constraint token: ${token}` };
    if (body.includes("\0"))
        return { ok: false, error: `invalid NUL byte in constraint token: ${token}` };
    let glob;
    if (body.endsWith("/")) {
        const dir = trimSlashes(body);
        if (!dir)
            return { ok: false, error: `empty directory constraint: ${token}` };
        glob = `**/${dir}/**`;
    }
    else if (GLOB_META_RE.test(body) || body.includes("/")) {
        glob = body.replace(/^\/+/, "");
    }
    else if (body.includes(".")) {
        glob = `**/${body}`;
    }
    else {
        glob = `**/${body}/**`;
    }
    return { ok: true, glob: negated ? `!${glob}` : glob };
}
function parseMultiGrepConstraints(constraints) {
    const trimmed = constraints?.trim();
    if (!trimmed)
        return { ok: true, globs: [], tokens: [] };
    const tokenized = tokenizeConstraints(trimmed);
    if (!tokenized.ok)
        return tokenized;
    const globs = [];
    for (const token of tokenized.tokens) {
        const parsed = tokenToRipgrepGlob(token);
        if (!parsed.ok)
            return parsed;
        globs.push(parsed.glob);
    }
    return { ok: true, globs, tokens: tokenized.tokens };
}
function isRipgrepMatchLine(line) {
    return /^.+?:\d+:/.test(line);
}
function buildRipgrepArgs(params, globs) {
    const args = ["--line-number", "--with-filename", "--color=never", "--hidden", "--fixed-strings"];
    if (params.ignoreCase)
        args.push("--ignore-case");
    if (params.context && params.context > 0)
        args.push("--context", String(params.context));
    for (const glob of globs)
        args.push("--glob", glob);
    for (const pattern of params.patterns)
        args.push("-e", pattern);
    const searchPath = params.path?.trim();
    if (searchPath)
        args.push("--", searchPath);
    return args;
}
function getMultiGrepRipgrepArgs(params) {
    const parsed = parseMultiGrepConstraints(params.constraints);
    if (!parsed.ok)
        return parsed;
    return { ...parsed, args: buildRipgrepArgs(params, parsed.globs) };
}
async function runMultiGrepRipgrepFallback(params) {
    const parsed = parseMultiGrepConstraints(params.constraints);
    if (!parsed.ok)
        throw new Error(`unsupported constraints: ${parsed.error}`);
    const args = buildRipgrepArgs(params, parsed.globs);
    return new Promise((resolve, reject) => {
        if (params.signal?.aborted) {
            reject(new Error("Operation aborted"));
            return;
        }
        const child = (0, node_child_process_1.spawn)("rg", args, { cwd: params.cwd, stdio: ["ignore", "pipe", "pipe"] });
        const outputLines = [];
        let stderr = "";
        let buffer = "";
        let matchCount = 0;
        let limitReached = false;
        let killedForLimit = false;
        let settled = false;
        const settle = (fn) => {
            if (settled)
                return;
            settled = true;
            fn();
        };
        const stopChild = (dueToLimit = false) => {
            if (!child.killed) {
                killedForLimit = dueToLimit;
                child.kill();
            }
        };
        const onAbort = () => stopChild(false);
        params.signal?.addEventListener("abort", onAbort, { once: true });
        const cleanup = () => {
            params.signal?.removeEventListener("abort", onAbort);
        };
        const handleLine = (line) => {
            if (limitReached)
                return;
            outputLines.push(line);
            if (isRipgrepMatchLine(line)) {
                matchCount++;
                if (matchCount >= params.limit) {
                    limitReached = true;
                    stopChild(true);
                }
            }
        };
        child.stdout?.on("data", (chunk) => {
            buffer += chunk.toString("utf8");
            let newlineIndex = buffer.indexOf("\n");
            while (newlineIndex >= 0) {
                const line = buffer.slice(0, newlineIndex).replace(/\r$/, "");
                buffer = buffer.slice(newlineIndex + 1);
                handleLine(line);
                newlineIndex = buffer.indexOf("\n");
            }
        });
        child.stderr?.on("data", (chunk) => {
            stderr += chunk.toString("utf8");
        });
        child.on("error", (error) => {
            cleanup();
            const message = error.code === "ENOENT" ? "ripgrep (rg) is not available" : `Failed to run ripgrep: ${error.message}`;
            settle(() => reject(new Error(message)));
        });
        child.on("close", (code) => {
            cleanup();
            if (params.signal?.aborted) {
                settle(() => reject(new Error("Operation aborted")));
                return;
            }
            if (buffer && !limitReached)
                handleLine(buffer.replace(/\r$/, ""));
            if (!killedForLimit && code !== 0 && code !== 1) {
                const message = stderr.trim() || `ripgrep exited with code ${code}`;
                settle(() => reject(new Error(message)));
                return;
            }
            settle(() => resolve({
                text: outputLines.length ? outputLines.join("\n") : "No matches found",
                matchCount,
                limitReached,
            }));
        });
    });
}
//# sourceMappingURL=multi-grep-fallback.js.map