#!/usr/bin/env zsh

set -eu


readonly SCRIPT_DIR="${0:A:h}"
readonly SOCKET_PATH="$("${SCRIPT_DIR}/zellij-nvim-socket.zsh")"


if (( $# == 0 )); then
  print -u2 "Usage: zellij-nvim-open.zsh <file> [...]"
  exit 1
fi


if [[ ! -S "${SOCKET_PATH}" ]]; then
  print -u2 "Neovim server is not running: ${SOCKET_PATH}"
  exit 1
fi


exec nvim \
  --server "${SOCKET_PATH}" \
  --remote "$@"
