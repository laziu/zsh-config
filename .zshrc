#!/usr/bin/env zsh
# Powerlevel10k instant prompt. Keep this block at the top; anything that reads
# console input (password or [y/n] prompts) must go above it.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load order:
#   1. core: zsh's own features (below)
#   2. plugins from .zsh_plugins.txt, via antidote (lib/plugins.zsh)
#   3. compinit, after plugins have added their completion dirs (lib/compinit.zsh)
#   4. conf.d/*.zsh, one file per feature, after everything they configure exists
#   5. aliases
#   6. machine-specific overrides and the prompt configuration
# Conventions for conf.d, functions/ and names: README.md.

# zsh_*_dir variables come from .zshenv.
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

# --- Helpers shared by conf.d files: one per file in functions/, loaded on first use ---
fpath=($ZDOTDIR/functions $fpath)
autoload -Uz $ZDOTDIR/functions/*(N:t)

# --- Keymap ---
# Choose it before any plugin binds keys: with EDITOR=vim zsh starts in vi
# mode, and switching later would drop those bindings. The keys themselves are
# bound in conf.d (editor, sudo, help and each plugin's file).
bindkey -e

# --- Completion styles (compinit itself runs after the plugins) ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $zsh_cache_dir/zcompcache
# Completion files outside plugins, highest priority first:
#   $ZDOTDIR/completions        hand-written ones (_mytool)
#   $zsh_data_dir/completions   generated ones: `tool completion zsh > _tool`
#                               there instead of eval-ing it on every startup
fpath=($ZDOTDIR/completions(N) $zsh_data_dir/completions(N) $fpath)

# --- Plugins, then compinit ---
source $ZDOTDIR/lib/plugins.zsh
source $ZDOTDIR/lib/compinit.zsh

# --- Features (conf.d) ---
# Sourced at top level, not in a function, so their globals stay global.
for zsh_conf in $ZDOTDIR/conf.d/*.zsh(N); do
  source $zsh_conf
done
unset zsh_conf

# --- Aliases (after plugins, so plugin code is not affected by them) ---
[[ $OSTYPE == linux* ]] && alias ls='ls --color=auto'  # macOS uses CLICOLOR instead
alias grep='grep --color=auto'

# Machine-specific settings, last so they win (git-ignored). zsh_unbind drops a
# key binding together with its cheat sheet line.
[[ -r $ZDOTDIR/.zshrc.local ]] && source $ZDOTDIR/.zshrc.local

# Written in the form `p10k configure` recognizes; otherwise it appends its own copy.
[[ ! -f ${ZDOTDIR:-~}/.p10k.zsh ]] || source ${ZDOTDIR:-~}/.p10k.zsh
