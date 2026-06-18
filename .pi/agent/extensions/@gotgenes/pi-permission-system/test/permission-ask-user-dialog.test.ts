import { afterEach, describe, expect, it, vi } from "vitest";
import {
  getAskUserPresenter,
  tryRequestPermissionDecisionViaAskUser,
} from "#src/permission-ask-user-dialog";
import type { PermissionDecisionUi } from "#src/permission-dialog";

/**
 * The ask_user presenter is feature-detected via a globalThis Symbol.for().
 * These tests publish/mock it and must clean up afterward so the symbol never
 * leaks into sibling suites (notably permission-dialog.test.ts, which relies on
 * the built-in ui.select fallback path and would break if a presenter were
 * accidentally still registered).
 */
const PRESENT_SYMBOL = Symbol.for("pi-ask-user:presentPrompt");

function clearPresenter(): void {
  delete (globalThis as Record<symbol, unknown>)[PRESENT_SYMBOL];
}

function publishPresenter(
  impl: (
    ctx: { hasUI?: boolean; ui: unknown },
    opts: {
      question: string;
      context?: string;
      options?: unknown[];
      allowFreeform?: boolean;
      boxTitle?: string;
    },
  ) => Promise<unknown>,
): void {
  (globalThis as Record<symbol, unknown>)[PRESENT_SYMBOL] = impl;
}

const noopUi: PermissionDecisionUi = {
  select: vi.fn(),
  input: vi.fn(),
};

afterEach(() => {
  clearPresenter();
  vi.restoreAllMocks();
});

describe("getAskUserPresenter", () => {
  it("returns undefined when no presenter is published", () => {
    clearPresenter();
    expect(getAskUserPresenter()).toBeUndefined();
  });

  it("returns the published function", () => {
    const fn = vi.fn();
    publishPresenter(fn as never);
    expect(getAskUserPresenter()).toBe(fn);
  });
});

describe("tryRequestPermissionDecisionViaAskUser", () => {
  it("returns null (fallback signal) when presenter is absent", async () => {
    clearPresenter();
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toBeNull();
  });

  it("returns approved when selection is Yes", async () => {
    publishPresenter(async () => ({ kind: "selection", selections: ["Yes"] }));
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toEqual({ approved: true, state: "approved" });
  });

  it("returns approved_for_session for the default session option", async () => {
    publishPresenter(async () => ({
      kind: "selection",
      selections: ["Yes, for this session"],
    }));
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toEqual({ approved: true, state: "approved_for_session" });
  });

  it("honors a custom sessionLabel option", async () => {
    publishPresenter(async () => ({
      kind: "selection",
      selections: ["git * (this session)"],
    }));
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
      { sessionLabel: "git * (this session)" },
    );
    expect(result).toEqual({ approved: true, state: "approved_for_session" });
  });

  it("returns denied for No", async () => {
    publishPresenter(async () => ({ kind: "selection", selections: ["No"] }));
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toEqual({ approved: false, state: "denied" });
  });

  it("treats cancel (null response) as a denial", async () => {
    publishPresenter(async () => null);
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toEqual({ approved: false, state: "denied" });
  });

  it("runs the freeform reason step for 'No, provide reason'", async () => {
    const presenter = vi
      .fn()
      .mockResolvedValueOnce({ kind: "selection", selections: ["No, provide reason"] })
      .mockResolvedValueOnce({ kind: "freeform", text: "dangerous operation" });
    publishPresenter(presenter as never);

    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );

    expect(result).toEqual({
      approved: false,
      state: "denied_with_reason",
      denialReason: "dangerous operation",
    });
    expect(presenter).toHaveBeenCalledTimes(2);
  });

  it("returns null (fallback) when the presenter throws", async () => {
    publishPresenter(async () => {
      throw new Error("ask-user UI exploded");
    });
    const result = await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Title",
      "Message",
    );
    expect(result).toBeNull();
  });

  it("forwards title/message as question/context, boxTitle as 'permission', with 4 options", async () => {
    let captured: Record<string, unknown> | undefined;
    publishPresenter(async (_ctx, opts) => {
      captured = opts as Record<string, unknown>;
      return { kind: "selection", selections: ["Yes"] };
    });

    await tryRequestPermissionDecisionViaAskUser(
      noopUi,
      "Permission Required",
      "details go here",
    );

    expect(captured).toMatchObject({
      question: "Permission Required",
      context: "details go here",
      boxTitle: "permission",
      allowFreeform: false,
    });
    expect(Array.isArray(captured?.options)).toBe(true);
    expect((captured?.options as unknown[]).length).toBe(4);
  });
});
