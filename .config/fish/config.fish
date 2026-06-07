# ── CachyOS base config ──────────────────────────────────
source /usr/share/cachyos-fish-config/cachyos-config.fish

# ── Environment ──────────────────────────────────────────
set -gx MANROFFOPT "-c"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx EDITOR nvim
fish_add_path ~/.local/bin

# ── GPG Agent + Nitrokey SSH ────────────────────────────
set -gx GPG_TTY (tty)
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# ── fzf ──────────────────────────────────────────────────
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,fg+:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#F5E0DC,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=border:#45475A \
--border=rounded \
--prompt=' ' \
--pointer='▶' \
--marker='✓' \
--preview-window='border-rounded' \
--height=~80% \
--layout=reverse \
--cycle"

# ── Catppuccin Mocha syntax highlighting ─────────────────
set -g fish_color_command green
set -g fish_color_keyword magenta
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection blue --bold
set -g fish_color_end green
set -g fish_color_error red
set -g fish_color_comment brblack --italic
set -g fish_color_operator brcyan
set -g fish_color_autosuggestion brblack
set -g fish_color_search_match --background=brblack
set -g fish_color_selection --background=brblack

# ── Integrations ─────────────────────────────────────────
fzf --fish | source
# zoxide init fish | source  # uncomment after: sudo pacman -S zoxide
starship init fish | source

# ── Autosuggestion keybindings ──────────────────────────
bind \cy accept-autosuggestion
bind \ce forward-word
bind \cf forward-char

# ── Dotfiles bare repo ──────────────────────────────────
alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
