# fzf: fuzzy pickers for history, files and directories (mise.toml).
zsh_requires command fzf || return
zsh_init_cache fzf --zsh || return
source $REPLY
# fzf just bound Tab (main keymap) to its `**` completion, over fzf-tab, which
# loaded earlier as a plugin. Give Tab back: fzf-tab already picks any
# completion with fzf.
(( $+widgets[fzf-tab-complete] )) && bindkey '^I' fzf-tab-complete

zsh_help -k '^R' 'Ctrl-R' 'search all history with fzf'
zsh_help -k '^T' 'Ctrl-T' 'insert file paths picked with fzf'
zsh_help -k '^[c' 'Alt-C' 'cd into a subdirectory picked with fzf'
