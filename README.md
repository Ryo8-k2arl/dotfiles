# dotfiles

Personal development environment managed by [chezmoi](https://www.chezmoi.io/), with host-specific configuration for Linux distributions and multiple machines.

## Highlights

- Chezmoi templates for host-specific Git, Hyprland, latexindent, and Zellij settings
- Bun and the JDKs required by the Android Gradle Plugin are managed by mise
- LazyVim configuration with Rust, Python, Kotlin, LaTeX, testing, and debugging support
- Zellij development workspace with Git worktree selection and one Neovim server per tab
- Source state isolated under `home/`; repository documentation is never deployed into `$HOME`
- Repeatable validation against an isolated temporary home

## Repository layout

```text
.
├── .chezmoiroot              # Selects home/ as the source-state root
├── .chezmoiversion           # Minimum supported chezmoi version
├── home/
│   ├── .chezmoi.toml.tmpl    # Per-host initialization prompts
│   ├── .chezmoiignore        # Conditional host exclusions
│   ├── .chezmoiscripts/      # Idempotent post-apply actions
│   ├── dot_config/           # Target: ~/.config
│   ├── dot_local/            # Target: ~/.local
│   └── dot_zshenv            # Target: ~/.zshenv
├── docs/
├── scripts/
└── Makefile
```

Chezmoi source attributes are encoded in filenames:

- `dot_foo` becomes `.foo`
- `executable_foo` is installed with executable permissions
- `private_foo` is installed without group/world permissions
- `*.tmpl` is rendered with host data
- `symlink_foo` creates a symbolic link

## Requirements

Install these with the current distribution's package manager:

- `git`
- `chezmoi >= 2.70`
- `zsh`
- `mise` (recommended; Bun and JDK installation is skipped when it is absent)

Mise is limited to Bun and the JDKs. The JDKs are an intentional exception: the
Android Gradle Plugin pins an exact toolchain version, and distribution packages
cannot be held at one. Neovim, Zellij, fzf, ghq, eza, delta, lazygit, starship,
Sheldon, TeX Live, Hyprland, fonts, and other system-integrated tools remain
distribution-managed.

The Android SDK is managed by neither: the official `android` CLI is its own
package manager, so a chezmoi script installs that CLI and lets it own the SDK
under `~/.local/share/android`.

On Linux, the native Codex and Claude Code CLIs are updated daily by systemd
user timers. Missed runs are triggered after the next login.

## Install on a new host

Install chezmoi, then initialize from GitHub:

```sh
chezmoi init --apply --ssh Ryo8-k2arl
```

During initialization, chezmoi asks for:

- host type: `desktop`, `laptop`, or `server`
- whether Hyprland configuration should be installed
- commands used by the Zellij file and Git panes

Defaults for the Zellij pane commands are `ft` and `keifu`. Enter alternatives available on that host when these custom tools are not installed.

Inspect before applying when setting up an important host:

```sh
chezmoi init --ssh Ryo8-k2arl
chezmoi diff
chezmoi apply
```

## Use this existing clone

```sh
chezmoi init --source "$PWD"
chezmoi diff --source "$PWD"
chezmoi apply --source "$PWD"
```

Equivalent Make targets are available:

```sh
make init
make diff
make apply
```

## Daily workflow

Edit source state and apply it:

```sh
chezmoi edit ~/.config/nvim/lua/config/options.lua
chezmoi diff
chezmoi apply
```

Import changes made directly to a managed target:

```sh
chezmoi re-add ~/.config/nvim/lua/config/options.lua
```

Pull the repository and apply changes:

```sh
chezmoi update
```

Machine-local values live in `~/.config/chezmoi/chezmoi.toml`, not in this repository. Run `chezmoi init --prompt` to update answers from `.chezmoi.toml.tmpl`.

Git identity is kept in the untracked, host-local file `~/.config/git/conf.d/user.local`. Chezmoi ensures that the file exists with private permissions but does not manage its contents.

## Validation

```sh
make check
```

The check renders the complete target state into a temporary home and validates:

- chezmoi templates and target paths
- file permissions and symlinks
- POSIX shell and Zsh syntax
- Lua and JSON syntax
- Git configuration includes
- Zellij configuration and the `dev` layout
- absence of hard-coded `/home/<user>` paths

## Documentation

- [Zellij development layout](docs/zellij.md)
- [LaTeX and LazyVim](docs/latex.md)
- [Android and Kotlin without Android Studio](docs/android.md)

## Local and private data

Git identity is not stored in this repository. The included `~/.config/git/conf.d/user.local` remains host-local; chezmoi only creates it when missing and enforces private permissions. Do not add credentials, histories, caches, or application state to `home/` unless they are intentionally templated or encrypted.

Before publishing changes, review both views:

```sh
git status --short
chezmoi diff
```
