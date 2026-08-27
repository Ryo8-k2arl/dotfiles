#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_home=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-layout-check.XXXXXX")

cleanup() {
  rm -rf -- "$test_home"
}
trap cleanup EXIT HUP INT TERM

check_hash() {
  expected=$1
  path=$2
  actual=$(sha256sum "$path" | cut -d' ' -f1)
  test "$actual" = "$expected"
}

# These files were relocated, not edited.
check_hash 09b94b1354e305e608b90362724fabbc089730c823d448feabc0513168653362 \
  "$repo_dir/docs/reference/hyprland.monolithic.conf"
check_hash 6e7f76c369b6cd1fa41d37fd7f613ca74fd8f2eb72259f1d6da3357eb38eda0f \
  "$repo_dir/home/dot_config/env/lang.env"
check_hash c4cda498a66efbda931c46bbeb66d71c096f1c4ff3b727ac5e2a74020d0f225d \
  "$repo_dir/home/dot_config/env/tool.env"

data='{"hostType":"laptop","osid":"linux-test","enableHyprland":true,"zellijFileCommand":"ft","zellijGitCommand":"keifu"}'

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

for target in \
  .config/env/base.env \
  .config/env/lang.env \
  .config/env/tool.env \
  .config/env/desktop.env \
  .config/env/local.env \
  .config/hypr/conf/general.conf \
  .config/hypr/conf/keybinds.conf \
  .config/hypr/conf/rules.conf \
  .config/hypr/conf/machine.conf
do
  test -f "$test_home/$target"
done

test "$(stat -c '%a' "$test_home/.config/env/local.env")" = 600
rg -q '^monitor = ,preferred,auto,auto$' "$test_home/.config/hypr/conf/machine.conf"
rg -q 'switch:off:Lid Switch' "$test_home/.config/hypr/conf/machine.conf"

zsh -n "$test_home/.zshenv"
test ! -e "$test_home/.config/lang.env"
test ! -e "$test_home/.config/tool.env"

printf '%s\n' 'dotfiles layout check passed'
