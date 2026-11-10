#!/usr/bin/env zsh
# One-time setup of this zsh configuration on a machine. Safe to rerun.
#   - Links ~/.zshenv to the .zshenv next to this script.
#   - Clones antidote, the plugin manager; it fetches the plugins on the first
#     interactive shell.
#   - Installs mise, the tool manager, with its official installer if missing,
#     then the tools in mise.toml.
# Later updates: `antidote update` and `mise upgrade`; new shells say when
# updates exist.
emulate zsh
setopt err_exit pipe_fail no_unset

# Sets ZDOTDIR, MISE_GLOBAL_CONFIG_FILE and the zsh_*_dir layout.
source ${0:A:h}/.zshenv

missing=()
for cmd in git curl; do
  (( $+commands[$cmd] )) || missing+=($cmd)
done
if (( $#missing )); then
  print -u2 "install.zsh: required commands are missing: $missing"
  print -u2 "Install them first, e.g. 'sudo dnf install $missing' or 'sudo apt install $missing'."
  exit 1
fi

zshenv_link=$HOME/.zshenv
if [[ ! -e $zshenv_link && ! -L $zshenv_link ]]; then
  ln -s $ZDOTDIR/.zshenv $zshenv_link
  print "ok: linked ~/.zshenv -> $ZDOTDIR/.zshenv"
elif [[ ${zshenv_link:A} != $ZDOTDIR/.zshenv ]]; then
  print -u2 "warning: ~/.zshenv is not a link to $ZDOTDIR/.zshenv, so zsh will not load this setup."
  print -u2 "         Move it away (e.g. mv ~/.zshenv ~/.zshenv.bak) and run install.zsh again."
fi

if [[ ! -d $zsh_antidote_dir/.git ]]; then
  git clone --depth=1 --quiet https://github.com/mattmc3/antidote.git $zsh_antidote_dir
fi
print "ok: antidote in $zsh_antidote_dir"

mise=${commands[mise]:-$HOME/.local/bin/mise}
if [[ ! -x $mise ]]; then
  curl -fsSL https://mise.run | sh  # installs to ~/.local/bin/mise
fi
$mise install
print "ok: tools from mise.toml installed"
print "Done. Start a new login shell (exec zsh -l); the first start fetches the plugins."
