# updates: a daily background `install.zsh --check`; its result is shown once,
# above the first prompt of a later shell (zsh_notice).

zsh-update() {
  $zsh_config_dir/install.zsh "$@"
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
    { $zsh_config_dir/install.zsh --check >| $notice.new && mv -f $notice.new $notice } &>/dev/null &!
  fi
}

zsh_help 'zsh-update' 'update plugins, tools and ~/.zsh*'
