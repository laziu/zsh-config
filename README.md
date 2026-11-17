# zsh-config

A fish-like zsh setup: autosuggestions, syntax highlighting, fzf completion and
history search, substring history on Up/Down, zoxide, pay-respects and the
powerlevel10k prompt. Plugins are managed by [antidote](https://antidote.sh) and
programs by [mise](https://mise.jdx.dev). The directory can live anywhere;
`~/.zshenv`, `~/.zprofile` and `~/.zshrc` load it.

## Layout

| Path | Contents |
| --- | --- |
| `install.zsh` | Install, update (`zsh-update`), `--check`, `--uninstall` |
| `plugins.txt` | Everything loaded at startup, in load order |
| `plugins/<name>.zsh` | A feature of this setup (`completion`, `sudo`, `help`, `updates`) |
| `plugins/antidote/<repo>.zsh` | Settings for a zsh plugin, loaded right after it |
| `plugins/mise/<tool>.zsh` | Shell integration of a program |
| `lib/env.zsh` | Environment for every zsh: this directory and the XDG paths |
| `lib/profile.zsh` | Login environment: `PATH`, editor, pager |
| `lib/init.zsh` | Interactive shell: zsh's own settings and keys, then `plugins.txt` |
| `lib/plugins.zsh` | Turns `plugins.txt` into one cached script (antidote's static mode) |
| `runcoms/` | The blocks `install.zsh` keeps in `~/.zshenv`, `~/.zprofile` and `~/.zshrc` |
| `functions/` | Helpers for `lib/`, `plugins/` and `install.zsh`, autoloaded |
| `completions/` | Hand-written completion files (`_command`) |

Outside this directory everything goes to XDG locations under a `zsh`
directory: generated files in `~/.cache/zsh` (plugin clones, the mise config,
caches), antidote in `~/.local/share/zsh`, history in `~/.local/state/zsh`.
mise keeps its programs in its own directory.

## plugins.txt

```
antidote:zsh-users/zsh-autosuggestions   # zsh plugin, then plugins/antidote/zsh-autosuggestions.zsh
mise:fzf                                 # program, then plugins/mise/fzf.zsh
sudo                                     # plugins/sudo.zsh
```

- **Order.** Entries load top to bottom, so the file shows what depends on
  what. For example, `completion` runs compinit after the entries that add
  completion directories, and before the ones that register completions.
- **Settings files.** A file under `plugins/` is only used when it exists.
  `<name>` is the last part of the repository or tool name. antidote
  annotations follow the repository (`antidote:owner/repo kind:defer`).
- **Programs.** `install.zsh` has mise install a `mise:` program only when no
  copy at least as new as mise's latest is already on `PATH`. Copies mise
  installs come first on `PATH`, so a program can still be updated without
  root rights. When the command has another name than the tool, add
  `bin:<command>` (`mise:ripgrep bin:rg`).
- **This machine.** `plugins.local.txt` (git-ignored) changes the list for one
  machine: `-<entry>` drops an entry (`-mise:zoxide`), and any other line is
  appended.

## Install

```sh
sudo dnf install -y zsh git curl      # or apt, brew, ...
git clone https://github.com/laziu/zsh-config.git ~/.config/zsh
~/.config/zsh/install.zsh
chsh -s "$(command -v zsh)"
```

`install.zsh` does three things:
- It writes this setup's block between `# >>> zsh-config: managed by install.zsh >>>` and
  `# <<< zsh-config <<<` in `~/.zshenv`, `~/.zprofile` and `~/.zshrc`. A file
  that exists without the block is left alone, with a warning. When one of
  them is a symlink, it stops without changing anything, since writing would
  change the link's target.
- It clones antidote.
- It installs mise if it is missing, then the programs.

The first interactive shell fetches the plugins and starts `p10k configure`,
which writes `.p10k.zsh` here (git-ignored, so each machine keeps its own prompt
style). Icons need a Nerd Font in the terminal app.

## Update

A shell checks once a day in the background (`install.zsh --check`) and prints
a notice above a later prompt when something is due. Then run `zsh-update`,
which runs `install.zsh` again:
- It refreshes the blocks.
- It runs `antidote update`.
- It decides again, for each program, between mise's copy and one already on
  `PATH`.
- It installs the latest version of the programs mise provides.
- It removes old versions, and the copies no longer needed. Versions that
  another mise config uses are kept.

The check also names `plugins.txt` entries that do not work, such as a feature
without its `plugins/` file or a program whose command needs `bin:<command>`.
`zsh-update` cannot fix those: correct the entry instead.

## Uninstall

```sh
~/.config/zsh/install.zsh --uninstall
rm -rf ~/.config/zsh
```

This removes:
- the blocks, or a whole `~/.zsh*` file when nothing else is left in it;
- `~/.cache/zsh` and antidote (`~/.local/share/zsh/antidote`; generated completions there are kept);
- after asking, powerlevel10k's caches.

The history and mise's programs are kept: `mise prune` deletes the programs no
other mise config uses. Deleting the directory alone is harmless too: the
blocks do nothing without it.

## Customize

- **Plugin, program or feature**:
  1. Add an entry to `plugins.txt` where it should load.
  2. If it needs settings, add the matching file under `plugins/`.
  3. Run `zsh-update` for a program. Plugins are fetched by the next shell.
- **This machine only**:
  - `plugins.local.txt`.
  - Lines after the block in `~/.zshrc`, which run last. There, `zsh_unbind <key>`
    removes a binding and its help line. The same goes for `~/.zprofile` and
    `~/.zshenv`.
- **Official installers** append their setup to `~/.zshenv` or `~/.zshrc`,
  after the block, outside this repository. rustup skips it because the
  `~/.zshenv` block already contains its line (in a comment). `lib/profile.zsh`
  puts `~/.cargo/bin` on `PATH`.
- **Completions**: generated completion files go to
  `~/.local/share/zsh/completions`
  (`tool completion zsh > ~/.local/share/zsh/completions/_tool`).

`h` (or Alt-H on an empty line) shows the keys and commands registered above.

## Conventions

**plugins/ files.** One file per entry, holding its settings, functions, key
bindings and cheat sheet lines. Each file is laid out as:

1. `# <name>: <purpose>`
2. For a program, its initialization, cached with `zsh_init_cache` and sourced
   at top level. `zsh_init_cache <command> ... || return` also skips the file
   when the program is missing. `install.zsh --check` reports a missing
   program.
3. Settings, then functions.
4. Registration: keys with `zsh_bind`, other usage with `zsh_help`. Both feed
   the cheat sheet; `zsh_unbind` removes a key together with its line.
   Messages above the prompt go through `zsh_notice`.

**functions/.** Helpers shared by `lib/` and `plugins/` files, one per file,
autoloaded. Each starts with a shebang, a usage comment and `emulate -L zsh`.

**Names.** As in zsh's own functions: widgets and commands to type are
kebab-case (`sudo-command-line`, `zsh-update`), internal functions and
variables snake_case. Shared names start with `zsh` (`zsh_bind`,
`zsh-notice-show`). A feature's names start with its file name
(`help_cheatsheet` and `help-or-cheatsheet` in `help.zsh`).

**Shebang.** zsh files without a `.zsh` extension (`functions/*`, `runcoms/*`)
start with `#!/usr/bin/env zsh` so editors detect the language.

## License

[MIT](LICENSE)
