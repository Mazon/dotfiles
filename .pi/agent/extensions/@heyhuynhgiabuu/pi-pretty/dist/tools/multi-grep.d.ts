import { type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { SdkToolDef, FffServiceWithCursor } from "../types.js";
import type { MultiGrepFallback } from "../types.js";
export declare function registerMultiGrepTool(pi: ExtensionAPI, cwd: string, fffService: FffServiceWithCursor | null | undefined, sdkGrepTool?: SdkToolDef, ripgrepFallback?: MultiGrepFallback, TextComp?: new (t?: string, x?: number, y?: number) => {
    setText(v: string): void;
}): void;
//# sourceMappingURL=multi-grep.d.ts.map