# Android and Kotlin without Android Studio

Android Studio の GUI を使わず、Neovim と公式 `android` CLI だけで Kotlin の Android アプリを開発するための設定です。CI / CD でも同じ経路が使えることを条件にしています。

「Android Studio CLI」というものは存在しません。2026 年 5 月に Stable 1.0 になった公式の `android` CLI がその役割を担い、SDK 管理、プロジェクト生成、仮想端末操作、APK 配置、画面取得を引き受けます。ビルド自体は従来どおり Gradle です。

なお `android studio` サブコマンド群（`render-compose-preview` など）は Android Studio の起動中インスタンスと Gemini サインインを前提とするため、この設定では使いません。

## 構成

| 展開先 | 役割 |
| --- | --- |
| `~/.config/env/lang.env` | `ANDROID_HOME`、`ANDROID_USER_HOME`、`ANDROID_AVD_HOME`、`GRADLE_USER_HOME`、`JAVA_HOME` / `JAVA_HOME_17` / `JAVA_HOME_21` |
| `~/.zshenv` | `$ANDROID_HOME/platform-tools` と `$ANDROID_HOME/emulator` を PATH に追加 |
| `~/.config/mise/config.toml` | `temurin-21` と `temurin-17` を導入 |
| `~/.local/share/gradle/gradle.properties` | mise 管理の JDK を Gradle の toolchain に橋渡し |
| `~/.config/nvim/after/lsp/kotlin_lsp.lua` | Kotlin LSP の起動設定と誤検知の抑制 |
| `~/.config/nvim/lua/plugins/lang/kotlin.lua` | treesitter、整形、LSP 登録 |
| `~/.config/nvim/lua/plugins/lsp/mason.lua` | `kotlin-lsp` を Mason で導入 |
| `~/.local/bin/android-emu` | ヘッドレスエミュレータの起動・停止 |
| `~/.local/bin/android-shot` | 画面取得と表示 |

chezmoi のソースは `home/dot_config/`、`home/dot_local/`、`home/.chezmoiscripts/` 以下にあります。

`android` CLI と SDK は chezmoi スクリプトが導入します。

| スクリプト | 内容 |
| --- | --- |
| `run_onchange_after_25-install-android-sdk.sh.tmpl` | `android` CLI、platform-tools、`platforms/android-36`、`build-tools/36.0.0`。server 以外では `emulator` も |

Kotlin LSP は他の言語サーバーと同じく Mason が導入します。Mason のパッケージは JetBrains の CDN から `bin/intellij-server` を含むアーカイブを取得するもので、取得元も版も手動導入と同一です。`cmd` と root marker は nvim-lspconfig の既定をそのまま使います。

## ツールチェーンの配置

ベンダー既定の `~/Android/Sdk` と `~/.android` ではなく、XDG に寄せています。

```text
~/.local/share/android/sdk    ANDROID_HOME
~/.local/share/android/user   ANDROID_USER_HOME（AVD、adbkey、CLI 自身のバンドル）
~/.local/share/gradle         GRADLE_USER_HOME
```

Kotlin LSP は Mason の管理下（`~/.local/share/nvim/mason/packages/kotlin-lsp`）に入ります。

`ANDROID_SDK_ROOT` は設定していません。`android` CLI はこの変数を無視し、`ANDROID_HOME` だけを見ます。

AVD の探索先を指す変数は 2 つ必要です。`android` CLI は `ANDROID_USER_HOME` を見ますが、`emulator` バイナリはこれを見ず `ANDROID_AVD_HOME` を見ます。片方だけだと `android emulator list` と `emulator -list-avds` の結果が食い違います。

`JAVA_HOME` も `lang.env` で設定しています。mise は `.zshrc` で activate するため非対話シェルでは効かず、そのままでは CI やスクリプトから `./gradlew` が JVM を見つけられません。mise が有効なときは mise の値が優先されます。

容量は SDK が約 4.3 GB、AVD とエミュレータ状態が約 3.9 GB、Kotlin LSP が約 1.3 GB、Gradle のキャッシュが約 1.3 GB、JDK 2 本で約 660 MB です。

## 必要なコマンド

- `nvim`
- `mise`（JDK を供給する）
- `curl`、`tar`（スクリプトが使う）

`java`、`android`、`adb`、`emulator` は chezmoi と mise が、Kotlin LSP は Mason が用意します。次で確認できます。

```sh
android info
android sdk list
mise ls java
```

Neovim では `:Mason` と `:LspInfo` で状態を確認できます。

## 基本の流れ

```sh
# プロジェクトを作る（テンプレート一覧は android create --list）
android create --name="My App" --output=./MyApp empty-activity

cd MyApp
./gradlew assembleDebug          # ビルド
./gradlew testDebugUnitTest      # 単体テスト

android-emu start                # ヘッドレスでエミュレータを起動
android run --apks=app/build/outputs/apk/debug/app-debug.apk
android-shot                     # 画面を撮って表示
android layout --pretty          # UI 階層を JSON で取得
android-emu stop
```

AVD が無い場合は先に作ります。

```sh
android emulator create medium_phone
```

計装テストは build-managed devices を Gradle に宣言し、描画ハードのない環境では GPU を指定します。

```sh
./gradlew pixel2api30DebugAndroidTest \
  -Pandroid.testoptions.manageddevices.emulator.gpu=swiftshader_indirect
```

## Neovim での挙動

Kotlin LSP は JetBrains 公式で、IntelliJ の解析エンジンをそのまま載せています。公式表記は Alpha、Android Gradle Plugin 対応は experimental ですが、この環境で実測した限り解決能力は実務水準にあります。

| 項目 | 結果 |
| --- | --- |
| 起動 | 約 8 秒 |
| 初回索引 | 約 44 秒（冷間）、以降は約 9 秒 |
| 補完 | `Modifier.` で 281 件、`MaterialTheme.` で `colorScheme` などが出る |
| 定義移動 | 自プロジェクト、Compose、Navigation3、`android.jar`、R クラスまで到達 |
| 参照検索 | 動作する |
| 整形 | LSP が担当（IntelliJ のフォーマッタ）。ktlint も ktfmt も入れていない |

届かないのは Extract Function、Change Signature、Move といった重量級リファクタリングです。LSP のプロトコルに語彙がないため、手で書くことになります。

補完が疑わしいときは Gradle を最終審にしてください。

```sh
./gradlew compileDebugKotlin
```

## 既知の落とし穴

**R クラスは一度ビルドするまで解決しない。** LSP は `processDebugResources` が生成する `R.jar` を見ます。`compileDebugKotlin` だけでは作られないため、新しいチェックアウトでは先に `./gradlew assembleDebug` を通してください。それまで `Couldn't resolve some dependencies: Gradle: android:r:null` が出ます。

**`android emulator start` は使わない。** ヘッドレス指定が無いため windowed 版 QEMU が選ばれ、`libpulse.so.0` が無い環境では起動前に落ちます。エミュレータは `qemu-system-x86_64-headless` を同梱しており、そちらは PulseAudio に依存しません。`android-emu` はこの理由で `emulator -no-window` を直接呼びます。

**`android emulator create` は system image を勝手に選ぶ。** プロファイル名から `google_apis_playstore` などを判断して自分でダウンロードします。手動で入れた image は使われないので、25 番スクリプトは system image を事前導入しません。

**中断した `android sdk install` は壊れたまま「導入済み」になる。** 展開が途中で終わっても `package.xml` は書かれるため、`android sdk list` は正常と報告します（実行可能ファイルは 0 個）。`--force` では修復されず、`android sdk remove` してから入れ直す必要があります。25 番スクリプトはこの状態を検出して自動で直します。

**`android screen resolve` は `--annotate` 付きの画像を要求する。** 素の PNG では `No feature data` になります。`android-shot` は常に `--annotate` を付けます。

**`adb emu kill` は非同期。** 直後に `adb devices` を見るとまだ端末が残っています。`android-emu stop` は消えるまで待ってから戻ります。

**Gradle の JDK 自動ダウンロードは無効にしている。** `auto-download=false` にしないと、mise が管理する JDK とは別に Gradle が自前の JDK を落として二重管理になります（実測で 503 MB）。

**Alacritty は画像プロトコルを持たない。** `android-shot` は chafa、画像ビューア、`explorer.exe` の順に試します。WSL2 では WSLg が有効なので画像ビューアがそのまま使えます。

**LSP を Mason 以外で導入するなら `mason = false` が要る。** `mason-lspconfig` は `kotlin_lsp` を Mason パッケージに対応付けているため、LazyVim は Mason に導入を任せて `vim.lsp.enable` を自分では呼びません（`lazyvim/plugins/lsp/init.lua`）。手動で入れたバイナリを使わせたい場合は `kotlin_lsp = { mason = false }` を指定しないと、設定もバイナリも揃っているのにサーバーが起動しません。この設定は Mason に任せているので指定は不要です。

**`@Composable` の命名警告は誤検知。** LSP は汎用 Kotlin 規則を当てて「関数名は小文字で始めるべき」と警告します。`after/lsp/kotlin_lsp.lua` が、Compose を使うバッファに限ってこの診断だけを落とします。

## Compose プレビュー

対話的なプレビューは GUI 専用なので使えません。確認はエミュレータで行い、その横で回帰テストとしてスクリーンショットテストを走らせる構成にします。

`com.android.compose.screenshot` はホスト側 JVM でレンダリングするため端末を占有せず、CI にも同じものが載ります。ただし `0.0.1-alpha15` で、全 preview 関数に `@PreviewTest` 注釈が必須です。

```sh
./gradlew updateDebugScreenshotTest    # 基準画像を作る
./gradlew validateDebugScreenshotTest  # 差分を検証する
```

## 未検証

- KSP や Hilt が生成するコードの LSP 解決
- `nvim-dap` から JDWP でアタッチする構成（`android run --debug` が接続待ちにするところまでは確認済み）
- perfetto や simpleperf による プロファイリング
- Journeys（自然言語で書く E2E テスト）の定義形式と実行要件
