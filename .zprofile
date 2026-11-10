#!/usr/bin/env zsh
# Login-shell environment. Read once per login (SSH, tmux panes, macOS
# terminals) and inherited by every child process, so keep only exports here.
# PATH lives here rather than in .zshenv because macOS /etc/zprofile
# (path_helper) runs after .zshenv and would reorder it.

typeset -U path PATH

# Homebrew on Apple Silicon macOS; skipped elsewhere.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Tools from mise.toml. mise keeps installs/<tool>/latest pointing at the
# newest installed version, so these entries never change. They replace mise's
# shims, which run mise itself on every call (~10 ms each, e.g. on every cd
# through zoxide). A tool installed after login appears in the next login shell.
path=(
  ~/.local/bin(N)
  ${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/installs/*/latest{,/bin}(N-/)
  ~/.cargo/bin(N)
  $path
)

# First installed editor in order of preference.
for EDITOR in nvim vim vi; do (( $+commands[$EDITOR] )) && break; done
export EDITOR VISUAL=$EDITOR
export PAGER=less
export LESS='-FiR'  # quit if one screen, smart-case search, pass colors through
export CLICOLOR=1   # colored ls on macOS/BSD; ignored by GNU ls
