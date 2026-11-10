# zsh-config

A fish-like zsh setup: autosuggestions, syntax highlighting, fzf completion and
history search, substring history on Up/Down, zoxide, pay-respects and the
powerlevel10k prompt. Plugins are managed by [antidote](https://antidote.sh) and
binary tools by [mise](https://mise.jdx.dev). The directory can live anywhere;
`~/.zshenv` links to it.

## Layout

| Path | Contents |
| --- | --- |
| `.zshenv` | `ZDOTDIR` (this directory), XDG paths, mise config location |
| `.zprofile` | Login environment: `PATH` (including mise tools), editor, pager |
| `.zshrc` | Core zsh settings and the load order (described at the top of the file) |
| `.zsh_plugins.txt` | zsh plugins, in load order (antidote) |
| `mise.toml` | Binary tools (mise) |
| `conf.d/<name>.zsh` | One feature (a plugin, a tool or a built-in feature such as `editor`, `sudo`, `help`): its settings, functions, keys and cheat sheet lines |
| `lib/` | Plugin loading and compinit, sourced by `.zshrc` |
| `functions/` | Helpers shared by `conf.d` files: `zsh_requires`, `zsh_bind`, `zsh_help`, `zsh_unbind`, `zsh_init_cache`, `zsh_notice` |
| `completions/` | Hand-written completion files (`_command`) |
| `install.zsh` | One-time setup per machine |

Generated files stay outside this directory: plugins in `~/.cache/antidote`,
tools in `~/.local/share/mise`, caches in `~/.cache/zsh`, history in
`~/.local/state/zsh`.

## Install

```sh
sudo dnf install -y zsh git curl      # or apt, brew, ...
git clone https://github.com/laziu/zsh-config.git ~/.config/zsh
~/.config/zsh/install.zsh
chsh -s "$(command -v zsh)"
```

The first interactive shell fetches the plugins and starts `p10k configure`,
which writes `.p10k.zsh` here (git-ignored, so each machine keeps its own prompt
style). Icons need a Nerd Font in the terminal app.

## Update

A shell checks for updates at most once a day in the background and prints a
notice above a later prompt. Then run:

```sh
antidote update   # plugins and antidote
mise upgrade      # tools
```

## Customize

- **Plugin**: add a line to `.zsh_plugins.txt` (or `antidote install owner/repo`)
  and, if it needs settings, a `conf.d/<name>.zsh`.
- **Tool**: `mise use -g <tool>@latest` adds it to `mise.toml`; add a `conf.d/<tool>.zsh`
  for shell integration. Tools appear on `PATH` in the next login shell.
- **conf.d file**: see [Conventions](#conventions); the existing files follow them.
- **This machine only** (both files are git-ignored):
  - `.zsh_plugins.local.txt`: `-owner/repo` drops a plugin, other lines are appended.
  - `.zshrc.local`: runs last; `zsh_unbind <key>` removes a binding and its help line.
- **Completions**: generated completion files go to `~/.local/share/zsh/completions`
  (`tool completion zsh > ~/.local/share/zsh/completions/_tool`).

`h` (or Alt-H on an empty line) shows the keys and commands registered above.

## Conventions

**conf.d files.** One file per feature: a plugin, a tool or a built-in feature.
It holds the feature's settings, functions, key bindings and cheat sheet lines,
and runs after the plugins and compinit (load order: top of `.zshrc`). The files
do not depend on each other's order. Each file is laid out as:

1. `# <name>: <purpose>`
2. for a plugin or a command, `zsh_requires plugin <owner/repo> || return` or
   `zsh_requires command <name> || return`: when it is missing, the file is
   skipped and a warning appears above the prompt of every shell
3. tool initialization, cached with `zsh_init_cache` and sourced at top level
4. settings, then functions
5. registration and startup actions: keys with `zsh_bind`, other usage with
   `zsh_help` (both feed the cheat sheet; `zsh_unbind` removes a key with its
   line), messages above the prompt with `zsh_notice`

**functions/.** Only helpers shared by conf.d files, one per file, autoloaded.
Each starts with a shebang, a usage comment and `emulate -L zsh`.

**Names.** As in zsh's own functions: widgets and commands to type are
kebab-case (`sudo-command-line`, `h`), internal functions and variables
snake_case. Shared names start with `zsh` (`zsh_bind`, `zsh-notice-show`); a
feature's names start with its file name (`help_cheatsheet` and
`help-or-cheatsheet` in `help.zsh`).

**Shebang.** zsh files without a `.zsh` extension (`.zshrc`, `functions/*`, ...)
start with `#!/usr/bin/env zsh` so editors detect the language.

## License

[MIT](LICENSE)
