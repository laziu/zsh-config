# updates: daily background check for plugin and tool updates. A shell started
# after the check shows the result once, above its first prompt (zsh_notice).

# updates_check <file>
# Compare installed plugins (antidote) and tools (mise) with upstream and write
# a one-line notice to <file>, empty when everything is current.
updates_check() {
  emulate -L zsh
  local out=$1 dir head remote
  local -a outdated_tools parts
  local -i plugins=0
  for dir in $zsh_antidote_dir ${(f)"$(antidote list --dirs 2>/dev/null)"}; do
    head=$(git -C $dir rev-parse HEAD 2>/dev/null) || continue
    remote=$(git -C $dir ls-remote origin HEAD 2>/dev/null) || continue
    [[ ${remote%%[[:space:]]*} == $head ]] || (( ++plugins ))
  done
  (( $+commands[mise] )) && outdated_tools=(${(f)"$(mise outdated --no-header 2>/dev/null)"})
  (( plugins )) && parts+=("$plugins plugin(s): antidote update")
  (( $#outdated_tools )) && parts+=("$#outdated_tools tool(s): mise upgrade")
  if (( $#parts )); then
    print -r -- "zsh: updates available: ${(j:; :)parts}" >| $out.tmp
  else
    : >| $out.tmp
  fi
  mv -f $out.tmp $out
}

() {
  setopt local_options extended_glob
  local notice=$zsh_cache_dir/updates shown=$zsh_cache_dir/updates.shown
  local stamp=$zsh_cache_dir/updates.checked
  # Show the last result unless already shown. zsh's -nt is false when $shown
  # does not exist yet, hence the -e test.
  if [[ -s $notice && ( ! -e $shown || $notice -nt $shown ) ]]; then
    zsh_notice -m $shown "$(<$notice)"
  fi
  if [[ -z $stamp(#qN.mh-24) ]]; then
    : >| $stamp
    updates_check $notice &>/dev/null &!
  fi
}
