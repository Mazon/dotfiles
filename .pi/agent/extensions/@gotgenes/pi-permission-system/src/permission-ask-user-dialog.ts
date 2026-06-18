/**
 * Optional adapter that renders the permission decision through the
 * `pi-ask-user` extension's rich prompt UI (the same component used by the
 * `ask_user` tool), so permission prompts match the look the user configured
 * for ask_user.
 *
 * Coupling strategy: `pi-ask-user` publishes its presenter on
 * `globalThis[Symbol.for("pi-ask-user:presentPrompt")]` at extension init
 * (same Symbol.for()-backed service-accessor pattern this package uses in
 * `src/service.ts` and `src/subagent-registry.ts`). We feature-detect it here,
 * so the adapter degrades gracefully — if `pi-ask-user` is absent, outdated, or
 * throws, callers fall back to the built-in `ui.select` dialog. That fallback
 * is mandatory because this code sits on the security-critical permission path.
 *
 * `displayMode` is deliberately omitted from the presenter call: the prompt then
 * follows `PI_ASK_USER_DISPLAY_MODE`, so permission prompts always render in the
 * same mode (overlay or inline) as ask_user tool calls.
 */
import {
  APPROVE_OPTION,
  APPROVE_FOR_SESSION_OPTION,
  createDeniedPermissionDecision,
  DENY_OPTION,
  DENY_WITH_REASON_OPTION,
  normalizePermissionDenialReason,
  type PermissionDecisionUi,
  type PermissionPromptDecision,
  type RequestPermissionOptions,
} from "./permission-dialog";

/** globalThis symbol published by pi-ask-user's extension init. */
const ASK_USER_PRESENT_SYMBOL = Symbol.for("pi-ask-user:presentPrompt");

/** ask_user option input (title-only or title+description), kept structural. */
type AskOptionInput = string | { title: string; description?: string };

/** ask_user response shape, kept structural to avoid a cross-package import. */
type AskResponse =
  | { kind: "selection"; selections: string[]; comment?: string }
  | { kind: "freeform"; text: string };

/** Presenter contract published by pi-ask-user. */
interface AskUserPresenter {
  (
    ctx: { hasUI?: boolean; ui: unknown },
    opts: {
      question: string;
      context?: string;
      options?: AskOptionInput[];
      allowMultiple?: boolean;
      allowFreeform?: boolean;
      allowComment?: boolean;
      displayMode?: "overlay" | "inline";
      boxTitle?: string;
    },
  ): Promise<AskResponse | null>;
}

/**
 * Feature-detect the ask_user presenter published on globalThis.
 *
 * Returns `undefined` when pi-ask-user is not installed (or has not published
 * yet), which is the signal for callers to use the built-in dialog fallback.
 */
export function getAskUserPresenter(): AskUserPresenter | undefined {
  const fn = (globalThis as Record<symbol, unknown>)[ASK_USER_PRESENT_SYMBOL];
  return typeof fn === "function" ? (fn as AskUserPresenter) : undefined;
}

/**
 * Render the permission decision via the ask_user UI when available.
 *
 * Returns `null` to instruct the caller to fall back to `ui.select`. This
 * happens when the presenter is unavailable OR when it throws — a UI-layer
 * failure must never block the permission decision path.
 *
 * Cancel (Esc) is treated as a denial so the guarded tool call never proceeds
 * while the user is absent or undecided.
 */
export async function tryRequestPermissionDecisionViaAskUser(
  ui: PermissionDecisionUi,
  title: string,
  message: string,
  options?: RequestPermissionOptions,
): Promise<PermissionPromptDecision | null> {
  const present = getAskUserPresenter();
  if (!present) return null;

  const sessionOption = options?.sessionLabel ?? APPROVE_FOR_SESSION_OPTION;
  const choices: AskOptionInput[] = [
    { title: APPROVE_OPTION, description: "Allow this one request." },
    { title: sessionOption, description: "Allow matching requests for the rest of this session." },
    { title: DENY_OPTION, description: "Block this request." },
    { title: DENY_WITH_REASON_OPTION, description: "Block and tell the agent why." },
  ];

  let response: AskResponse | null;
  try {
    response = await present({ hasUI: true, ui }, {
      question: title,
      context: message,
      options: choices,
      allowMultiple: false,
      allowFreeform: false,
      allowComment: false,
      boxTitle: "permission",
    });
  } catch {
    return null;
  }

  if (response === null || response === undefined) {
    return createDeniedPermissionDecision();
  }
  if (response.kind !== "selection") {
    return createDeniedPermissionDecision();
  }

  const selected = response.selections[0];
  if (selected === APPROVE_OPTION) {
    return { approved: true, state: "approved" };
  }
  if (selected === sessionOption) {
    return { approved: true, state: "approved_for_session" };
  }
  if (selected === DENY_WITH_REASON_OPTION) {
    const reason = await collectDenialReason(present, ui, title, message);
    return createDeniedPermissionDenialDecision(reason);
  }
  return createDeniedPermissionDecision();
}

/**
 * Second step: freeform input for the denial reason. Uses the ask_user presenter
 * with an empty option list so it routes to ask_user's text-input UI, keeping
 * the look consistent. Cancel yields no reason (plain denial).
 */
async function collectDenialReason(
  present: AskUserPresenter,
  ui: PermissionDecisionUi,
  title: string,
  message: string,
): Promise<string | undefined> {
  let response: AskResponse | null;
  try {
    response = await present({ hasUI: true, ui }, {
      question: "Share why this request was denied (optional)",
      context: `${title}\n${message}`,
      options: [],
      allowFreeform: true,
      boxTitle: "permission",
    });
  } catch {
    return undefined;
  }
  if (response?.kind === "freeform") {
    return normalizePermissionDenialReason(response.text);
  }
  return undefined;
}

// Thin local wrapper to keep the call sites above readable; mirrors the
// permission-dialog helper of the same shape.
function createDeniedPermissionDenialDecision(
  reason: string | undefined,
): PermissionPromptDecision {
  return createDeniedPermissionDecision(reason);
}
