# help: Alt-H and `h` show a command's manual, or this setup's cheat sheet
# (lines registered with zsh_help and zsh_bind).
# run-help backs both; zsh aliases it to plain man by default.
(( ${+aliases[run-help]} )) && unalias run-help
autoload -Uz run-help ${^fpath}/run-help-*(N:t)

# Print the cheat sheet, one section per group in registration order.
help_cheatsheet() {
  emulate -L zsh
  local group i
  for group in ${(u)zsh_help_groups}; do
    print -r -- $group
    for (( i = 1; i <= $#zsh_help_groups; i++ )); do
      [[ $zsh_help_groups[i] == $group ]] || continue
      printf '  %-16s %s\n' $zsh_help_labels[i] $zsh_help_texts[i]
    done
    print
  done
}

# Widget: help for the command being typed (its manual, zsh's own help for
# builtins, or the git/ip/sudo subcommand), like fish. On an empty line, print
# the cheat sheet instead.
help-or-cheatsheet() {
  if [[ -n $BUFFER ]]; then
    zle run-help
  else
    zle -I
    help_cheatsheet
  fi
}

# h                          print the cheat sheet
# h <command> [subcommand]   open help for command, like Alt-H on a typed line
h() {
  if (( ! $# )); then
    help_cheatsheet
    return
  fi
  # run-help reads subcommands from the line editor, which is empty when it
  # runs as a command, so call its per-command helper (run-help-git etc.).
  if (( $+functions[run-help-$1] )); then
    run-help-$1 ${@[2,-1]}
  else
    run-help $1
  fi
}

zsh_bind '^[h' help-or-cheatsheet 'this sheet; with a command typed, its manual'
zsh_bind '^[H' help-or-cheatsheet
zsh_help 'h [command]' 'this sheet, or the manual of command'
