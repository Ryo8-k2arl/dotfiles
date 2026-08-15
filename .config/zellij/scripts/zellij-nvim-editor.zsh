#!/usr/bin/env zsh

set -u

readonly SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}"
readonly SESSION_NAME="${ZELLIJ_SESSION_NAME:-default}"
readonly SOCKET_PATH="${SOCKET_DIR}/nvim-${SESSION_NAME}.sock"

SERVER_PID=""


server_is_running() {
  [[ -n "${SERVER_PID}" ]] &&
    kill -0 "${SERVER_PID}" 2>/dev/null
}


wait_for_server() {
  while ! nvim \
    --server "${SOCKET_PATH}" \
    --remote-expr '1' >/dev/null 2>&1
  do
    server_is_running || return 1
    sleep 0.05
  done
}


start_server() {
  rm -f "${SOCKET_PATH}"

  nvim \
    --headless \
    --listen "${SOCKET_PATH}" &

  SERVER_PID=$!

  wait_for_server
}


attach_ui() {
  nvim \
    --server "${SOCKET_PATH}" \
    --remote-ui
}


stop_server() {
  if server_is_running; then
    kill "${SERVER_PID}" 2>/dev/null
    wait "${SERVER_PID}" 2>/dev/null
  fi

  rm -f "${SOCKET_PATH}"
}


trap stop_server EXIT
trap 'exit 0' INT TERM HUP


while true; do
  if ! server_is_running; then
    start_server || {
      sleep 1
      continue
    }
  fi

  attach_ui

  sleep 0.1
done
