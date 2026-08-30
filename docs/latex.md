# LaTeX in Neovim

LazyVim の公式 TeX extra を基盤に、VimTeX、TexLab、latexmk、latexindent を使う設定です。PDF preview は将来ターミナル内に実装するため、現在は設定していません。

TexLab は補完、参照ジャンプ、診断、整形、保存時ビルドを担当します。VimTeX は Syntax Highlight、モーション、text object、環境操作などの LaTeX 固有の編集機能を担当します。ビルドの重複を避けるため VimTeX の compiler は無効です。

## 構成

| 展開先 | 役割 |
| --- | --- |
| `~/.config/nvim/lua/config/lazy.lua` | `lazyvim.plugins.extras.lang.tex` を静的に読み込む |
| `~/.config/nvim/after/lsp/texlab.lua` | TexLab の build と formatter 設定 |
| `~/.config/nvim/lua/plugins/lang/latex.lua` | VimTeX と TexLab の役割分担 |
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
| `<localleader>lb` | TexLab で一度だけビルド |
| `vim.lsp.buf.format()` | TexLab 経由で latexindent を実行 |

TexLab は保存時にビルドします。VimTeX の compiler、viewer、TexLab の forward search は無効なので、PDF に関する処理は起動しません。

## 補完と list 編集

TexLab の command、environment、citation、label、file 補完に加え、LuaSnip から friendly-snippets の LaTeX Workshop 互換 snippet を読み込みます。候補は入力中に自動表示され、選択すると説明も表示されます。展開後は `Tab` / `Shift-Tab` で placeholder 間を移動します。

代表的な snippet trigger:

| Trigger | 展開内容 |
| --- | --- |
| `BIT` / `BEN` | `itemize` / `enumerate` |
| `BEQ` / `BSEQ` | `equation` / `equation*` |
| `BAL` / `BSAL` | `align` / `align*` |
| `FIT` / `FBF` | `textit` / `textbf` |
| `@/` / `@2` | `frac` / `sqrt` |
| `fig` | figure、画像、caption、label |

行頭が `\item` または `\item[...]` の行で `Enter` を押すと、次の行にも同じ item prefix を挿入します。内容が空の item で `Enter` を押すと item を削除して継続を終了します。通常の改行を入れたい場合は `Alt-Enter` を使います。

`latexindent`は`tblr`、`longtblr`、`talltblr`、`spreadtab`を表として扱い、セル区切りの`&`と行末の`\\`を整列します。セル内の`{ ... }`はchild code blockとして保護するため、その中の`\\`は行末delimiterに含めません。

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

TexLab が main file を判定できない場合は、子ファイルの先頭付近に root directive を追加します。

```tex
% !TeX root = ../main.tex
```

## 確認

リポジトリ全体の構文、テンプレート展開、Zellij layout と LaTeX wrapper は次で検証できます。

```sh
make check
```
