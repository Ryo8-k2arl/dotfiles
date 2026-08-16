#!/bin/sh

set -eu


script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
socket_path=$("$script_dir/zellij-nvim-socket.sh") || exit 1


if [ "$#" -eq 0 ]; then
	printf '%s\n' \
		'Usage: zellij-nvim-open.sh <file> [...]' >&2
	exit 1
fi


if [ ! -S "$socket_path" ]; then
	printf 'Neovim server is not running: %s\n' \
		"$socket_path" >&2
	exit 1
fi


exec nvim \
	--server "$socket_path" \
	--remote "$@"
