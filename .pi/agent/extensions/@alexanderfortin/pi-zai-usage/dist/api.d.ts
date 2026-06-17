/**
 * Z.ai Usage Checker - Pi Extension
 * Provider-specific API interaction using shared library primitives
 */
import { UsageError } from "@alexanderfortin/pi-usage-lib";
import type { ModelRegistry } from "@earendil-works/pi-coding-agent";
export interface ZaiUsageResponse {
    data: {
        limits: Array<{
            type: string;
            percentage: number;
            nextResetTime?: number;
        }>;
    };
}
export interface ZaiApiError {
    code: number;
    msg: string;
    success: boolean;
}
export interface ZaiUsageData {
    percentage: number;
    resetTime?: string;
    timeRemaining?: string;
}
/**
 * Fetch Z.ai usage from the API
 *
 * Uses shared library primitives (buildAuthHeaders, safeFetch, safeParseJson)
 * for sandbox-aware auth, error handling, and JSON parsing.
 */
export declare function getZaiUsage(modelRegistry: Pick<ModelRegistry, "getApiKeyForProvider">): Promise<ZaiUsageData>;
export { UsageError };
//# sourceMappingURL=api.d.ts.map