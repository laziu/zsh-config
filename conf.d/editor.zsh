# editor: line editor keys. The emacs keymap is chosen in .zshrc, before the
# plugins load.

# Home/End differ between terminals, application mode and tmux.
for key in '^[[H' '^[OH' '^[[1~'; do bindkey $key beginning-of-line; done
for key in '^[[F' '^[OF' '^[[4~'; do bindkey $key end-of-line; done
unset key
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

WORDCHARS=${WORDCHARS//\/}
autoload -Uz edit-command-line

zsh_help 'Ctrl-W' 'delete back to the previous word or /'
zsh_bind '^X^E' edit-command-line 'edit the command line in $EDITOR'
