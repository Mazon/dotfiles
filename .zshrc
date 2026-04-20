# ──────────────────────────────────────────────────────────────────────────────
#  .zshrc — CachyOS zsh config (vanilla, no oh-my-zsh, no p10k)
# ──────────────────────────────────────────────────────────────────────────────
#
# Suggestion: Move EDITOR/VISUAL/PAGER/PATH to ~/.zshenv so they're available
# in non-interactive shells too. See: https://zsh.sourceforge.io/Guide/zshguide02.html

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Environment                                                               │
# └─────────────────────────────────────────────────────────────────────────────┘
export DISABLE_MAGIC_FUNCTIONS=true        # fix pasting URLs and other text
export FZF_BASE=/usr/share/fzf

# ── Editor ───────────────────────────────────────────────────────────────────
if command -v nvim &>/dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
elif command -v vim &>/dev/null; then
  export EDITOR=vim
  export VISUAL=vim
fi

# ── Pager (bat if available) ────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  export PAGER="bat --paging=always"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"                # disable roff formatting for bat
  export BAT_THEME="base16"
else
  export PAGER=less
fi

# ── GPG Agent as SSH Agent ──────────────────────────────────────────────────
# Uses GPG agent for SSH authentication (works with YubiKeys/smartcards).
# Call `gpgtty` after creating new terminal splits (e.g. in tmux) to refresh.
export GPG_TTY=$(tty)
gpgtty() { export GPG_TTY=$(tty); }

if [[ -o interactive ]]; then
  gpgconf --launch gpg-agent &>/dev/null
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # Add default key if no keys are loaded
  if ! ssh-add -l &>/dev/null; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
  fi
fi

# ── PATH ─────────────────────────────────────────────────────────────────────
typeset -U path                           # deduplicate
[[ -d ~/.local/bin ]]   && path=(~/.local/bin   $path)
[[ -d ~/.cargo/bin ]]   && path=(~/.cargo/bin   $path)
[[ -d ~/go/bin ]]       && path=(~/go/bin       $path)

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Shell options                                                             │
# └─────────────────────────────────────────────────────────────────────────────┘
setopt AUTO_CD                  # cd by typing directory name alone
setopt AUTO_PUSHD               # push old dir onto stack on cd
setopt PUSHD_IGNORE_DUPS        # don't push duplicates onto dir stack
setopt INTERACTIVE_COMMENTS     # allow comments in interactive shell
setopt CORRECT                  # command auto-correction
setopt NO_BEEP                  # shut up

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  History                                                                   │
# └─────────────────────────────────────────────────────────────────────────────┘
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY            # share history across all sessions
setopt APPEND_HISTORY           # append, don't overwrite
setopt INC_APPEND_HISTORY       # add commands as they are typed
setopt HIST_IGNORE_ALL_DUPS     # delete old duplicates
setopt HIST_IGNORE_SPACE        # ignore commands starting with space
setopt HIST_SAVE_NO_DUPS        # don't save duplicates
setopt HIST_REDUCE_BLANKS       # trim whitespace
setopt HIST_VERIFY              # expand history, don't execute immediately

HISTORY_IGNORE="(&|[bf]g|c|clear|history|exit|q|pwd|* --help)"

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Completion                                                                │
# └─────────────────────────────────────────────────────────────────────────────┘
autoload -Uz compinit
# rebuild dump once per day for speed
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

setopt ALWAYS_TO_END            # move cursor to end after completion
setopt AUTO_MENU                # press Tab repeatedly to cycle completions
setopt AUTO_LIST                # list choices on ambiguous completion
setopt COMPLETE_IN_WORD         # complete from cursor position, not just end

# case-insensitive, partial-match, substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select                          # arrow-key driven menu
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}%B--- %b%f%d'
zstyle ':completion:*:messages' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format '%F{cyan}%B--- %b (%e) --%f'

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Key bindings                                                              │
# └─────────────────────────────────────────────────────────────────────────────┘
bindkey -e                      # emacs mode

# make delete, home, end work
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[1;5D' backward-word       # Ctrl+Left
bindkey '^[[1;5C' forward-word        # Ctrl+Right

# history search (up/down typed prefix)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A'  up-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search

# unbind Alt+L (used by some terminal multiplexers)
bindkey -r '^[l'

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Colored output                                                            │
# └─────────────────────────────────────────────────────────────────────────────┘
autoload -Uz colors && colors

# ── ls ────────────────────────────────────────────────────────────────────────
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32'
alias ls='ls --color=auto'
alias ll='ls -lh --group-directories-first'
alias la='ls -lhA --group-directories-first'
alias l='ls -lhA --group-directories-first'

# ── grep / ripgrep ───────────────────────────────────────────────────────────
export GREP_COLORS='mt=01;31:fn=35:ln=32:bn=32:se=36'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
if command -v rg &>/dev/null; then
  alias rg='rg --sort path'
fi

# ── less / man colors ───────────────────────────────────────────────────────
export LESS='-R -F -X'
export LESS_TERMCAP_md="$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2>/dev/null)"

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Aliases                                                                   │
# └─────────────────────────────────────────────────────────────────────────────┘

# ── build ────────────────────────────────────────────────────────────────────
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n='ninja'

# ── navigation ───────────────────────────────────────────────────────────────
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

# ── directory stack (works with AUTO_PUSHD) ──────────────────────────────────
alias d='dirs -v'               # show directory stack with numbers
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'

# ── pacman ───────────────────────────────────────────────────────────────────
alias update='sudo pacman -Syu'
alias rmpkg='sudo pacman -Rsn'
alias cleanch='sudo pacman -Scc'
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# ── systemctl ────────────────────────────────────────────────────────────────
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias scu-status='systemctl --user status'

# ── help for newcomers to Arch ───────────────────────────────────────────────
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'

# ── better defaults ──────────────────────────────────────────────────────────
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias wget='wget -c'            # continue downloads

# ── utilities ────────────────────────────────────────────────────────────────
alias tb='nc termbin.com 9999'
alias jctl='journalctl -p 3 -xb'

# ── bat (cat replacement) ───────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Functions                                                                 │
# └─────────────────────────────────────────────────────────────────────────────┘

# Remove orphan packages safely
cleanup() {
  local orphans
  orphans=$(pacman -Qtdq 2>/dev/null)
  if [[ -n "$orphans" ]]; then
    sudo pacman -Rsn $orphans
  else
    echo "No orphan packages to remove."
  fi
}

# Extract any archive
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.tar.zst)   tar --zstd -xf "$1" ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.zst)       zstd -d "$1"     ;;
      *.deb)       ar x "$1"        ;;
      *.lz4)       lz4 -d "$1"      ;;
      *.lzma)      unlzma "$1"      ;;
      *.xz)        unxz "$1"        ;;
      *.cab)       cabextract "$1"  ;;
      *)           echo "extract: unsupported format '$1'" ;;
    esac
  else
    echo "extract: '$1' is not a valid file"
  fi
}

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Git shortcuts                                                             │
# └─────────────────────────────────────────────────────────────────────────────┘
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gco='git checkout'
alias gcm='git checkout main'
alias gcd='git checkout develop'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias grb='git rebase'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gstp='git stash pop'

# ── modern git commands ──────────────────────────────────────────────────────
alias gsw='git switch'                    # modern branch switching
alias gswc='git switch -c'                # create + switch
alias grs='git restore'                   # modern file restore
alias grss='git restore --staged'         # unstage files
alias glog='git log --oneline --graph --decorate --format="%h %s (%cr) <%an>" -20'
alias gconflict='git diff --name-only --diff-filter=U'  # list conflicted files

# Interactive git log with fzf
glogf() {
  git log --oneline --color=always "$@" |
    fzf --ansi --no-sort --reverse \
      --preview 'git show --color=always {1}' \
      --bind 'enter:execute(git show {1} | less -R)+abort'
}

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Prompt — built with pure zsh (vcs_info + precmd)                          │
# │                                                                            │
# │  Layout:                                                                   │
# │    ~/directory  on main +?                              12:34 PM           │
# │    ❯                                                                        │
# └─────────────────────────────────────────────────────────────────────────────┘

# ── Palette ──────────────────────────────────────────────────────────────────
P_CYN='%F{39}'       # directories
P_GRN='%F{76}'       # clean branch, success
P_YLW='%F{178}'      # dirty / modified
P_RED='%F{196}'      # errors, conflicts
P_PRP='%F{135}'      # prompt char
P_GRY='%F{242}'      # dim / secondary info
P_RST='%f'           # reset

# ── vcs_info setup (built into zsh) ──────────────────────────────────────────
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr   "${P_YLW}!"     # unstaged changes
zstyle ':vcs_info:*' stagedstr     "${P_GRN}+"      # staged changes
zstyle ':vcs_info:git:*' formats    "${P_GRY}on %b%m%u%c${P_RST}"
zstyle ':vcs_info:git:*' actionformats "${P_GRY}on %b ${P_RED}%a${P_RST}%m%u%c"

# show untracked indicator if any
+vi-untracked() {
  if [[ -n $(git ls-files --exclude-standard --others 2>/dev/null) ]]; then
    hook_com[misc]+=" ${P_RED}?${P_RST}"
  fi
}
zstyle ':vcs_info:git*+set-message:*' hooks untracked

# ── Assemble prompt via precmd ──────────────────────────────────────────────
set_prompt() {
  vcs_info

  local dir="${P_CYN}%~${P_RST}"
  local git="${vcs_info_msg_0_}"

  PS1="${dir}"
  [[ -n "$git" ]] && PS1+="  ${git}"
  PS1+=$'\n'"${P_PRP}❯ ${P_RST}"
  PS2="${P_PRP}❯ ${P_RST}"

  RPS1="${P_GRY}%*${P_RST}"
}
precmd_functions+=(set_prompt)

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Plugins (standalone, no framework required)                               │
# │  Order matters: source highlighting last                                   │
# └─────────────────────────────────────────────────────────────────────────────┘

# ── History substring search (loaded immediately — needed for key bindings) ──
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── FZF ──────────────────────────────────────────────────────────────────────
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Use fd for file/directory listing if available (10x faster than find)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border=sharp
  --info=inline
  --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null'
  --preview-window 'right,50%,wrap,follow'
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --bind 'ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort'
  --bind 'ctrl-/:toggle-preview'
"

# Ctrl+T: file preview with bat
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null'
  --preview-window 'right,60%,wrap'
"

# Alt+C: cd with directory preview
if command -v eza &>/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {} 2>/dev/null || ls {}'"
else
  export FZF_ALT_C_OPTS="--preview 'ls {}'"
fi

# ── Deferred plugins (load after first prompt for faster startup) ─────────────
_zsh_deferred_plugins() {
  # Fish-like autosuggestions
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)

  # Syntax highlighting (MUST be last plugin)
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

  # pkgfile command-not-found
  source /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _deferred_plugin_loader
_deferred_plugin_loader() {
  add-zsh-hook -d precmd _deferred_plugin_loader  # run once
  _zsh_deferred_plugins
}

# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  Modern tooling                                                            │
# └─────────────────────────────────────────────────────────────────────────────┘

# ── zoxide (smart cd replacement) ────────────────────────────────────────────
# Install: sudo pacman -S zoxide
# Provides: z <dir> (jump), zi <dir> (interactive with fzf)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi
