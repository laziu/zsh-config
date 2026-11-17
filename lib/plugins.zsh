# Turns plugins.txt into antidote's bundle list, and that into one static
# script, rebuilt only when the inputs change.

fpath=($zsh_antidote_dir/functions $fpath)
autoload -Uz antidote                                    # antidote update, install, ...
zstyle ':antidote:bundle:*' shallow yes                  # skip the background full-history fetch
zstyle ':antidote:bundle:*' zcompile yes                 # compile the cloned plugins' files
zstyle ':antidote:bundle:/*' zcompile no                 # local files: no .zwc in this directory

() {
  local list=$zsh_cache_dir/plugins.txt static=$zsh_cache_dir/plugins.zsh
  # Shells started together (e.g. tmux panes) may all rebuild at once, so each
  # writes under a name of its own and renames when done.
  local tmp=$zsh_cache_dir/plugins.$$
  local dir=$zsh_config_dir/plugins input stale=0
  # Directory mtimes catch added or removed files, plugins.local.txt included.
  # A missing $ANTIDOTE_HOME (clones deleted) also counts as stale.
  for input in $zsh_config_dir{,/plugins.txt,/plugins.local.txt(N)} $dir{,/antidote,/mise}(N/) $ANTIDOTE_HOME; do
    [[ $static -nt $input ]] || stale=1
  done
  (( stale )) || return 0

  local entry word
  local -a lines
  zsh_plugin_entries
  for entry in $reply; do
    word=${entry%% *}
    [[ $word == antidote:* ]] && lines+=(${entry#antidote:})
    if zsh_plugin_file $word; then
      lines+=($REPLY)
    elif [[ $word != *:* ]]; then
      zsh_notice "zsh: plugins.txt: '$word' has no plugins/$word.zsh"
    fi
  done
  print -rl -- $lines >| $tmp.txt
  mv -f $tmp.txt $list
  # On failure (e.g. offline) keep the previous script.
  antidote bundle <$list >| $tmp.zsh || { rm -f $tmp.zsh; return 1 }
  mv -f $tmp.zsh $static
  # Compiled under the script's own name, which source looks up in the .zwc.
  zcompile $tmp.zwc $static
  mv -f $tmp.zwc $static.zwc
}
[[ -r $zsh_cache_dir/plugins.zsh ]] && source $zsh_cache_dir/plugins.zsh
