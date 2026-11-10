# Load the plugins in .zsh_plugins.txt with antidote's static mode, as set up in
# antidote's README: antidote turns the list into a plain script of `source`
# lines, regenerated only when the list changes, and only that script runs at
# startup. Sourced by .zshrc.
#
# .zsh_plugins.local.txt (git-ignored) adjusts the list for this machine:
# a line `-owner/repo` drops that plugin, any other line is appended.
#
# Sets zsh_plugins_loaded and zsh_plugins_dropped (repo names) for
# zsh_requires, which conf.d files use to check their plugin.

fpath=($zsh_antidote_dir/functions $fpath)
autoload -Uz antidote                                    # antidote update, install, ...
zstyle ':antidote:bundle' file $ZDOTDIR/.zsh_plugins.txt # where `antidote install` adds
zstyle ':antidote:bundle:*' shallow yes                  # skip the background full-history fetch

() {
  local base=$ZDOTDIR/.zsh_plugins.txt extra=$ZDOTDIR/.zsh_plugins.local.txt
  local list=$zsh_cache_dir/plugins.txt static=$zsh_cache_dir/plugins.zsh
  # $list.local holds the plugins $extra drops. It exists only for a list
  # built with $extra, so deleting $extra rebuilds the list.
  local stale=0
  [[ $list -nt $base ]] || stale=1
  if [[ -e $extra ]]; then
    [[ $list -nt $extra && -e $list.local ]] || stale=1
  else
    [[ -e $list.local ]] && stale=1
  fi

  if (( stale )); then
    local -a lines=(${(f)"$(<$base)"}) added dropped
    local name
    if [[ -r $extra ]]; then
      added=(${(f)"$(<$extra)"})
      dropped=(${${(M)added:#-*}#-})
      added=(${added:#-*})
      for name in $dropped; do
        lines=(${lines:#${(b)name}(|[[:space:]]*)})
      done
      print -rl -- $dropped >| $list.local
    else
      rm -f $list.local
    fi
    print -rl -- $lines $added >| $list
  fi

  [[ $static -nt $list ]] || antidote bundle <$list >|$static

  # First word of each entry, skipping comments.
  typeset -ga zsh_plugins_loaded=(${${${(f)"$(<$list)"}:#\#*}%%[[:space:]]*})
  typeset -ga zsh_plugins_dropped=()
  [[ -e $list.local ]] && zsh_plugins_dropped=(${(f)"$(<$list.local)"})
}
source $zsh_cache_dir/plugins.zsh
