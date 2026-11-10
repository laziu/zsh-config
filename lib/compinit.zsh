# Initialize the completion system once, after the plugins have added their
# completion directories to fpath and before conf.d registers completions
# (compdef). A second compinit would cost another ~9 ms and drop every
# completion registered in between. Sourced by .zshrc.

autoload -Uz compinit
() {
  # (#q) glob qualifiers require extended_glob; keep it local because it
  # changes the meaning of ^ and # in command-line patterns (e.g. HEAD^).
  setopt local_options extended_glob
  local dump=$zsh_cache_dir/zcompdump dir
  # Run the full check at most once a day, or right away when a completion
  # directory gained files (a new package or plugin): the fast path (-C) only
  # knows the completions recorded in the dump.
  local full=1
  [[ -n $dump(#qN.mh-24L+0) ]] && full=0  # non-empty and younger than a day
  for dir in $fpath; do
    [[ $dir -nt $dump ]] && full=1
  done
  if (( full )); then
    compinit -d $dump
    # compinit rewrites the dump only when completions change; refresh the
    # mtime so the next shells take the fast path. No dump means compinit
    # was aborted (e.g. at the insecure-directories prompt); retry next time.
    [[ -s $dump ]] && touch $dump
  else
    compinit -C -d $dump
  fi
}
