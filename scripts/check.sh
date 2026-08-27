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
test "$(stat -c '%a' "$test_home/.config/git/conf.d/user.local")" = "600"
test "$(readlink "$test_home/.local/bin/latexindent")" = "../../.config/latexindent/bin/latexindent-wrapper"

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

for script_file in \
  "$test_home"/.config/zellij/scripts/*.sh \
  "$test_home/.config/latexindent/bin/latexindent-wrapper"
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

if rg -n '/home/[^/[:space:]]+' "$repo_dir/home"; then
  printf '%s\n' 'hard-coded home directory detected' >&2
  exit 1
fi

printf '%s\n' 'dotfiles check passed'
