/**
 * redirect-guard — pure, synchronous redirect/write heuristic.
 *
 * Scope (IMPORTANT): this detector ONLY flags the gaps that
 * `@gotgenes/pi-permission-system`'s cross-cutting `path` surface does NOT
 * catch. Everything else returns `null` so the permission system decides, and
 * the two layers compose safely regardless of extension load order.
 *
 * Verified gaps in the path surface (see plan + source audit):
 *
 *  1. `dd of=<path>` (and any writer whose argument is a `KEY=/path` token).
 *     `of=/dev/sda` is parsed by tree-sitter-bash as a `variable_assignment`
 *     and explicitly skipped by `collectGenericCommandTokens`, and the token
 *     is rejected as an env-assignment by `rejectNonPathToken` — so it never
 *     reaches the `path` gate. We catch it here.
 *
 *  2. Bare-relative redirect targets with no leading `.` and no `/`
 *     (e.g. `echo x > passwd` while cwd is `/etc`, or `> authorized_keys`
 *     while cwd is `~/.ssh`). `classifyTokenAsRuleCandidate` requires a `.`,
 *     a `/`, or `..`, so such tokens are never path-rule candidates. We resolve
 *     them against cwd and check sensitivity.
 *
 * Redirect targets that DO contain `.`/`/`/`~` (e.g. `echo x > ~/.bashrc`,
 * `> /dev/sda`, `> .env`) are handled by the `path` surface and are
 * deliberately NOT re-checked here, to avoid double-prompting.
 *
 * This is a pragmatic regex/string heuristic, NOT a shell parser. It favors a
 * low false-positive rate (only fires when a resolved target is genuinely
 * sensitive) over perfect recall — the `path` surface is the primary defense.
 */

import { homedir } from "node:os";
import { isAbsolute, resolve as resolvePath, sep } from "node:path";

export interface SuspiciousWrite {
  /** Short human-readable summary, shown in the confirm dialog body. */
  readonly summary: string;
  /** Reason string used when blocking. */
  readonly reason: string;
  /** Resolved sensitive target paths that triggered the hit. */
  readonly targets: readonly string[];
}

const HOME = homedir();

/** Absolute directory prefixes whose contents are sensitive to writes. */
const SENSITIVE_ABS_PREFIXES: readonly string[] = [
  "/etc/",
  "/boot/",
  "/dev/",
  "/proc/",
  "/sys/",
  "/usr/",
  "/sbin/",
  "/bin/",
  "/lib/",
  "/lib64/",
];

/**
 * Subdirectories under `$HOME` that hold secrets/config and are sensitive to
 * writes. Matched against the path segment(s) following `$HOME/`.
 */
const SENSITIVE_HOME_SUBDIRS: readonly string[] = [
  ".ssh",
  ".gnupg",
  ".aws",
  ".config",
  ".docker",
  ".kube",
  ".config/gcloud",
];

/**
 * rc / startup files directly under `$HOME` — the classic redirect-mischief
 * targets (`echo x > ~/.bashrc`).
 */
const SENSITIVE_HOME_RC: readonly string[] = [
  ".bashrc",
  ".bash_profile",
  ".bash_login",
  ".bash_logout",
  ".bash_aliases",
  ".bash_history",
  ".profile",
  ".inputrc",
  ".zshrc",
  ".zprofile",
  ".zshenv",
  ".zlogin",
  ".tmux.conf",
  ".vimrc",
  ".gitconfig",
  ".netrc",
  ".npmrc",
  ".pypirc",
];

/** Basenames that are dangerous no matter which directory they land in. */
const DANGEROUS_BASENAMES: ReadonlySet<string> = new Set([
  "passwd",
  "shadow",
  "gshadow",
  "group",
  "subuid",
  "subgid",
  "authorized_keys",
  "authorized_keys2",
  "known_hosts",
  "id_rsa",
  "id_dsa",
  "id_ecdsa",
  "id_ed25519",
]);

/** Expand a token (`~/...`, absolute, or relative) to an absolute path. */
function expand(token: string, cwd: string): string {
  if (token.startsWith("~")) return HOME + token.slice(1);
  if (isAbsolute(token)) return token;
  return resolvePath(cwd || process.cwd(), token);
}

/** Strip one layer of matching surrounding single/double quotes. */
function stripQuotes(t: string): string {
  if (
    t.length >= 2 &&
    ((t[0] === '"' && t[t.length - 1] === '"') ||
      (t[0] === "'" && t[t.length - 1] === "'"))
  ) {
    return t.slice(1, -1);
  }
  return t;
}

/** True for a bare relative redirect target the `path` surface does not see. */
function isBareRelative(token: string): boolean {
  if (!token) return false;
  if (token.startsWith(".")) return false; // dotfile / ./ — path surface handles
  if (token.includes("/")) return false; // absolute or relative-with-slash — path surface handles
  if (token.includes("..")) return false;
  return true;
}

/** True if an absolute path points at a sensitive write target. */
function isSensitive(absPath: string): boolean {
  if (!absPath) return false;
  const withSlash = absPath.endsWith(sep) ? absPath : absPath + sep;
  for (const prefix of SENSITIVE_ABS_PREFIXES) {
    if (withSlash.startsWith(prefix)) return true;
  }

  const base = absPath.split(sep).pop() ?? "";
  if (DANGEROUS_BASENAMES.has(base)) return true;

  if (HOME && absPath.startsWith(HOME + sep)) {
    const rest = absPath.slice(HOME.length + 1);
    for (const sub of SENSITIVE_HOME_SUBDIRS) {
      if (rest === sub || rest.startsWith(sub + sep)) return true;
    }
    if (SENSITIVE_HOME_RC.includes(rest)) return true;
  }
  return false;
}

/**
 * Detect a suspicious write/redirect in a bash command string.
 *
 * @param command raw bash command
 * @param cwd     effective working directory (from `ctx.cwd`)
 * @returns a `SuspiciousWrite` when a sensitive gap-target is found, else `null`
 */
export function detectSuspiciousWrite(
  command: string,
  cwd: string,
): SuspiciousWrite | null {
  if (!command) return null;

  const flagged: string[] = [];

  // Split on shell separators so a stray `of=` or `>` in an unrelated segment
  // is not attributed to `dd`/a redirect in another segment. Quote-unaware;
  // acceptable for a conservative safety heuristic.
  const segments = command.split(/(?:&&|\|\||[;|&\n])/);

  for (const seg of segments) {
    const s = seg.trim();
    if (!s) continue;

    // (1) dd of=<path> — env-assignment tokens slip the path surface.
    if (/\bdd\b/.test(s)) {
      const ofRe = /\bof\s*=\s*(['"]?)([^'"\s]+)\1/g;
      let m: RegExpExecArray | null;
      while ((m = ofRe.exec(s)) !== null) {
        const target = expand(stripQuotes(m[2]), cwd);
        if (isSensitive(target)) flagged.push(target);
      }
    }

    // (2) bare-relative redirect targets — `>` `>>` `&>` `<digit>>`.
    //     `2>&1`-style FD targets yield an empty capture (next char is `&`)
    //     and are skipped. Tokens with `.`/`/` are left to the path surface.
    const redirRe = /\d?&?>+\s*(['"]?)([^'"\s;&|]+)\1/g;
    let rm: RegExpExecArray | null;
    while ((rm = redirRe.exec(s)) !== null) {
      const token = stripQuotes(rm[2]);
      if (!isBareRelative(token)) continue;
      const target = expand(token, cwd);
      if (isSensitive(target)) flagged.push(target);
    }
  }

  if (flagged.length === 0) return null;

  const targets = [...new Set(flagged)];
  return {
    targets,
    summary: `Writes or redirects to a sensitive target:\n  - ${targets.join("\n  - ")}`,
    reason: `redirect-guard: suspicious write to ${targets.join(", ")}`,
  };
}
