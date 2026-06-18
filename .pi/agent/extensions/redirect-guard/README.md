# redirect-guard

Companion extension for [`@gotgenes/pi-permission-system`](https://github.com/gotgenes/pi-permission-system)
that lets "gray-area" bash commands run silently (`allow`) **without** losing
protection against their real danger: abusive output redirection / writes to
sensitive targets.

## Why

Commands like `echo`, `printf`, `base64`, `awk` were configured as `ask` purely
because their redirect behavior can be abused (`echo x > ~/.bashrc`,
`cat f > /dev/sda`). That forces a prompt on every safe use too.

The permission system already extracts redirect destinations with tree-sitter
and runs them through a **cross-cutting `path` gate** that takes precedence over
the bash command rule. So the clean fix is mostly config: add a hardened `path`
surface, then flip those commands to `allow`. The `path` surface catches ~90% of
redirect abuse.

This extension fills the **verified gaps** the `path` surface misses:

| Gap | Why the path surface misses it | Caught here |
|-----|-------------------------------|-------------|
| `dd of=/dev/sda`, `dd of=/etc/evil`, `dd of=~/.bashrc` | `of=/dev/sda` is a `variable_assignment` node, explicitly skipped; the token is also rejected as an env-assignment | ✅ |
| `echo x > passwd` (cwd `/etc`), `> authorized_keys` (cwd `~/.ssh`) | bare-relative names (no `.`/`/`) are never path-rule candidates | ✅ |

Redirect targets that contain `.`/`/`/`~` (`echo x > ~/.bashrc`, `> /dev/sda`,
`> .env`) are handled by the `path` surface and are **deliberately not
re-checked** here, to avoid double-prompting.

## Behavior

- Registers a `tool_call` handler for `bash`.
- Runs `detectSuspiciousWrite(command, ctx.cwd)` — pure, sync, no side effects.
- Returns `undefined` (no opinion) unless a gap-target is found → composes
  safely with `pi-permission-system` regardless of load order.
- On a hit: with a UI it asks for confirmation (`ctx.ui.confirm`); headless it
  blocks. Mirrors the official `permission-gate` extension.

## Files

- `index.ts` — `tool_call` handler / factory.
- `detector.ts` — pure redirect/write heuristic (unit-testable).

## Tuning

- The sensitive-target lists live in `detector.ts` (`SENSITIVE_ABS_PREFIXES`,
  `SENSITIVE_HOME_SUBDIRS`, `SENSITIVE_HOME_RC`, `DANGEROUS_BASENAMES`). Keep
  them roughly in sync with the `path` surface in
  `~/.pi/agent/extensions/pi-permission-system/config.json`.
- This is a pragmatic regex heuristic, not a shell parser. It favors a low
  false-positive rate (only fires when a resolved target is genuinely
  sensitive) over perfect recall — the `path` surface is the primary defense.

## Limitations

- Quote-unaware segment splitting (acceptable for a conservative safety net).
- `$HOME`/variable-literal redirect targets (`echo x > $HOME/.bashrc`) are not
  expanded; the `path` surface generally does not resolve those either.
