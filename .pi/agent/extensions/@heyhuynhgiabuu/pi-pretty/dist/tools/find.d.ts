import { type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { SdkToolDef, FffServiceLike } from "../types.js";
export declare function registerFindTool(pi: ExtensionAPI, cwd: string, fffService: FffServiceLike | null | undefined, sdkTool: SdkToolDef, TextComp?: new (t?: string, x?: number, y?: number) => {
    setText(v: string): void;
}): void;
//# sourceMappingURL=find.d.ts.map