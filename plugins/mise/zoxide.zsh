# zoxide: jump to directories by a part of their path, ranked by use
# (mise.toml). Runs after compinit, which its `z` completion needs.
zsh_requires command zoxide || return
zsh_init_cache zoxide init zsh || return
source $REPLY

zsh_help 'z <part>' 'jump to the best-matching visited directory'
zsh_help 'zi <part>' 'pick among matching directories with fzf'
