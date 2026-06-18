#!/usr/bin/env bash
#
# install.sh — install pinned runtime deps for every vendored pi extension.
#
# This configuration vendors extension *source* + committed `package-lock.json`
# files but intentionally does NOT vendor `node_modules/` (~1 GB, platform
# specific). Run this once after cloning your dotfiles on a new machine so
# extensions can resolve their imports (croner, msgpackr, sandbox-runtime, …).
#
# Supply-chain model:
#   - Reproducibility + integrity hashing come from each extension's committed
#     `package-lock.json`. We use `npm ci` (lockfile-only, fails if the
#     lockfile is out of sync) wherever a lockfile exists.
#   - `--omit=dev` matches pi's own package-install behavior: devDependencies
#     (typescript, vitest, biome, @types/node …) are not needed at runtime —
#     pi loads .ts via jiti.
#
# Scope:
#   - Installs deps for everything under ~/.pi/agent/extensions/ (vendored).
#   - Does NOT touch pi-managed packages (`npm:` / `git:` entries in
#     settings.json) — pi installs those itself on startup via `pi install`.
#
# Usage:
#   ~/.pi/install.sh                # install/refresh all vendored extensions
#   PI_EXT_DIR=/path ~/.pi/install.sh
#   ~/.pi/install.sh --check        # dry-run: report what would be installed
#
set -euo pipefail

EXT_DIR="${PI_EXT_DIR:-$HOME/.pi/agent/extensions}"
CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

# --- minimal color helpers (no-op when not a tty) ---------------------------
if [[ -t 1 ]]; then
  C_BOLD=$'\033[1m'; C_GREEN=$'\033[32m'; C_RED=$'\033[31m'
  C_YELLOW=$'\033[33m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_BOLD=""; C_GREEN=""; C_RED=""; C_YELLOW=""; C_DIM=""; C_RESET=""
fi
step()  { printf '%s→%s %s\n' "$C_BOLD" "$C_RESET" "$*"; }
ok()    { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
fail()  { printf '  %s✗%s %s\n' "$C_RED" "$C_RESET" "$*"; }
header(){ printf '\n%s%s%s\n' "$C_BOLD" "$*" "$C_RESET"; }

# --- preflight --------------------------------------------------------------
command -v node >/dev/null 2>&1 || { fail "node not found on PATH"; exit 1; }
command -v npm  >/dev/null 2>&1 || { fail "npm not found on PATH";  exit 1; }

if [[ ! -d "$EXT_DIR" ]]; then
  fail "extensions dir not found: $EXT_DIR"
  echo "    Set PI_EXT_DIR or re-run from the intended host."
  exit 1
fi

printf '%snode:%s %s  %snpm:%s %s\n' \
  "$C_DIM" "$C_RESET" "$(node -v)" \
  "$C_DIM" "$C_RESET" "$(npm -v)"
printf '%sextensions:%s %s\n' "$C_DIM" "$C_RESET" "$EXT_DIR"

# Does a package.json declare non-empty runtime `dependencies`?
# (Skips stub manifests like the top-level extensions/package.json.)
has_runtime_deps() {
  node -e \
    "const p=require('$1/package.json');\
     process.exit(p.dependencies&&Object.keys(p.dependencies).length?0:1)"
}

# --- collect targets --------------------------------------------------------
mapfile -t manifests < <(
  find "$EXT_DIR" -name package.json -not -path "*/node_modules/*" \
    -print0 | tr '\0' '\n'
)

failures=()
installed=0
skipped=0

for pkg in "${manifests[@]}"; do
  dir="$(dirname "$pkg")"
  name="$(basename "$dir")"

  if ! has_runtime_deps "$dir"; then
    skipped=$((skipped + 1))
    continue
  fi

  step "$name"

  if [[ $CHECK -eq 1 ]]; then
    if [[ -f "$dir/package-lock.json" ]]; then
      ok "would run: npm ci --omit=dev"
    else
      warn "no package-lock.json — would run: npm install --omit=dev (not reproducible)"
    fi
    installed=$((installed + 1))
    continue
  fi

  if [[ -f "$dir/package-lock.json" ]]; then
    # Reproducible: install exactly what the committed lockfile pins.
    # Fails loudly if the lockfile is out of sync with package.json.
    if (cd "$dir" && npm ci --omit=dev --no-fund --no-audit --no-progress); then
      ok "installed (npm ci)"
      installed=$((installed + 1))
    else
      fail "npm ci failed for $name"
      echo "      ${C_DIM}lockfile out of sync? refresh with:${C_RESET}"
      echo "      ${C_DIM}  (cd \"$dir\" && npm install --omit=dev && git add package-lock.json)${C_RESET}"
      failures+=("$name")
    fi
  else
    # No lockfile: best-effort, NOT reproducible. Warn so it's never silent.
    warn "no package-lock.json — falling back to npm install (unpinned!)"
    if (cd "$dir" && npm install --omit=dev --no-fund --no-audit --no-progress); then
      ok "installed (npm install)"
      installed=$((installed + 1))
    else
      fail "npm install failed for $name"
      failures+=("$name")
    fi
  fi
done

# --- summary ----------------------------------------------------------------
header "summary"
echo "  installed/touched: $installed"
echo "  skipped (no deps): $skipped"
if (( ${#failures[@]} )); then
  echo "  ${C_RED}failed:${C_RESET} ${failures[*]}"
  exit 1
fi
printf '  %s✓ all vendored extension deps installed%s\n' "$C_GREEN" "$C_RESET"
echo
echo "${C_DIM}Next: pi-managed packages (npm:/git: in settings.json) are installed"
echo "automatically by pi on first launch, or run:${C_RESET}"
echo "${C_DIM}  pi list && pi update --extensions${C_RESET}"
