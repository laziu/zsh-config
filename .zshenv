#!/usr/bin/env zsh
# Read by every zsh, including scripts; keep it cheap.
# ~/.zshenv is a symlink to this file (created by install.zsh), so this
# directory can live anywhere, e.g. as a git checkout.

# Read the other startup files from the directory this file really lives in.
export ZDOTDIR=${${(%):-%x}:A:h}

# The binary tools (fzf, zoxide, ...) are declared next to this file, so every
# machine with this checkout installs the same set.
export MISE_GLOBAL_CONFIG_FILE=$ZDOTDIR/mise.toml

# Debian/Ubuntu /etc/zsh/zshrc runs its own compinit unless this is set;
# lib/compinit.zsh runs a cached one, so skip the duplicate. No effect elsewhere.
skip_global_compinit=1

# Directory layout shared by .zshrc, lib/, conf.d/ and install.zsh, following
# the XDG base directory spec so nothing but ~/.zshenv lands in $HOME.
zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
zsh_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
zsh_state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
zsh_antidote_dir=$zsh_data_dir/antidote
