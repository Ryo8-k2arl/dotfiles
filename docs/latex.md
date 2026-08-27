# LaTeX in Neovim

LazyVim の公式 TeX extra を基盤に、TexLab、latexmk、latexindent を使う設定です。PDF viewer は設定していません。

## 構成

| 展開先 | 役割 |
| --- | --- |
| `~/.config/nvim/lua/config/lazy.lua` | `lazyvim.plugins.extras.lang.tex` を静的に読み込む |
| `~/.config/nvim/after/lsp/texlab.lua` | TexLab の build と formatter 設定 |
| `~/.config/nvim/lua/plugins/lang/latex.lua` | VimTeX と LaTeX 用 keymap |
| `~/.config/nvim/lua/plugins/lsp/mason.lua` | `texlab` と `latexindent` を導入 |
| `~/.config/latexindent/settings.yaml` | latexindent の整形規則 |
| `~/.local/bin/latexindent` | Mason 版 latexindent の wrapper |

chezmoi のソースは、それぞれ `home/dot_config/` と `home/dot_local/` 以下にあります。

## 必要なコマンド

- `nvim`
- `latexmk`
- TeX Live などの LaTeX 環境

`texlab` と `latexindent` は Mason が管理します。Neovim で次を実行すると状態を確認できます。

```vim
:Mason
:LspInfo
:checkhealth vimtex
```

## 操作

LaTeX buffer では LazyVim/VimTeX の標準操作に加えて、次の設定を利用できます。

| 操作 | 用途 |
| --- | --- |
| `:VimtexCompile` | latexmk による継続コンパイルの開始・停止 |
| `:VimtexStop` | コンパイルを停止 |
| `:VimtexClean` | 生成物を削除 |
| `vim.lsp.buf.format()` | TexLab 経由で latexindent を実行 |

TexLab の保存時ビルドと forward search は無効です。PDF viewer と forward search は、利用するデスクトップ環境ごとに別途設定してください。

## latexindent の生成物

wrapper は、編集中のディレクトリを汚さないようにログとバックアップを XDG state/cache 配下へ移動します。

```text
${XDG_STATE_HOME:-~/.local/state}/latexindent/
${XDG_CACHE_HOME:-~/.cache}/latexindent/
```

実体は Mason が配置した次のコマンドです。

```text
${XDG_DATA_HOME:-~/.local/share}/nvim/mason/bin/latexindent
```

別の実体を使う場合は `LATEXINDENT_BIN` を設定できます。

## 複数ファイルのプロジェクト

TexLab と VimTeX が main file を判定できない場合は、子ファイルの先頭付近に root directive を追加します。

```tex
% !TeX root = ../main.tex
```

## 確認

リポジトリ全体の構文、テンプレート展開、Zellij layout と LaTeX wrapper は次で検証できます。

```sh
make check
```
