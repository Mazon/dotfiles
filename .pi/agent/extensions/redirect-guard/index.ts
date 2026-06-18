/**
 * redirect-guard — companion extension for `@gotgenes/pi-permission-system`.
 *
 * Lets "gray-area" bash commands (`echo`, `printf`, `base64`, `awk`, `cat`)
 * run silently (`allow`) while still catching the redirect/write danger they
 * pose on the specific targets that the permission system's cross-cutting
 * `path` surface misses.
 *
 * Design:
 *  - Registers a `tool_call` handler for `bash`.
 *  - Runs `detectSuspiciousWrite(command, ctx.cwd)` (pure, sync).
 *  - Returns `undefined` (no opinion) unless a gap-target is found, so this
 *    composes safely with pi-permission-system regardless of load order.
 *  - On a hit: with a UI, asks for confirmation; without a UI (headless),
 *    blocks. This mirrors the official `permission-gate` example.
 *
 * See detector.ts for exactly which gaps are covered and why.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { detectSuspiciousWrite } from "./detector.ts";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command = (event.input as { command?: string }).command;
    if (!command) return undefined;

    const hit = detectSuspiciousWrite(command, ctx.cwd);
    if (!hit) return undefined;

    if (!ctx.hasUI) {
      return { block: true, reason: hit.reason };
    }

    const allow = await ctx.ui.confirm(
      "redirect-guard: suspicious write/redirect",
      `${hit.summary}\n\nCommand:\n  ${command}\n\nAllow this write?`,
    );
    return allow ? undefined : { block: true, reason: hit.reason };
  });
}
