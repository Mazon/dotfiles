export type ConstraintParseResult = {
    ok: true;
    globs: string[];
    tokens: string[];
} | {
    ok: false;
    error: string;
};
export type MultiGrepRipgrepFallbackParams = {
    cwd: string;
    patterns: string[];
    path?: string;
    constraints?: string;
    context?: number;
    limit: number;
    ignoreCase: boolean;
    signal?: AbortSignal;
};
export type MultiGrepRipgrepFallbackResult = {
    text: string;
    matchCount: number;
    limitReached: boolean;
};
export type MultiGrepRipgrepFallback = (params: MultiGrepRipgrepFallbackParams) => Promise<MultiGrepRipgrepFallbackResult>;
export declare function parseMultiGrepConstraints(constraints: string | undefined): ConstraintParseResult;
export declare function getMultiGrepRipgrepArgs(params: MultiGrepRipgrepFallbackParams): ConstraintParseResult & {
    args?: string[];
};
export declare function runMultiGrepRipgrepFallback(params: MultiGrepRipgrepFallbackParams): Promise<MultiGrepRipgrepFallbackResult>;
//# sourceMappingURL=multi-grep-fallback.d.ts.map