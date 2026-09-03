#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_home=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-check.XXXXXX")

cleanup() {
  rm -rf -- "$test_home"
}
trap cleanup EXIT HUP INT TERM

data='{"hostType":"desktop","osid":"linux-test","gitName":"Test User","gitEmail":"test@example.com","enableHyprland":true,"zellijFileCommand":"ft","zellijGitCommand":"keifu"}'

chezmoi \
  --source "$repo_dir" \
  --destination "$test_home" \
  --persistent-state "$test_home/chezmoistate.boltdb" \
  --cache "$test_home/cache" \
  --override-data "$data" \
  --no-tty \
  --force \
  apply \
  --exclude scripts

test -x "$test_home/.config/zellij/scripts/zellij-tab.sh"
test -x "$test_home/.config/latexindent/bin/latexindent-wrapper"
test -L "$test_home/.local/bin/latexindent"
test -f "$test_home/.config/zsh/.zshrc"
test -f "$test_home/.config/systemd/user/claude-code-update.service"
test -f "$test_home/.config/systemd/user/claude-code-update.timer"
test -f "$test_home/.config/systemd/user/codex-update.service"
test -f "$test_home/.config/systemd/user/codex-update.timer"
test -x "$test_home/.local/bin/android-emu"
test -x "$test_home/.local/bin/android-shot"
test -f "$test_home/.local/share/gradle/gradle.properties"
test -f "$test_home/.config/nvim/after/lsp/kotlin_lsp.lua"
test "$(stat -c '%a' "$test_home/.config/git/conf.d/user.local")" = "600"
test "$(readlink "$test_home/.local/bin/latexindent")" = "../../.config/latexindent/bin/latexindent-wrapper"

cli_timer_script="$repo_dir/home/.chezmoiscripts/run_after_40-enable-cli-update-timers.sh.tmpl"
test "$(chezmoi execute-template < "$cli_timer_script" | sed -n '1p')" = '#!/bin/sh'
chezmoi execute-template < "$cli_timer_script" | sh -n

android_sdk_script="$repo_dir/home/.chezmoiscripts/run_onchange_after_25-install-android-sdk.sh.tmpl"
test "$(chezmoi execute-template < "$android_sdk_script" | sed -n '1p')" = '#!/bin/sh'
chezmoi execute-template < "$android_sdk_script" | sh -n

resurrect_hook="$test_home/.config/zellij/scripts/zellij-resurrect-command.sh"
editor_command="$test_home/.config/zellij/scripts/zellij-nvim-editor.sh"
test "$(RESURRECT_COMMAND='[nvim] <defunct>' XDG_CONFIG_HOME="$test_home/.config" "$resurrect_hook")" = "$editor_command"
test "$(RESURRECT_COMMAND='lazygit' XDG_CONFIG_HOME="$test_home/.config" "$resurrect_hook")" = "lazygit"

server_data='{"hostType":"server","osid":"linux-test","gitName":"Test User","gitEmail":"test@example.com","enableHyprland":false,"zellijFileCommand":"ft","zellijGitCommand":"keifu"}'
if chezmoi \
  --source "$repo_dir" \
  --destination "$test_home" \
  --persistent-state "$test_home/chezmoistate.boltdb" \
  --cache "$test_home/cache" \
  --override-data "$server_data" \
  managed | grep -q '^\.config/hypr/'; then
  printf '%s\n' 'Hyprland files were not excluded for the server profile' >&2
  exit 1
fi

if chezmoi \
  --source "$repo_dir" \
  --destination "$test_home" \
  --persistent-state "$test_home/chezmoistate.boltdb" \
  --cache "$test_home/cache" \
  --override-data "$server_data" \
  managed | grep -q '^\.local/bin/android-'; then
  printf '%s\n' 'Emulator helpers were not excluded for the server profile' >&2
  exit 1
fi

for script_file in \
  "$test_home"/.config/zellij/scripts/*.sh \
  "$test_home/.config/latexindent/bin/latexindent-wrapper" \
  "$test_home/.local/bin/android-emu" \
  "$test_home/.local/bin/android-shot"
do
  sh -n "$script_file"
done

for zsh_file in \
  "$test_home/.zshenv" \
  "$test_home/.config/zsh/.zshrc" \
  "$test_home"/.config/zsh/*.zsh \
  "$test_home"/.config/zsh/hooks/*.zsh \
  "$test_home"/.config/rc/*.rc
do
  zsh -n "$zsh_file"
done

find "$test_home/.config/nvim" -type f -name '*.json' -print0 |
  xargs -0 -r -n1 jq empty

NVIM_LOG_FILE="$test_home/nvim.log" nvim --clean --headless -u NONE \
  "+lua for _, f in ipairs(vim.fn.glob('$test_home/.config/nvim/**/*.lua', false, true)) do assert(loadfile(f)) end" \
  +qa

git config \
  --includes \
  --file "$test_home/.config/git/config" \
  --list >/dev/null

ZELLIJ_CONFIG_DIR="$test_home/.config/zellij" \
  zellij setup --check >/dev/null
ZELLIJ_CONFIG_DIR="$test_home/.config/zellij" \
  zellij setup --dump-layout dev >/dev/null

systemd-analyze verify \
  "$test_home/.config/systemd/user/claude-code-update.service" \
  "$test_home/.config/systemd/user/claude-code-update.timer" \
  "$test_home/.config/systemd/user/codex-update.service" \
  "$test_home/.config/systemd/user/codex-update.timer"

if rg -n '/home/[^/[:space:]]+' "$repo_dir/home"; then
  printf '%s\n' 'hard-coded home directory detected' >&2
  exit 1
fi

printf '%s\n' 'dotfiles check passed'
