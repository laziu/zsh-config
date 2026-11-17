# updates: daily background check for plugin and tool updates. A shell started
# after the check shows the result once, above its first prompt (zsh_notice).

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
    { $zsh_config_dir/install.zsh --check >| $notice.new && mv -f $notice.new $notice } &>/dev/null &!
  fi
}
