# Zellij Development Layout

Git worktree や `ghq` のリポジトリごとに、エディタ、Git ツール、Agent、ターミナルをまとめた開発タブを作るための Zellij 設定です。

![Zellij development layout](./assets/zellij-dev-layout.png)

> Screenshot placeholder: `docs/assets/zellij-dev-layout.png`

## Layout

`dev.kdl` は、タブバーとステータスバーの間を次のように構成します。

```text
┌─────────────────────────────────────────────────────────────┐
│                         Tab bar                             │
├───────────────────┬─────────────────────────────────────────┤
│ File              │ Editor                                  │
│ (`ft`)            │ Neovim server for this Zellij tab       │
│                   ├─────────────────────────────────────────┤
│ Git               │ Agent                                   │
│ (`keifu`)         ├─────────────────────────────────────────┤
│                   │ Terminal                                │
├───────────────────┴─────────────────────────────────────────┤
│                       Status bar                            │
└─────────────────────────────────────────────────────────────┘
```

- 左側は `File` と `Git` の stacked pane
- 右側は `Editor`、`Agent`、`Terminal` の stacked pane
- 起動時のフォーカスは `Editor`
- `Editor` を終了しても Neovim が同じソケットで再起動
- タブごとに独立した Neovim server socket を使用

## Features

### Workspace picker

`Ctrl-t` → `n` で floating picker を開きます。

![Zellij workspace picker](./assets/zellij-workspace-picker.png)

> Screenshot placeholder: `docs/assets/zellij-workspace-picker.png`

picker には次の workspace が表示されます。

- 現在の Git repository に属する worktree
- `ghq list -p` で取得できる repository

worktree の preview には branch、変更状態、diff stat、最近の commit を表示します。通常の directory は `eza`、未導入の場合は `ls` で preview します。選択すると、その directory を作業ディレクトリにした `dev.kdl` の新しいタブが作られます。

### One Neovim server per tab

Neovim の socket は、Zellij の session name と tab ID から生成されます。

```text
${XDG_RUNTIME_DIR:-/tmp}/nvim-zellij-<uid>/nvim-<session>-<tab>.sock
```

これにより、`ft` など別 pane のツールから、同じタブの Neovim にファイルを送れます。

```sh
~/.config/zellij/scripts/zellij-nvim-open.sh path/to/file
```

この dotfiles では `FILETREE_DEFAULT_CMD` が同スクリプトを使うように設定されています。

### Session resurrection

`post_command_discovery_hook` は、復元対象の Neovim command（終了時に検出された `[nvim] <defunct>` を含む）を `zellij-nvim-editor.sh` に置き換えます。復元後も古い socket path を再利用せず、現在の session と tab に対応した Neovim server を起動できます。

## Requirements

| Command | Purpose | Required |
| --- | --- | :---: |
| `zellij` | Terminal workspace | Yes |
| `nvim` | Editor pane and remote editing | Yes |
| `fzf` | Workspace picker | Yes |
| `git` | Worktree discovery and preview | Yes |
| `ft` | File pane のデフォルト command | Configurable |
| `keifu` | Git pane のデフォルト command | Configurable |
| `ghq` | Repository discovery | Recommended |
| `eza` | Directory preview | Optional |

The current configuration is validated with Zellij `0.44.3`.

## Installation

chezmoi からリポジトリ全体を導入します。

```sh
chezmoi init --apply --ssh Ryo8-k2arl
```

初期化時に `Zellij file pane command` と `Zellij Git pane command` をホストごとに指定できます。デフォルトは `ft` と `keifu` です。

設定が読み込まれているか確認します。

```sh
zellij setup --check
```

## Usage

現在の directory で development layout を直接起動します。

```sh
zellij --layout dev
```

既存 session 内では workspace picker の利用を推奨します。

1. `Ctrl-t` で Tab mode に入る
2. `n` で workspace picker を開く
3. worktree または repository を選択する
4. 選択した workspace の development tab が作られる

通常の空タブが必要な場合は `Ctrl-t` → `p` を使います。

## Key bindings

### Direct bindings

| Key | Action |
| --- | --- |
| `Alt-h/j/k/l` | Pane 間を移動 |
| `Alt-n` | Pane を追加 |
| `Alt-f` | Floating pane の表示を切り替え |
| `Alt-+` / `Alt--` | Pane をリサイズ |
| `Alt-[` / `Alt-]` | Swap layout を切り替え |
| `Ctrl-g` | Locked mode を切り替え |
| `Ctrl-q` | Zellij を終了 |

### Mode prefixes

| Key | Mode |
| --- | --- |
| `Ctrl-t` | Tab mode |
| `Ctrl-p` | Pane mode |
| `Ctrl-n` | Resize mode |
| `Ctrl-h` | Move mode |
| `Ctrl-s` | Scroll mode |
| `Ctrl-o` | Session mode |
| `Ctrl-b` | tmux-compatible mode |

### Tab mode

| Key | Action |
| --- | --- |
| `n` | Workspace picker から development tab を作成 |
| `p` | 通常の空タブを作成 |
| `h` / `k` | 前のタブ |
| `j` / `l` | 次のタブ |
| `1` ... `9` | 指定番号のタブへ移動 |
| `r` | タブ名を変更 |
| `x` | タブを閉じる |
| `s` | Active sync tab を切り替え |

### Pane mode

| Key | Action |
| --- | --- |
| `h/j/k/l` | Focus を移動 |
| `d` / `r` | 下／右に pane を追加 |
| `s` | Stacked pane を追加 |
| `f` | Focus pane を fullscreen 化 |
| `w` | Floating pane を切り替え |
| `e` | Embedded / floating を切り替え |
| `c` | Pane 名を変更 |
| `x` | Focus pane を閉じる |

## Files

| Path | Role |
| --- | --- |
| `config.kdl` | Key bindings、plugin aliases、session resurrection hook |
| `layouts/dev.kdl` | Development tab の pane layout |
| `scripts/zellij-tab.sh` | Workspace の列挙、fzf 選択、新規タブ作成 |
| `scripts/zellij-tab-preview.sh` | Repository / directory preview |
| `scripts/zellij-nvim-editor.sh` | Tab 専用 Neovim server の起動と再起動 |
| `scripts/zellij-nvim-socket.sh` | Session / tab 固有 socket path の生成 |
| `scripts/zellij-nvim-open.sh` | 起動中の Neovim server へファイルを送信 |
| `scripts/zellij-resurrect-command.sh` | Session 復元時の Neovim command 置換 |

## Customization

### Pane commands

初回の `chezmoi init` で File pane と Git pane の command をホストごとに指定できます。後から変更する場合は `~/.config/chezmoi/chezmoi.toml` の `zellijFileCommand` と `zellijGitCommand` を編集し、`chezmoi apply` を実行します。

```toml
[data]
zellijFileCommand = "ft"
zellijGitCommand = "keifu"
```

### Workspace picker appearance

picker の色、border、preview 幅は `.config/fzf/config` の `FZF_ZELLIJ_WORKSPACE_OPTS` で変更できます。

## Troubleshooting

### Workspace picker does not open

```sh
command -v fzf git ghq
```

`fzf` は必須です。`ghq` がない場合、現在の repository の worktree だけが候補になります。

### File does not open in Neovim

Editor pane で Neovim server が起動していることを確認してから、次を実行します。

```sh
~/.config/zellij/scripts/zellij-nvim-socket.sh
~/.config/zellij/scripts/zellij-nvim-open.sh path/to/file
```

これらのスクリプトは Zellij session 内で実行する必要があります。

### Layout or config fails to load

```sh
zellij setup --check
```

KDL の parse error、設定ファイルの場所、利用中の Zellij version を確認できます。
