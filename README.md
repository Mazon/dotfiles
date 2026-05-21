# dotfiles

Personal dotfiles managed with a [bare Git repo](https://www.atlassian.com/git/tutorials/dotfiles) at `~/.dotfiles`.

```
git clone --bare git@github.com:Mazon/dotfiles.git $HOME/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot checkout
dot config status.showUntrackedFiles no
```

## Overview

| Category | Tool | Notes |
|----------|------|-------|
| **OS** | CachyOS (Arch) + macOS | Shared config where possible |
| **Compositor** | [mango-wm](https://github.com/mangoiv/dotfiles) | Wayland, scroller/tile layouts |
| **Shell** | fish | CachyOS base config + custom bindings |
| **Terminal** | alacritty | Iosevka Nerd Font, Catppuccin Mocha |
| **Editor** | neovim | Lazy-loaded, blink.cmp, treesitter |
| **Multiplexer** | tmux | TPM, vim-tmux-navigator, resurrect/continuum |
| **Prompt** | starship | Powerline style with Nerd Font icons |
| **Launcher** | fuzzel | App launcher |
| **Bar** | waybar | Top bar via mango |
| **Notifications** | swaync | |
| **Font** | Iosevka Nerd Font | |

## Layout

```
~/.config/
├── alacritty/       # terminal — fonts, colors (Catppuccin Mocha)
├── btop/            # system monitor
├── fish/            # shell — fzf, starship, zoxide integrations
├── fuzzel/          # app launcher
├── htop/            # system monitor
├── mango/           # Wayland compositor (Linux only)
│   ├── autostart.sh
│   ├── config.conf  # blur, shadows, layout, theme
│   ├── bind.conf    # keybinds (Colemak layout)
│   ├── env.conf     # env vars (fcitx5, Qt, Wayland)
│   ├── rule.conf
│   ├── scripts/     # brightness, volume, screenshots, idle
│   ├── swaync/      # notification daemon
│   ├── waybar/      # status bar
│   ├── wlogout/     # logout screen
│   └── wallpaper/
├── nvim/            # neovim config
│   ├── init.lua
│   ├── lua/         # options, keymaps, plugins
│   └── after/lsp/   # LSP configs (clangd, gopls, lua_ls, pyright, rust, ts, zls)
├── starship.toml    # prompt theme (powerline, Nerd Font icons)
└── tmux/
    └── tmux.conf    # C-Space leader, vim nav, TPM plugins

~/.local/bin/
├── bootstrap        # install all deps (Arch + macOS)
└── run-llama.sh     # local LLM server
```

## Keybindings (mango)

`Alt` + `h/j/k/l` — focus windows (Colemak-aware)
`Alt` + `1-9` — switch tags
`Alt+Shift` + `1-9` — toggle tags
`Alt+Ctrl+S` — screenshot (grim + slurp + swappy)
`Alt+Ctrl+L` — lock screen (swaylock)
`Alt` + `Space` — app launcher (fuzzel)

## Bootstrap

On a fresh machine:

```sh
# Clone and checkout dotfiles
git clone --bare git@github.com:Mazon/dotfiles.git $HOME/.dotfiles
dot checkout
dot config status.showUntrackedFiles no

# Install everything
~/.local/bin/bootstrap
```

The bootstrap script handles both **Arch Linux** (pacman) and **macOS** (brew), installing:
- CLI tools (fish, nvim, tmux, fzf, fd, bat, starship, zoxide, gitmux, ripgrep…)
- Terminal + fonts (alacritty, Iosevka Nerd Font)
- Wayland stack on Linux (mango-wm, waybar, swaync, fuzzel, swaybg, grim, cliphist, fcitx5…)
- Apps (firefox, signal)
- TPM + tmux plugins

## Linux-only (Wayland)

These are only installed on Arch:

`mango-wm` `waybar` `wlogout` `swaync` `fuzzel` `swaybg` `swaylock` `swayidle` `swayosd` `sway-audio-idle-inhibit` `wl-clip-persist` `cliphist` `wl-clipboard` `wlsunset` `wlr-randr` `dimland` `grim` `slurp` `swappy` `pamixer` `playerctl` `blueman` `nm-applet` `xfce-polkit` `fcitx5` `Bibata-Modern-Ice`

## Theme

Everything uses **Catppuccin Mocha** — alacritty, fzf, fish syntax highlighting, and starship.
Keyboard layout is **Colemak**.
