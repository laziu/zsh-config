# sudo: Alt-S adds or removes sudo in front of the command line, like fish.

# Widget. On an empty line, recall the previous command first.
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  local cursor=$CURSOR
  if [[ $BUFFER == sudo\ * ]]; then
    BUFFER=${BUFFER#sudo }
    CURSOR=$(( cursor > 5 ? cursor - 5 : 0 ))
  else
    BUFFER="sudo $BUFFER"
    CURSOR=$(( cursor + 5 ))
  fi
}

zsh_bind '^[s' sudo-command-line 'toggle sudo (empty line: previous command)'
