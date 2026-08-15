#!/usr/bin/env zsh

set -u

readonly SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}"
readonly SESSION_NAME="${ZELLIJ_SESSION_NAME:-default}"
readonly SOCKET_PATH="${SOCKET_DIR}/nvim-${SESSION_NAME}.sock"


if (( $# == 0 )); then
  echo "Usage: nvim-open.zsh <file> [...]" >&2
  exit 1
fi


if [[ ! -S "${SOCKET_PATH}" ]]; then
  echo "Neovim server is not running: ${SOCKET_PATH}" >&2
  exit 1
fi


exec nvim \
  --server "${SOCKET_PATH}" \
  --remote "$@"
