#!/bin/zsh
# -----------------------------------------------------------------------------
# .zsh 
# -----------------------------------------------------------------------------

# Autoload
autoload -U colors; colors # Let's have some colors first
autoload -U edit-command-line
#autoload -Uz name_of_the_prompt_file; name_of_the_prompt_file # Setup the Prompt
# CAPS already remapped to CTRL.
# make short-pressed Ctrl behave like Escape:


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
export PROMPT='[%1~] %:'
export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export TERM="xterm-256color"  # 256 color mode
export GOPATH=/home/mazon/docs/golang
export PATH='/usr/local/bin:~/bin:/opt/coreutils/libexec/gnubin:/usr/local/sbin:/sbin:/usr/bin:/usr/sbin:/bin':$PATH
export PASSWORD_STORE_DIR=~/.password-store
# GPG
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

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

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
#function zle-keymap-select {
#  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
#  zle reset-prompt
#}
#zle -N zle-keymap-select
#
#function zle-line-finish {
#  vim_mode=$vim_ins_mode
#}
#zle -N zle-line-finish

# Fuzzy File search
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# typing ... expands to ../.., .... to ../../.., etc.
#rationalise-dot() {
#	if [[ $LBUFFER = *.. ]]; then
#		LBUFFER+=/..
#	else
#		LBUFFER+=.
#	fi
#}
#zle -N rationalise-dot
#bindkey . rationalise-dot
#bindkey -M isearch . self-insert # history search fix

# -----------------------------------------------------------------------------
# Custom
# -----------------------------------------------------------------------------
xcape -e 'Control_L=Escape' # Remap CTRL and ESC.
#gpg-connect-agent updatestartuptty /bye

# Extras
# Syntax highlighting plugin
#if [[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
#	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#elif [[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
#	source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#fi

#source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# VI MODE KEYBINDINGS (ins mode)
#bindkey -M viins '^a'    beginning-of-line
#bindkey -M viins '^n'    vi-cmd-mode
#bindkey -M viins '^o'    accept-line
#bindkey -M viins '^e'    end-of-line
#bindkey -M viins -s '^b' "←\n" # C-b move to previous directory (in history)
#bindkey -M viins -s '^f' "→\n" # C-f move to next directory (in history)
#bindkey -M viins '^k'    kill-line
#bindkey -M viins '^r'    history-incremental-pattern-search-backward
#bindkey -M viins '^s'    history-incremental-pattern-search-forward
#bindkey -M viins '^o'    history-beginning-search-backward
#bindkey -M viins '^p'    history-beginning-search-backward
#bindkey -M viins '^n'    history-beginning-search-forward
####################bindkey -M viins '^y'    yank
####################bindkey -M viins '^w'    backward-kill-word
#bindkey -M viins '^u'    backward-kill-line
#bindkey -M viins '^h'    backward-delete-char
#bindkey -M viins '^?'    backward-delete-char
#bindkey -M viins '^_'    undo
#bindkey -M viins '^x^l'  history-beginning-search-backward-then-append
#bindkey -M viins '^x^r'  redisplay
#bindkey -M viins '\eOH'  beginning-of-line # Home
#bindkey -M viins '\eOF'  end-of-line       # End
#bindkey -M viins '\e[2~' overwrite-mode    # Insert
#bindkey -M viins '^u' fh

# VI MODE KEYBINDINGS (cmd mode)
#bindkey -M vicmd 'ca'    change-around
#bindkey -M vicmd 'ci'    change-in
#bindkey -M vicmd 'da'    delete-around
#bindkey -M vicmd 'di'    delete-in
#bindkey -M vicmd 'ga'    what-cursor-position
#bindkey -M vicmd 'gg'    beginning-of-history
#bindkey -M vicmd 'G '    end-of-history
#bindkey -M vicmd '^a'    beginning-of-line
#bindkey -M vicmd '^e'    end-of-line
#bindkey -M vicmd '^k'    kill-line
#bindkey -M vicmd '^r'    history-incremental-pattern-search-backward
#bindkey -M vicmd '^s'    history-incremental-pattern-search-forward
#bindkey -M vicmd '^o'    history-beginning-search-backward
#bindkey -M vicmd '^p'    history-beginning-search-backward
#bindkey -M vicmd '^n'    history-beginning-search-forward
#bindkey -M vicmd '^y'    yank
#bindkey -M vicmd '^w'    backward-kill-word
#bindkey -M vicmd '^u'    backward-kill-line
#bindkey -M vicmd '/'     vi-history-search-forward
#bindkey -M vicmd '?'     vi-history-search-backward
#bindkey -M vicmd '^_'    undo
#bindkey -M vicmd '\ef'   forward-word                      # Alt-f
#bindkey -M vicmd '\eb'   backward-word                     # Alt-b
#bindkey -M vicmd '\ed'   kill-word                         # Alt-d
#bindkey -M vicmd '\e[5~' history-beginning-search-backward # PageUp
#bindkey -M vicmd '\e[6~' history-beginning-search-forward # PageDown

