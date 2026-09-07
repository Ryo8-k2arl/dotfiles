# Agent skills の共有

Claude Code、Codex CLI、Gemini CLI はいずれも `<agent home>/skills/<name>/SKILL.md` を user scope の skill として読み込み、いずれもシンボリックリンクをたどります。そこで skill の実体は `~/.config/agent-skills` に1つだけ置き、各 agent の skills ディレクトリへリンクを張ります。編集は1箇所で済み、ホスト間の同期は `chezmoi apply` が担当します。

skill そのものは agent 非依存の Markdown なので、この方式で共有できます。hook、command、MCP server を持つ plugin はリンクでは登録できないため、各 agent の CLI で導入します。

## 構成

| 展開先 | 役割 |
| --- | --- |
| `~/.config/agent-skills/<name>/SKILL.md` | skill の実体。chezmoi のソースは `home/dot_config/agent-skills/` |
| `~/.claude/skills/<name>` | Claude Code 向けのリンク |
| `~/.codex/skills/<name>` | Codex CLI 向けのリンク |
| `~/.gemini/skills/<name>` | Gemini CLI 向けのリンク |

リンクは `home/.chezmoiscripts/run_after_35-link-agent-skills.sh` が apply ごとに張り直します。ディレクトリごとリンクにするのではなく skill ごとにリンクを作るのは、Codex が `~/.codex/skills/.system` に組み込み skill を置いており、ディレクトリ単位のリンクではそれが隠れるためです。

スクリプトの動作は次の3点です。

- `~/.config/agent-skills` 配下で `SKILL.md` を持つディレクトリだけをリンクする
- `~/.config/agent-skills` を指す壊れたリンクだけを削除する。agent 自身が入れた skill には触れない
- インストールされていない agent の home は作らない

同名の実ディレクトリが agent 側にある場合は、上書きせずに警告して飛ばします。

## 自作 skill を追加する

`home/dot_config/agent-skills/<name>/SKILL.md` を作り、apply します。

```sh
mkdir -p home/dot_config/agent-skills/paper-review
$EDITOR home/dot_config/agent-skills/paper-review/SKILL.md
chezmoi apply --source "$PWD"
```

`SKILL.md` の frontmatter は3つの agent で共通です。

```markdown
---
name: paper-review
description: 何をする skill で、いつ使うのかを1文で書く。agent はこの description だけを見て起動を判断する。
---
```

補助ファイル（`references/`、`scripts/`、`assets/`）は同じディレクトリに置けば、リンク経由でそのまま参照できます。

## 他人の skill を取り込む

リポジトリにコピーせず、`home/.chezmoiexternal.toml` で ref を固定して取得します。更新は `refreshPeriod` と `chezmoi update` に任せます。

```toml
[".config/agent-skills/<name>"]
    type = "archive"
    url = "https://github.com/<owner>/<repo>/archive/refs/tags/v1.2.3.tar.gz"
    stripComponents = 2
    include = ["*/skills/<name>/**"]
    refreshPeriod = "168h"
```

取得先が `~/.config/agent-skills` 配下であれば、自作 skill と同じようにリンクされます。

## plugin

hook、command、MCP server を含む plugin は `home/.chezmoiscripts/run_onchange_after_36-install-agent-plugins.sh` の表で宣言します。表を編集すると、次の apply で全ホストに反映されます。

```sh
# Fields: <marketplace source> <plugin id> <agents>
plugins='
DietrichGebert/ponytail ponytail@ponytail claude,codex
'
```

plugin は skill と違って実行環境を要求することがあります。Ponytail の hook は `node <hook>.js` として起動されるため、Node 本体が PATH 上に必要です。これは `home/dot_config/mise/config.toml` の `[tools]` で宣言しています。

marketplace の追加と plugin の導入は、どちらの CLI でも冪等です。宣言済みの marketplace と導入済みの plugin はそのまま成功扱いになるため、スクリプトは独自の状態を持ちません。Claude Code へは user scope で導入します。

`claude plugin install` に `--yes` は渡しません。marketplace がコマンド実行を伴う導入方法を宣言している場合、そのコマンドは各ホストで一度は対話的に確認するべきだからです。

## 管理しないもの

`~/.claude/settings.json` と `~/.codex/config.toml` は agent 自身が書き換えます。theme、model、`trust_level`、`hooks.state` などが実行中に追記されるため、chezmoi の管理対象にすると apply のたびに差分が出ます。plugin を CLI 経由で導入しているのはこのためです。

## 機微情報

このリポジトリは公開されています。研究室内部の基準、未公開の原稿、査読対象の情報を skill 本文に書かないでください。それらが必要になった場合は、private リポジトリを `.chezmoiexternal.toml` の `type = "git-repo"` で取り込むか、chezmoi の `encrypted_` 属性で暗号化します。
