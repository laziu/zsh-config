# Sourced by ~/.zshenv in every zsh, scripts included: keep it cheap.

zsh_config_dir=${${(%):-%x}:A:h:h}

# Debian/Ubuntu /etc/zsh/zshrc runs its own compinit unless this is set;
# plugins/completion.zsh runs a cached one, so skip the duplicate. No effect
# elsewhere.
skip_global_compinit=1

zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
zsh_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
zsh_state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
zsh_antidote_dir=$zsh_data_dir/antidote
# Where antidote clones plugins. Set here so the child zsh antidote starts for
# some commands sees it too.
ANTIDOTE_HOME=$zsh_cache_dir/antidote
