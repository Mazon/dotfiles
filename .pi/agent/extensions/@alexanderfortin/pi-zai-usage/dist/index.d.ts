/**
 * Z.ai Usage Checker - Pi Extension
 *
 * Uses createUsageExtension from the shared library to handle all
 * event registration, provider matching, caching, and footer lifecycle.
 */
import { createUsageExtension } from "@alexanderfortin/pi-usage-lib";
import { type ZaiUsageData } from "./api";
declare const extension: ReturnType<typeof createUsageExtension<ZaiUsageData>>;
export default extension;
//# sourceMappingURL=index.d.ts.map