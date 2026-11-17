#!/usr/bin/env zsh
# One-time setup of this zsh configuration on a machine. Safe to rerun.
#   - Writes this setup's block into ~/.zshenv, ~/.zprofile and ~/.zshrc.
#   - Clones antidote, the plugin manager; it fetches the plugins on the first
#     interactive shell.
#   - Installs mise, the tool manager, with its official installer if missing,
#     then the mise: entries of plugins.txt.
# Later updates: `antidote update` and `mise -C ~/.cache/zsh upgrade`; new
# shells say when updates exist.
emulate zsh
setopt err_exit pipe_fail no_unset extended_glob

# Sets zsh_config_dir and the zsh_*_dir layout.
source ${0:A:h}/lib/env.zsh
fpath=($zsh_config_dir/functions $fpath)
autoload -Uz zsh_plugin_entries

ok()   { print -r -- "ok: $*" }
warn() { print -ru2 -- "warning: $*" }
die()  { print -ru2 -- "install.zsh: $*"; exit 1 }

missing=()
for cmd in git curl; do
  (( $+commands[$cmd] )) || missing+=($cmd)
done
if (( $#missing )); then
  print -u2 "install.zsh: required commands are missing: $missing"
  print -u2 "Install them first, e.g. 'sudo dnf install $missing' or 'sudo apt install $missing'."
  exit 1
fi

# --- ~/.zshenv, ~/.zprofile, ~/.zshrc ---
# Only the block between the markers belongs to this setup.

marker_begin='# >>> zsh-config: managed by install.zsh >>>'
marker_end='# <<< zsh-config <<<'

# runcom_block <name>: set REPLY to the block for ~/.<name>.
runcom_block() {
  local default='${XDG_CONFIG_HOME:-$HOME/.config}/zsh'
  local body=$(<$zsh_config_dir/runcoms/$1)
  body=${body#\#!*$'\n'}
  [[ $zsh_config_dir == ${${XDG_CONFIG_HOME:-$HOME/.config}/zsh:A} ]] ||
    body=${body//$default/${(D)zsh_config_dir}}
  REPLY=$marker_begin$'\n'$body$'\n'$marker_end
}

# runcoms <install|check|uninstall>: write, compare or remove the blocks;
# check prints the files whose block is out of date.
runcoms() {
  local name file content updated
  # Writing through a link would change its target instead, such as a file
  # in a dotfiles repository.
  if [[ $1 != check ]]; then
    for name in zshenv zprofile zshrc; do
      file=~/.$name
      [[ -L $file ]] &&
        die "${(D)file} is a symlink to $(readlink $file). Replace it with a regular file, then run install.zsh again."
    done
  fi
  for name in zshenv zprofile zshrc; do
    file=~/.$name
    runcom_block $name
    content=
    [[ -r $file ]] && content=$(<$file)
    if [[ $content == *$marker_begin*$marker_end* ]]; then
      updated=${content%%$marker_begin*}$REPLY${content#*$marker_end}
      [[ $1 == uninstall ]] && updated=${content%%$marker_begin*}${${content#*$marker_end}##$'\n'#}
    elif [[ $1 == install && ! -e $file ]]; then
      updated=$REPLY
    else
      [[ $1 == install ]] &&
        warn "${(D)file} has no zsh-config block. Move it away (mv ${(D)file}{,.bak}) and run install.zsh again."
      continue
    fi
    [[ $updated == $content ]] && { [[ $1 == install ]] && ok "${(D)file} is up to date"; continue }
    case $1 in
      (check) print -r -- ${(D)file} ;;
      (install) print -r -- $updated >| $file && ok "${(D)file}: block written" ;;
      (uninstall)
        if [[ $updated == [[:space:]]# ]]; then
          rm $file && ok "removed ${(D)file}"
        else
          print -r -- $updated >| $file && ok "${(D)file}: block removed, the rest kept"
        fi ;;
    esac
  done
}

runcoms install

if [[ ! -d $zsh_antidote_dir/.git ]]; then
  git clone --depth=1 --quiet https://github.com/mattmc3/antidote.git $zsh_antidote_dir
fi
print "ok: antidote in $zsh_antidote_dir"

mise=${commands[mise]:-$HOME/.local/bin/mise}
if [[ ! -x $mise ]]; then
  curl -fsSL https://mise.run | sh  # installs to ~/.local/bin/mise
fi
# A config of its own leaves the user's mise config alone.
zsh_plugin_entries
tools=(${${${(M)reply:#mise:*}%% *}#mise:})
mise_config=$zsh_cache_dir/mise.toml
mkdir -p $zsh_cache_dir
{
  print "[tools]"
  for tool in $tools; do print -r -- "\"$tool\" = \"latest\""; done
} >| $mise_config
$mise trust --quiet $mise_config
$mise -C $zsh_cache_dir install
print "ok: tools from plugins.txt installed"
print "Done. Start a new login shell (exec zsh -l); the first start fetches the plugins."
