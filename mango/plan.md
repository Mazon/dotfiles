# Mango Configuration Review — Findings Report

## Purpose
Thorough review of the mango Wayland compositor configuration at `~/.config/mango`. Mango appears to be a dwl-based/fork Wayland compositor using a `key=value` configuration format with support for blur, shadows, animations, multiple tiling layouts, and an IPC command (`mmsg`). This report catalogs all issues, improvements, and optimizations found.

## Current Configuration Summary

| Component | File(s) | Role |
|-----------|---------|------|
| Core config | `config.conf` | Effects, animations, layout, keyboard, mouse, appearance |
| Key bindings | `bind.conf` | Window management, layout, tags, media keys |
| Window rules | `rule.conf` | Per-app floating, opacity, tag placement, layer rules |
| Environment | `env.conf` | XCursor, IME (fcitx), Qt/Gtk platform variables |
| Autostart | `autostart.sh` | Display setup, daemons (swaync, waybar, fcitx5, etc.), app launch |
| Waybar | `waybar/config.jsonc`, `waybar/style.css` | Top bar: workspaces, window, volume, clock, notifications |
| SwayNC | `swaync/config.json`, `swaync/style.css`, `swaync/sound/` | Notification daemon with per-app sound scripts |
| Rofi | `rofi/config.rasi`, `rofi/gruvbox-dark-hard.rasi` | App launcher theme |
| Wlogout | `wlogout/layout`, `wlogout/style.css` | Logout/lock/power menu |
| Scripts | `scripts/*.sh` | Brightness, volume, screenshots, idle, monitor, waybar toggle |

---

## Findings

### 1. Correctness / Bugs

#### 1.1 [HIGH] Duplicate keybinding — `ALT+CTRL+Q` bound twice
- **File:** `bind.conf` lines 3–4
- **Issue:** Both `binds=ALT+CTRL,q,reload_config` (line 3) and `binds=ALT+CTRL,q,killclient,` (line 4) use the same key chord. The second silently overrides the first (or both conflict). One of them must be wrong.
  - Line 3: `binds=ALT+CTRL,q,reload_config` — likely intended to be `ALT+CTRL,r` for reload? But `ALT+CTRL,r` is already bound to `reload_config` on line 2.
  - Line 4: `binds=ALT+CTRL,q,killclient,` — trailing comma.
- **Fix:** Decide which action `ALT+CTRL+Q` should trigger. If quit, remove the duplicate `reload_config` line. If reload, fix the key for kill client. Remove trailing comma on line 4.

#### 1.2 [HIGH] Duplicate keybinding — `ALT+SHIFT+S` bound twice
- **File:** `bind.conf` lines 26 and 42
- **Issue:** `binds=ALT+SHIFT,S,zoom,` (line 26, switch master) and `binds=ALT+SHIFT,S,setlayout,scroller` (line 42). Both use `ALT+SHIFT+S`.
- **Fix:** Rebind one of them to a different key.

#### 1.3 [HIGH] Duplicate keybinding — `ALT+SHIFT+R` bound twice
- **File:** `bind.conf` lines 19 and 41
- **Issue:** `binds=ALT+SHIFT,R,togglegaps` (line 19) and `binds=ALT+SHIFT,R,setlayout,right_tile` (line 41).
- **Fix:** Rebind one of them.

#### 1.4 [MEDIUM] Inconsistent `binds` vs `bind` keyword
- **File:** `bind.conf` lines 86–94
- **Issue:** Lines 86–94 use `bind=` instead of `binds=`. Lines 52–83 use `binds=`. This is inconsistent. If `bind` and `binds` are both valid in mango, this is a style issue. If not, the `bind=` lines may be silently ignored.
- **Fix:** Normalize to `binds=` throughout unless `bind` is a distinct mango directive.

#### 1.5 [MEDIUM] Trailing commas in bind values
- **File:** `bind.conf` lines 4, 26, 44, 45
- **Issue:** Several binds end with a trailing comma (e.g., `binds=ALT+CTRL,q,killclient,`). This may or may not be valid syntax depending on mango's parser, but is inconsistent with other entries.
- **Fix:** Remove trailing commas for consistency.

#### 1.6 [MEDIUM] `animation_curve_open` contains a value > 1.0
- **File:** `config.conf` line 45
- **Issue:** `animation_curve_open=0.46,1.0,0.29,1.1` — the last control point is `1.1`. CSS-style cubic-bezier curves are typically clamped to [0,1]. While some engines support out-of-range values for "overshoot" effects, this should be intentional.
- **Fix:** If intentional overshoot, add a comment explaining it. Otherwise, change to `1.0`.

#### 1.7 [MEDIUM] `GLFW_IM_MODULE` set to `ibus` but IME is `fcitx5`
- **File:** `env.conf` line 7
- **Issue:** `env=GLFW_IM_MODULE,ibus` — all other IME variables are set to `fcitx`/`fcitx5`, and `fcitx5` is launched in autostart. Setting `GLFW_IM_MODULE=ibus` may cause GLFW-based apps to look for ibus instead of fcitx.
- **Fix:** Change to `env=GLFW_IM_MODULE,fcitx` or remove if fcitx5 handles this natively.

#### 1.8 [LOW] `swaync` path inconsistency in autostart
- **File:** `autostart.sh` lines 12–13
- **Issue:** A commented-out line references `~/.config/mango/swaync/config.jsonc` while the active line uses `~/.config/swaync/config.json`. Meanwhile, the mango-local swaync config is at `~/.config/mango/swaync/config.json`. The active swaync command points to `~/.config/swaync/` (the default XDG path), not the mango-local one.
- **Fix:** Either:
  - If the local config is the one to use: change line 13 to `-c ~/.config/mango/swaync/config.json -s ~/.config/mango/swaync/style.css`
  - Or, if `~/.config/swaync/` is intentionally a symlink/copy: document this.

#### 1.9 [MEDIUM] Idle timer ordering is wrong
- **File:** `scripts/idle.sh` lines 12–15
- **Issue:** The dim timeout (300s) fires *after* the DPMS-off timeout (1800s = 30 min). Since swayidle processes timeouts in elapsed-time order, the 300s timer fires first at 5 minutes, but then the 1800s timer fires at 30 min. The `resume` after DPMS-off runs `restart_wlsunset.sh`, but the `resume` after dim only kills dimland. When DPMS-off triggers, the screen is already off so dimland's resume never fires correctly relative to DPMS resume. The logic seems to work but is fragile.
- **Fix:** Consider restructuring so that dim is a shorter timeout and DPMS is a longer one, with clear resume chains. Add comments explaining the intended order.

#### 1.10 [LOW] Waybar `custom/updates` module references wrong path
- **File:** `waybar/config.jsonc` lines 91–99
- **Issue:** The `custom/updates` module is defined but never included in any module section (left/center/right). It references `~/.config/waybar/scripts/update-sys` which is outside the mango config tree. If unused, it should be removed.
- **Fix:** Either add to `modules-right` or remove the definition.

---

### 2. Security Concerns

#### 2.1 [HIGH] `restart_wlsunset.sh` uses `sudo kill`
- **File:** `scripts/restart_wlsunset.sh` line 5
- **Issue:** `xargs sudo kill` runs kill as root. Killing user processes with sudo is unnecessary and a security risk — it means the user has a passwordless sudo rule or is prompted for a password in the background.
- **Fix:** Remove `sudo`. Use `xargs kill` (or `pkill wlsunset`). User processes can be killed without root.

#### 2.2 [MEDIUM] `set +e` in autostart.sh masks all errors
- **File:** `autostart.sh` line 3
- **Issue:** `set +e` disables error propagation. While useful so one failing daemon doesn't block others, it means you'll never know if a startup command fails silently.
- **Fix:** Consider logging failures: `wlsunset ... || echo "wlsunset failed" >> ~/.cache/mango/autostart.log` or use individual `|| true` per command and keep `set -e`.

#### 2.3 [MEDIUM] `set +e` in `restart_wlsunset.sh` also masks errors
- **File:** `scripts/restart_wlsunset.sh` line 3
- **Issue:** Same concern as above.

#### 2.4 [LOW] Lock screen uses plain black color, no image
- **File:** `bind.conf` line 5, `wlogout/layout` line 3
- **Issue:** `swaylock -f -c 000000` — plain black screen. While functional, this offers minimal visual feedback that the screen is locked vs off. Consider using a lock image or blur effect.
- **Fix:** Consider `swaylock -f --effect-blur 5x5` or similar if swaylock-effects is available.

#### 2.5 [LOW] `signal-desktop --password-store='kwallet6'`
- **File:** `autostart.sh` line 58
- **Issue:** Explicitly choosing kwallet6 as the password backend. This is fine if KDE is installed, but on a wlroots-based compositor without KDE, kwallet may not be running or accessible. If this fails silently, Signal may fall back to plaintext credential storage.
- **Fix:** Verify kwallet6 is available, or consider using `--password-store=gnome` (if gnome-keyring is available) or the default.

---

### 3. Performance

#### 3.1 [MEDIUM] `custom/workspace-logic` polls every 1 second
- **File:** `waybar/config.jsonc` line 104
- **Issue:** `"interval": 1` causes `windowtags.sh` to run every second. This script runs `mmsg -g -t -c` and pipes through `awk` and `paste`. On slower systems, this could cause noticeable overhead.
- **Fix:** If mango/mmsg supports a signal-based update mechanism (e.g., `exec-on-event` or a wayland event), use that instead. Otherwise, consider increasing the interval to 2–3 seconds.

#### 3.2 [LOW] Blur enabled with `blur=0` but `blur_layer=1`
- **File:** `config.conf` lines 2–3
- **Issue:** `blur=0` (disable blur for windows?) but `blur_layer=1` (enable blur for layers?). If layer blur is on but window blur is off, the compositor still does blur work for layer surfaces. The `blur_optimized=1` flag helps, but verify this is the intended behavior.
- **Fix:** If layer blur is also unwanted, set `blur_layer=0`.

#### 3.3 [LOW] `repeat_delay=600` is quite long
- **File:** `config.conf` line 94
- **Issue:** A 600ms repeat delay is noticeably sluggish. Most users prefer 200–350ms. Combined with `repeat_rate=25`, this may feel unresponsive for keyboard-driven workflows.
- **Fix:** Consider `repeat_delay=300` and `repeat_rate=35` for snappier key repeat.

#### 3.4 [LOW] `swaybg` runs without `--mode` flag
- **File:** `autostart.sh` line 19
- **Issue:** `swaybg -i ~/.config/mango/wallpaper/wallpaper.png` doesn't specify a mode. Default is typically "stretch" or "fill" depending on version. Explicit is better.
- **Fix:** Add `--mode fill` or `--mode center` to match intended behavior.

---

### 4. Missing Settings / Best Practices

#### 4.1 [MEDIUM] No `swayidle` / idle manager in autostart
- **File:** `autostart.sh`
- **Issue:** The `idle.sh` script exists but is never launched from `autostart.sh`. There's no reference to `swayidle` anywhere in the autostart. This means the screen never dims or turns off automatically.
- **Fix:** Add `~/.config/mango/scripts/idle.sh &` or a direct `swayidle` call to `autostart.sh`.

#### 4.2 [MEDIUM] No mute keybinding
- **File:** `bind.conf`
- **Issue:** Volume up/down bindings exist (lines 98–99) but there is no mute toggle binding for `XF86AudioMute`. The `volume.sh` script supports a `mute` action.
- **Fix:** Add: `binds=none,XF86AudioMute,spawn,~/.config/mango/scripts/volume.sh mute`

#### 4.3 [MEDIUM] No microphone mute keybinding
- **File:** `bind.conf`
- **Issue:** No `XF86AudioMicMute` binding. Waybar shows a microphone module, but there's no dedicated key to toggle it.
- **Fix:** Add: `binds=none,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle`

#### 4.4 [MEDIUM] Move-to-tag keybindings are all commented out
- **File:** `bind.conf` lines 62–71
- **Issue:** `SHIFT+Alt+1..9` for moving windows to tags is commented out. This is a fundamental tiling WM operation. Without it, the only way to move windows is `ALT+CTRL+1..9` (toggletag), which is attach/detach, not a clean move.
- **Fix:** Uncomment or provide alternative move-to-tag bindings.

#### 4.5 [LOW] No XF86AudioPlay / XF86AudioNext / XF86AudioPrev media keys
- **File:** `bind.conf`
- **Issue:** No media player control bindings for play/pause, next, previous.
- **Fix:** Add bindings like:
  ```
  binds=none,XF86AudioPlay,spawn,playerctl play-pause
  binds=none,XF86AudioNext,spawn,playerctl next
  binds=none,XF86AudioPrev,spawn,playerctl previous
  ```

#### 4.6 [LOW] `wlsunset` temperatures are nearly identical
- **File:** `autostart.sh` line 16, `scripts/restart_wlsunset.sh` line 7
- **Issue:** `-T 3501 -t 3500` — the daytime temp is 3501K and nighttime is 3500K. The difference is only 1K, which is visually imperceptible. This effectively means the screen is always at ~3500K with no actual day/night transition.
- **Fix:** Set a more meaningful daytime temperature, e.g., `-T 6500 -t 3500` for a proper blue-light reduction at night.

#### 4.7 [LOW] No `swappy` configuration
- **File:** `scripts/screenshot.sh`
- **Issue:** Uses `swappy` for screenshot annotation but no `~/.config/swappy/config` is present in the mango tree. It may exist elsewhere, but if not, swappy uses defaults which may not be ideal.
- **Fix:** Create a swappy config with preferred save directory and settings.

#### 4.8 [LOW] `README.md` is empty
- **File:** `README.md`
- **Issue:** The README has no content. A brief description of the config structure and how to use it would be helpful.
- **Fix:** Add a short description of mango, the config layout, and how to modify settings.

---

### 5. Consistency Issues

#### 5.1 [MEDIUM] Theme / color palette inconsistency across components
- **Files:** `config.conf`, `waybar/style.css`, `swaync/style.css`, `rofi/config.rasi`, `wlogout/style.css`
- **Issue:** The configs use different color palettes:
  - `config.conf`: earthy brown tones (`0x201b14` bg, `0x8BAA9B` focus, `0xBABD2C` maximize)
  - `waybar/style.css`: Dracula palette (`rgba(30, 31, 41, 0.9)` bg, `#ff5555` red, `#8be9fd` cyan)
  - `swaync/style.css`: Gruvbox-inspired (`rgba(60, 58, 57, 0.8)` bg, `#d79921` yellow)
  - `rofi/config.rasi`: Gruvbox (`#201B14` bg, `#AC9259` highlight)
  - `wlogout/style.css`: warm earth tones (`rgba(46, 42, 30, 0.69)` bg, `#d5b497` text)
  
  The rofi and wlogout align well with `config.conf`'s earthy tones. Waybar uses a completely different Dracula theme. SwayNC is in between.
- **Fix:** Decide on a unified palette (likely Gruvbox/earthy based on the compositor config and rofi) and update waybar to match. At minimum, ensure `background`, `foreground`, `accent`, and `border` colors are consistent.

#### 5.2 [MEDIUM] Font inconsistency across components
- **Files:** `waybar/style.css` line 18, `swaync/style.css` line 12, `rofi/config.rasi` line 21, `wlogout/style.css` line 2
- **Issue:**
  - Waybar: `"JetBrainsMono Nerd Font", "monospace"`
  - SwayNC: `"HYLeMiaoTiJ"` (a Chinese font)
  - Rofi: `"Maple Mono NF CN bold 18"`
  - Wlogout: `"HYLeMiaoTiJ,CaskaydiaCove Nerd Font"`
  
  Three different monospace fonts are used (JetBrains Mono, Maple Mono, CaskaydiaCove) plus a Chinese font (HYLeMiaoTiJ). This creates visual inconsistency.
- **Fix:** Standardize on 1–2 fonts: one monospace (e.g., Maple Mono NF) and one CJK (e.g., HYLeMiaoTiJ), used consistently.

#### 5.3 [LOW] Mixed shebangs in scripts
- **Files:** `scripts/*.sh`, `swaync/sound/*.sh`
- **Issue:** Some scripts use `#!/bin/bash`, others use `#!/usr/bin/bash`, and sound scripts use `#!/usr/bin/env bash`. Three different shebangs.
- **Fix:** Standardize to `#!/usr/bin/env bash` (most portable) across all scripts.

#### 5.4 [LOW] Commented-out references to `hypr` in idle.sh
- **File:** `scripts/idle.sh` lines 3–9
- **Issue:** Old commented-out config references `hyprctl` and `~/.config/hypr/scripts/`. This is leftover from a Hyprland config migration.
- **Fix:** Remove the commented-out Hyprland lines for cleanliness.

#### 5.5 [LOW] Commented-out references to `hypr` in `restart_wlsunset.sh`
- **File:** `scripts/restart_wlsunset.sh`
- **Issue:** The `grep -v swayidle | grep -v restart` patterns in the process kill line were likely inherited from an older setup. The filter `grep -v swayidle` prevents killing swayidle if it happens to match "wlsunset" in some output, but this is fragile.
- **Fix:** Use `pkill -x wlsunset` instead of the complex grep-awk-xargs pipeline.

---

### 6. Style / Quality

#### 6.1 [LOW] Inconsistent indentation in config files
- **File:** `config.conf`
- **Issue:** Most settings use `key=value` without spaces around `=`, but some have spaces:
  - `blur_params_num_passes = 2` (spaces around `=`)
  - `shadows_size = 12` (spaces around `=`)
  - `animation_duration_move=500` (no spaces)
  - `shadowscolor= 0x000000ff` (space only after `=`)
  - `binds=ALT+CTRL,q,killclient,` (trailing comma)
  
  This is cosmetic but makes the file harder to scan.
- **Fix:** Normalize to `key=value` (no spaces) throughout for consistency.

#### 6.2 [LOW] Inconsistent indentation in JSON files
- **Files:** `swaync/config.json`, `waybar/config.jsonc`
- **Issue:** Mixed tabs and spaces. `swaync/config.json` uses tabs on some lines and spaces on others. `waybar/config.jsonc` uses 4-space indentation but has trailing commas in some places and not others.
- **Fix:** Run through a JSON formatter with consistent indentation (2 spaces is standard for JSON).

#### 6.3 [LOW] Unused variables in scripts
- **File:** `scripts/brightness.sh` lines 13–15, `scripts/volume.sh` lines 7–18
- **Issue:** In `brightness.sh`, the `get_brightness` and `send_notification` functions are defined but never called (the code using them is commented out). Similarly in `volume.sh`, `get_volume`, `is_mute`, and `send_notification` are unused. These are dead code.
- **Fix:** Remove the unused functions or uncomment the code that uses them.

#### 6.4 [LOW] Hardcoded icon paths
- **File:** `scripts/brightness.sh` line 15, `scripts/volume.sh` lines 28–44
- **Issue:** Icon paths like `/usr/share/icons/Adwaita/96x96/status/audio-volume-*.symbolic.png` and `${HOME}/.config/rice_assets/Icons/b.png` are hardcoded. If icons move or packages change, these break silently.
- **Fix:** Use icon lookups (e.g., `find` or `xdg-icon-resource`) or rely on the icon theme name.

#### 6.5 [LOW] `windowtags.sh` has commented-out logic blocks
- **File:** `scripts/windowtags.sh` lines 14–25
- **Issue:** Half the script is commented out. This makes it hard to understand the intended behavior.
- **Fix:** Remove dead code or document what the commented sections were for.

#### 6.6 [LOW] Waybar CSS references undefined color variable
- **File:** `waybar/style.css` line 144
- **Issue:** `background: @black;` — there is no `@black` defined in the color definitions. This will either fall back to transparent or produce a CSS warning.
- **Fix:** Define `@black` in the color definitions or replace with an explicit value like `#000000`.

---

### 7. Robustness / Reliability

#### 7.1 [HIGH] `monitor.sh` lacks quoting and will break on unexpected output
- **File:** `scripts/monitor.sh` lines 3–4
- **Issue:** `$enable` is unquoted in the comparison `[ $enable == "true" ]`. If `wlr-randr` fails or returns empty, this becomes `[ == "true" ]` which is a syntax error. Also uses `[ ]` (test) instead of `[[ ]]` (bash).
- **Fix:** Rewrite:
  ```bash
  enable=$(wlr-randr --json | jq --arg name "eDP-1" '.[] | select(.name == $name) | .enabled')
  if [[ "$enable" == *"true"* ]]; then
      wlr-randr --output eDP-1 --off
  else
      wlr-randr --output eDP-1 --on
  fi
  ```

#### 7.2 [MEDIUM] `exitdim.sh` is fragile
- **File:** `scripts/exitdim.sh`
- **Issue:** `ps aux | grep -v grep | grep dimland | grep -v idle | awk '{print $2}' | xargs kill` — multiple pipes, no error handling, will fail silently if dimland isn't running. Also, piping to `xargs kill` with no arguments will cause `kill` to show usage.
- **Fix:** Replace with `pkill -x dimland` or `pkill -f dimland`.

#### 7.3 [MEDIUM] `restart_wlsunset.sh` is fragile
- **File:** `scripts/restart_wlsunset.sh` line 5
- **Issue:** Complex grep chain to find wlsunset PID. Multiple `grep -v` filters are needed to avoid false matches. This is error-prone.
- **Fix:** Use `pkill -x wlsunset` instead.

#### 7.4 [MEDIUM] No process deduplication in autostart
- **File:** `autostart.sh`
- **Issue:** Every time the autostart runs (e.g., on config reload or compositor restart), all daemons are launched again. There's no check for already-running instances. While most daemons handle this gracefully (waybar, swaync), some may not (fcitx5 uses `--replace` which is good, but others don't).
- **Fix:** Use `pidof`/`pgrep` checks before launching, or use mango's `exec-once` mechanism which should handle this automatically (it's already used for the autostart script itself, but individual daemons inside the script aren't protected).

#### 7.5 [LOW] `hide_waybar_mango.sh` uses `pgrep` then `pkill`
- **File:** `scripts/hide_waybar_mango.sh`
- **Issue:** Line 3 uses `pgrep waybar` to check if running, then line 6 uses `pkill waybar`. Could use `pkill -x waybar` directly with a check. Also, when restarting, it runs waybar in the foreground (no `&`), blocking the terminal.
- **Fix:** This is acceptable for a toggle script but consider adding `&` and `disown` if called from a keybind that shouldn't block.

---

### 8. Waybar-Specific Issues

#### 8.1 [MEDIUM] Waybar `ext/workspaces` is a custom module — may require external support
- **File:** `waybar/config.jsonc` lines 39–52
- **Issue:** `ext/workspaces` is not a standard waybar module. It appears to be a mango-specific waybar extension. If it's not installed or the waybar doesn't have the mango plugin, this will silently fail.
- **Fix:** Document this dependency. Ensure the mango waybar extension is installed.

#### 8.2 [LOW] Waybar CSS selector grouping bug
- **File:** `waybar/style.css` line 76
- **Issue:** `#custom-power #custom-swaync` has a space between selectors, meaning "#custom-swaync that is a descendant of #custom-power". This is likely not the intent — it should be `#custom-power, #custom-swaync` (comma separated) to apply styles to both independently.
- **Fix:** Change `#custom-power #custom-swaync` to `#custom-power, #custom-swaync`.

#### 8.3 [LOW] Waybar clock module has no format defined
- **File:** `waybar/config.jsonc` lines 106–112
- **Issue:** The clock module has all its format settings commented out. It will use waybar's default format, which may not be what's desired.
- **Fix:** Define at least a format, e.g., `"format": "{:%H:%M}"`.

---

### 9. Rofi-Specific Issues

#### 9.1 [LOW] Rofi has two theme files that may conflict
- **Files:** `rofi/config.rasi`, `rofi/gruvbox-dark-hard.rasi`
- **Issue:** `config.rasi` has its own complete theme inline, and `gruvbox-dark-hard.rasi` is a separate theme file. Neither file imports the other. If `config.rasi` is the one actually used (as rofi's default config location), `gruvbox-dark-hard.rasi` is unused.
- **Fix:** Either have `config.rasi` import `gruvbox-dark-hard.rasi` via `@theme` or remove the unused file.

#### 9.2 [LOW] Rofi `message` block has `background-color: red`
- **File:** `rofi/config.rasi` line 117
- **Issue:** The `message` widget has `background-color: red`. This is likely a debug leftover and will show a red box if any message is displayed.
- **Fix:** Change to `background-color: transparent;` or remove.

---

## Summary by Severity

### High (5)
1. Duplicate `ALT+CTRL+Q` binding
2. Duplicate `ALT+SHIFT+S` binding
3. Duplicate `ALT+SHIFT+R` binding
4. `sudo kill` in `restart_wlsunset.sh`
5. Unquoted variable in `monitor.sh`

### Medium (14)
6. Inconsistent `bind` vs `binds` keyword
7. Trailing commas in bind values
8. Animation curve value > 1.0
9. `GLFW_IM_MODULE=ibus` but using fcitx5
10. swaync path inconsistency in autostart
11. Idle timer ordering fragile
12. No swayidle in autostart
13. No mute keybinding
14. No mic mute keybinding
15. Move-to-tag bindings all commented out
16. Color palette inconsistency
17. Font inconsistency
18. `exitdim.sh` fragile
19. `restart_wlsunset.sh` fragile

### Low (20)
20. Waybar `custom/updates` unused module definition
21. Lock screen is plain black
22. Signal password store backend may not work
23. workspace-logic polling every 1s
24. Blur settings may be unintended
25. `repeat_delay=600` is sluggish
26. swaybg missing mode flag
27. No media key bindings
28. wlsunset temperatures nearly identical
29. No swappy config
30. Empty README
31. Mixed shebangs
32. Leftover Hyprland references
33. Inconsistent config indentation
34. Inconsistent JSON indentation
35. Dead code in scripts
36. Hardcoded icon paths
37. Commented-out logic in windowtags.sh
38. Waybar CSS undefined `@black`
39. Waybar CSS selector grouping bug
40. Waybar clock no format
41. Rofi unused theme file
42. Rofi red message background
43. No process deduplication in autostart

---

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Assumed mango is a dwl-fork Wayland compositor | Based on `mmsg` IPC, tag-based workspace model, `config.conf` format, wlroots ecosystem tools |
| Did not verify script execute permissions | Could not run `ls -la` but all scripts have proper shebangs; recommend verifying |
| Did not validate against mango's actual config schema | No documentation found; findings based on general tiling WM knowledge and code analysis |
| Color theme analysis is subjective | Noted inconsistencies as-is; the "right" palette is a personal preference |
| Focused on the mango config tree only | Swaync runs from `~/.config/swaync/` per autostart, but the mango-local config exists — flagged as inconsistency |

## Surprises & Discoveries

1. **Mango appears to be a feature-rich dwl fork** with blur, shadows, animations, overview mode, scroller layout, and a `mmsg` IPC — more features than standard dwl.
2. **Multiple Hyprland migration artifacts** remain in idle.sh and restart_wlsunset.sh.
3. **The wlsunset temperature config makes it effectively non-functional** (1K difference).
4. **Three critical keybinding conflicts** mean the user is likely not getting the behavior they expect from `ALT+CTRL+Q`, `ALT+SHIFT+S`, and `ALT+SHIFT+R`.
5. **Idle management (swayidle) is never started**, meaning the screen never auto-dims or turns off.
