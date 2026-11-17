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
    # A name of its own per shell; a check that cannot run says so instead
    # of leaving the notice empty for a day.
    {
      if $zsh_config_dir/install.zsh --check >| $notice.$$; then
        mv -f $notice.$$ $notice
      else
        rm -f $notice.$$
        print -r -- "zsh: the daily update check failed; run ${(D)zsh_config_dir}/install.zsh --check" >| $notice
      fi
    } &>/dev/null &!
  fi
}

zsh_help 'zsh-update' 'update plugins, tools and ~/.zsh*'
