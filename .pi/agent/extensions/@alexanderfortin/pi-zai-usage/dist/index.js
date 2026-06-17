/**
 * Z.ai Usage Checker - Pi Extension
 *
 * Uses createUsageExtension from the shared library to handle all
 * event registration, provider matching, caching, and footer lifecycle.
 */
import { createUsageExtension } from "@alexanderfortin/pi-usage-lib";
import { getZaiUsage } from "./api";
/** Render Z.ai usage data into a themed footer string */
function renderZaiStatus(data, theme) {
    const displayPercentage = Math.round(data.percentage * 10) / 10;
    let status = theme.fg("muted", "Z.ai:") + theme.fg("accent", `${displayPercentage}%`);
    if (data.resetTime && data.timeRemaining) {
        status += ` ${theme.fg("dim", `(${data.timeRemaining})`)}`;
    }
    return status;
}
const extension = createUsageExtension({
    providerPrefix: "zai",
    statusKey: "zai-usage",
    label: "Z.ai",
    fetchUsage: getZaiUsage,
    renderStatus: renderZaiStatus,
});
export default extension;
//# sourceMappingURL=index.js.map