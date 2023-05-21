#!/bin/zsh
# -----------------------------------------------------------------------------
# .zsh 
# -----------------------------------------------------------------------------

# Autoload
autoload -U colors; colors # Let's have some colors first
autoload -U edit-command-line

# -----------------------------------------------------------------------------
# System
# -----------------------------------------------------------------------------
fpath=(~/.zsh $fpath) # Path to zsh functions.
REPORTTIME=3          # Report CPU usage for commands running longer than REPORTTIME seconds
HISTFILE=~/.zhistory  # Location of history file.
HISTSIZE=5000         # The number of commands that are loaded into memory.
SAVEHIST=5000         # The number of commands that are stored in history file.


# -----------------------------------------------------------------------------
# Zstyle
# -----------------------------------------------------------------------------
# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.
# http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# formatting and messages
# http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# -----------------------------------------------------------------------------
# Options 
# -----------------------------------------------------------------------------
setopt SHARE_HISTORY        # Share history between all shells 
setopt INC_APPEND_HISTORY   # Add commands to history as they are entered, don't wait for shell to exit
setopt EXTENDED_HISTORY     # Also remember command start time and duration
setopt HIST_IGNORE_ALL_DUPS # Do not keep duplicate commands in history
setopt HIST_IGNORE_SPACE    # Do not remember commands that start with a whitespace
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
#export PROMPT='[%1~] %:'
export PROMPT='%n@%m %F%/%f $ '
#export PROMPT="%n@%m %/ $ "
export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export TERM="xterm-256color"  # 256 color mode
#export GOPATH=/home/mazon/docs/golang
export PATH='~/.local/bin;/usr/local/bin:~/bin:/opt/coreutils/libexec/gnubin:/usr/local/sbin:/sbin:/usr/bin:/usr/sbin:/bin':$PATH
export PASSWORD_STORE_DIR=/home/mazon/docs/.password-store/
# GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# NNN
export NNN_COLORS="2136"                           # use a different color for each
export NNN_FCOLORS='0000E6310000000000000000'
export NNN_BMS='c:~/dev/self/mygame;h:~;'
# alias ls "nnn -e"
alias nnn "nnn -e"
set --export NNN_FIFO "/tmp/nnn.fifo"

# FZF
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# -----------------------------------------------------------------------------
# Alias
# -----------------------------------------------------------------------------
alias ls="ls --color=auto" 
alias diff="diff -u" # Make unified diff syntax the default
alias sudo="sudo "   # expand sudo aliases
alias config='/usr/bin/git --git-dir=$HOME/dev/self/dotfiles/ --work-tree=$HOME'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias vim="nvim"
alias v="nvim"
alias vi="nvim"

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Fuzzy File search
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Custom
# -----------------------------------------------------------------------------
#gpg-connect-agent updatestartuptty /bye
# CAPS_LOCK as ESC when push and CTRL when pressed.
setxkbmap -option "ctrl:nocaps"
sudo /usr/local/bin/evcape.py &

