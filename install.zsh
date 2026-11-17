#!/usr/bin/env zsh
# One-time setup of this zsh configuration on a machine. Safe to rerun.
#   - Writes this setup's block into ~/.zshenv, ~/.zprofile and ~/.zshrc.
#   - Clones antidote, the plugin manager; it fetches the plugins on the first
#     interactive shell.
#   - Installs mise, the tool manager, with its official installer if missing,
#     then the mise: entries of plugins.txt that are missing from PATH or
#     older there than mise's latest.
# Later updates: `antidote update` and `mise -C ~/.cache/zsh upgrade`; new
# shells say when updates exist.
emulate zsh
setopt pipe_fail no_unset extended_glob

# Sets zsh_config_dir and the zsh_*_dir layout.
source ${0:A:h}/lib/env.zsh
fpath=($zsh_config_dir/functions $fpath)
autoload -Uz zsh_plugin_entries is-at-least

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
  git clone --depth=1 --quiet https://github.com/mattmc3/antidote.git $zsh_antidote_dir ||
    die "cloning antidote failed"
fi
print "ok: antidote in $zsh_antidote_dir"

# --- mise tools ---
# mise provides a tool only where no copy at least as new as mise's latest is
# already on PATH; lib/profile.zsh puts the ones it provides first.

mise=${commands[mise]:-$HOME/.local/bin/mise}
if [[ ! -x $mise ]]; then
  curl -fsSL https://mise.run | sh || die "installing mise failed"  # installs to ~/.local/bin/mise
fi
mise_config=$zsh_cache_dir/mise.toml
mise_path=$zsh_cache_dir/mise-path.zsh

# configured_tools: set reply to the tools in $mise_config.
configured_tools() {
  reply=()
  [[ -r $mise_config ]] || return 0
  local line
  for line in ${(M)${(f)"$(<$mise_config)"}:#\"*\" = *}; do
    reply+=(${(Q)line%% = *})
  done
}

# version_of <text>: set REPLY to the first version number in its first line.
version_of() {
  REPLY=${${${1%%$'\n'*}##[^0-9]#}%%[^0-9.]*}
}

# user_copy <command>: set REPLY to the first <command> on PATH that is not
# one of mise's installs/<tool>/latest directories.
user_copy() {
  local installs=${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/installs
  local dir
  for dir in $path; do
    [[ $dir == $installs/*/latest(|/bin) ]] && continue
    [[ -f $dir/$1 && -x $dir/$1 ]] && { REPLY=$dir/$1; return 0 }
  done
  return 1
}

# tools_plan: decide which mise: entries mise provides. Sets, as globals,
# tools and bins (each tool's command), configured (the tools in $mise_config),
# keep (the tools mise is to provide) and note (why, by tool). An unreadable
# version counts as older; without mise's latest (offline) the current
# decision stands.
tools_plan() {
  local entry tool bin user latest
  typeset -ga tools bins configured keep
  typeset -gA note
  tools=() bins=() keep=() note=()
  configured_tools
  configured=($reply)
  zsh_plugin_entries
  for entry in ${(M)reply:#mise:*}; do
    tool=${${entry%% *}#mise:}
    bin=${${(M)${(s: :)entry}:#bin:*}#bin:}
    bin=${bin:-${tool##*[:/]}}
    tools+=($tool) bins+=($bin)
    if ! user_copy $bin; then
      keep+=($tool)
      continue
    fi
    user=$REPLY
    version_of "$($user --version </dev/null 2>&1)"
    note[$tool]="$user ${REPLY:-(version unknown)}"
    latest=$($mise latest $tool 2>/dev/null)
    if [[ -z $latest ]]; then
      warn "$tool: could not get mise's latest version, so the current choice stays. Run install.zsh again when online."
      if (( $configured[(Ie)$tool] )); then
        keep+=($tool)
        note[$tool]="mise's latest unknown; $user is ${note[$tool]#* }"
      else
        note[$tool]="using ${note[$tool]} (mise's latest unknown)"
      fi
    elif [[ -n $REPLY ]] && is-at-least $latest $REPLY; then
      note[$tool]="using ${note[$tool]}, as new as mise's $latest"
    else
      keep+=($tool)
      note[$tool]="newer than ${note[$tool]}"
    fi
  done
}

# tool_dir <tool> <command>: set reply to the directory of mise's <tool> that
# holds <command> and the installed version. The directory goes through
# installs/<tool>/latest, which follows upgrades. Returns 1 when <command> is
# not there, 2 when <tool> is not installed.
tool_dir() {
  local where dir
  where=$($mise -C $zsh_cache_dir where $1 2>/dev/null) || return 2
  dir=${where:h}/latest
  [[ -d $dir ]] || dir=$where
  [[ -x $dir/$2 ]] || dir=$dir/bin
  reply=($dir ${where:t})
  [[ -x $dir/$2 ]]
}

tools_sync() {
  local -a entries
  local tool bin
  tools_plan
  for tool in ${tools:|keep}; do
    ok "$tool: $note[$tool]"
  done

  # A config of its own leaves the user's mise config alone, and mise tracks
  # it, so `mise prune` keeps these tools.
  mkdir -p $zsh_cache_dir
  {
    print "[tools]"
    for tool in $keep; do print -r -- "\"$tool\" = \"latest\""; done
  } >| $mise_config
  $mise trust --quiet $mise_config || die "mise trust failed"
  if (( $#keep )); then
    $mise -C $zsh_cache_dir install ${^keep}@latest || die "mise install failed"
  fi

  for tool in $keep; do
    bin=$bins[$tools[(Ie)$tool]]
    tool_dir $tool $bin
    case $? in
      (2) die "mise where $tool failed" ;;
      (1) warn "$tool installs no '$bin' command; name it with bin:<command> in plugins.txt"
          continue ;;
    esac
    entries+=($reply[1])
    ok "$tool $reply[2] from mise${note[$tool]:+, $note[$tool]}"
  done
  print -r -- "path=(${(j: :)${(@qq)entries}} \$path)" >| $mise_path

  # Removes old versions and tools no longer provided, except versions that
  # another mise config uses.
  $mise prune --tools --yes --quiet ${(u)tools} ${(u)configured} >/dev/null ||
    warn "mise prune failed"
  rm -rf $zsh_cache_dir/init  # zsh_init_cache output of replaced binaries
}

tools_sync
print "Done. Start a new login shell (exec zsh -l); the first start fetches the plugins."
