# syntax-highlighting: color the command line while typing.
zsh_requires plugin zsh-users/zsh-syntax-highlighting || return

# It re-highlights the whole line on every keystroke; skip very long buffers
# such as pastes. Read on every redraw.
ZSH_HIGHLIGHT_MAXLENGTH=512
