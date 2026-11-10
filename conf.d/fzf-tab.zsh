# fzf-tab: pick completion candidates with fzf.
zsh_requires plugin Aloxaf/fzf-tab || return

zstyle ':completion:*' menu no  # fzf-tab replaces the completion menu
zsh_help -k '^I' 'Tab' 'complete; pick candidates with fzf'
