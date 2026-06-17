/**
 * Pure cadence logic for the system-reminder injection.
 *
 * Decisions are made here as plain functions so they're easy to unit-test
 * without spinning up the whole extension. The default export of the
 * extension wires these into the `tool_result` and `context` hooks.
 */
/** Internal cadence state. Plain object so it round-trips through tests. */
export interface CadenceState {
    currentTurn: number;
    lastTaskToolUseTurn: number;
    reminderInjectedThisCycle: boolean;
    reminderDue: boolean;
}
export interface CadenceConfig {
    /** Turns without a task-tool call before a reminder is considered due. */
    reminderInterval: number;
    /** Set of tool names that count as "task tool usage" and reset cadence. */
    taskToolNames: ReadonlySet<string>;
}
export declare function createCadenceState(): CadenceState;
export declare function resetCadenceState(state: CadenceState): void;
/** Increment the turn counter at `turn_start`. */
export declare function onTurnStart(state: CadenceState): void;
export interface ToolResultDecision {
    /** True when caller should mark `reminderDue` for the next `context` event. */
    markDue: boolean;
}
/**
 * Decide what cadence change a tool_result implies. Mutates `state` in place
 * (resets the timer when a task tool was used) and returns whether the
 * reminder should be queued for the next LLM call.
 */
export declare function evaluateToolResult(state: CadenceState, toolName: string, hasTasks: boolean, config: CadenceConfig): ToolResultDecision;
/**
 * Drain the pending reminder when `context` fires. Returns true if the
 * caller should inject the reminder into the upcoming LLM call's messages.
 */
export declare function drainReminderForContext(state: CadenceState): boolean;
