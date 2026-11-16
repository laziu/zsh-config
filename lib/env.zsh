# Sourced by ~/.zshenv in every zsh, scripts included: keep it cheap.

zsh_config_dir=${${(%):-%x}:A:h:h}

# The binary tools (fzf, zoxide, ...) are declared next to this file, so every
# machine with this checkout installs the same set.
export MISE_GLOBAL_CONFIG_FILE=$zsh_config_dir/mise.toml

# Debian/Ubuntu /etc/zsh/zshrc runs its own compinit unless this is set;
# lib/compinit.zsh runs a cached one, so skip the duplicate. No effect elsewhere.
skip_global_compinit=1

zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
zsh_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
zsh_state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
zsh_antidote_dir=$zsh_data_dir/antidote
