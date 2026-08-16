#!/bin/sh

set -u

script_dir=$(
  CDPATH= cd "$(dirname "$0")" 2>/dev/null &&
    pwd -P
) || exit 1

socket_path=$("$script_dir/zellij-nvim-socket.sh") || exit 1

cleanup() {
  rm -f "$socket_path"
}

trap cleanup EXIT
trap 'exit 0' INT TERM HUP

while :; do
  rm -f "$socket_path"

  nvim \
    --listen "$socket_path"

  sleep 0.1
done
