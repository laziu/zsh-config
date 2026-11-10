# history-substring-search: Up/Down find history entries containing the typed
# text anywhere, like fish.
zsh_requires plugin zsh-users/zsh-history-substring-search || return

HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1  # read on every search
zsh_bind '^[[A' history-substring-search-up 'previous commands containing the typed text'
zsh_bind '^[OA' history-substring-search-up
zsh_bind '^[[B' history-substring-search-down 'next commands containing the typed text'
zsh_bind '^[OB' history-substring-search-down
