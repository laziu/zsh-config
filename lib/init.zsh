# Sourced by ~/.zshrc in interactive shells.

# Load order:
#   1. core: zsh's own features (below)
#   2. plugins.txt, top to bottom (lib/plugins.zsh)
#   3. aliases
# Conventions for plugins/, functions/ and names: README.md.

# zsh_*_dir variables come from lib/env.zsh.
[[ -d $zsh_cache_dir ]] || mkdir -p $zsh_cache_dir
[[ -d $zsh_state_dir ]] || mkdir -p $zsh_state_dir

# --- History: large and shared across sessions, like fish ---
HISTFILE=$zsh_state_dir/history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history extended_history hist_fcntl_lock
setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks

# --- Shell behavior ---
setopt interactive_comments
setopt no_flow_control  # free Ctrl-S/Ctrl-Q from terminal flow control

# --- Helpers shared by plugins/ files: one per file in functions/, loaded on first use ---
fpath=($zsh_config_dir/functions $fpath)
autoload -Uz $zsh_config_dir/functions/*(N:t)

# --- Keymap ---
# Choose it before any plugin binds keys: with EDITOR=vim zsh starts in vi
# mode, and switching later would drop those bindings. The keys themselves are
# bound below and in plugins/ (sudo, help and each plugin's file).
bindkey -e

# --- Directories ---
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent

zsh_help '<directory>' 'a bare directory name cds into it'
zsh_help 'cd -<Tab>' 'pick a recent directory'

# --- Line editor ---
# Home/End differ between terminals, application mode and tmux.
for key in '^[[H' '^[OH' '^[[1~'; do bindkey $key beginning-of-line; done
for key in '^[[F' '^[OF' '^[[4~'; do bindkey $key end-of-line; done
unset key
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

WORDCHARS=${WORDCHARS//\/}
autoload -Uz edit-command-line

zsh_help 'Ctrl-W' 'delete back to the previous word or /'
zsh_bind '^X^E' edit-command-line 'edit the command line in $EDITOR'

# --- Plugins (plugins.txt) ---
source $zsh_config_dir/lib/plugins.zsh

# --- Aliases (after plugins, so plugin code is not affected by them) ---
[[ $OSTYPE == linux* ]] && alias ls='ls --color=auto'  # macOS uses CLICOLOR instead
alias grep='grep --color=auto'
