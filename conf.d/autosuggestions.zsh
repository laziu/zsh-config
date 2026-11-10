# autosuggestions: grey inline suggestions from history and completion.
zsh_requires plugin zsh-users/zsh-autosuggestions || return

ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # read on every suggestion
zsh_help 'Right / Ctrl-F' 'accept the grey autosuggestion'
