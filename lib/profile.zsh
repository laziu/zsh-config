# Sourced by ~/.zprofile once per login; children inherit it, so only exports.
# PATH is set here, not in env.zsh, because macOS /etc/zprofile reorders it.

typeset -U path PATH

# Homebrew on Apple Silicon macOS; skipped elsewhere.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

path=(
  ~/.local/bin(N)
  ~/.cargo/bin(N)
  $path
)

# mise: tools in plugins.txt that mise provides (install.zsh writes the list),
# first on PATH. mise keeps installs/<tool>/latest pointing at the newest
# installed version, so these entries never change. They replace mise's shims,
# which run mise itself on every call (~10 ms each, e.g. on every cd through
# zoxide). A tool installed after login appears in the next login shell.
[[ -r $zsh_cache_dir/mise-path.zsh ]] && source $zsh_cache_dir/mise-path.zsh

# First installed editor in order of preference.
for EDITOR in nvim vim vi; do (( $+commands[$EDITOR] )) && break; done
export EDITOR VISUAL=$EDITOR
export PAGER=less
export LESS='-FiR'  # quit if one screen, smart-case search, pass colors through
export CLICOLOR=1   # colored ls on macOS/BSD; ignored by GNU ls
