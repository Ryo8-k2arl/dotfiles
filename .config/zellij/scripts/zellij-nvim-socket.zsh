#!/usr/bin/env zsh

set -eu


current_tab_id() {
  local tab_id

  tab_id="$(
    zellij action current-tab-info |
      awk '$1 == "id:" { print $2; exit }'
  )"

  if [[ -z "${tab_id}" ]]; then
    print -u2 "Failed to get the current Zellij tab ID."
    return 1
  fi

  print -r -- "${tab_id}"
}


if [[ -z "${ZELLIJ_SESSION_NAME:-}" ]]; then
  print -u2 "Not running inside a Zellij session."
  exit 1
fi


readonly SOCKET_DIR="${XDG_RUNTIME_DIR:-/tmp}/nvim-zellij-${UID}"
readonly SESSION_NAME="${ZELLIJ_SESSION_NAME}"
readonly TAB_ID="$(current_tab_id)"

# Keep the socket filename safe for filesystem use.
readonly SAFE_SESSION_NAME="${SESSION_NAME//[^A-Za-z0-9_.-]/_}"


umask 077
mkdir -p "${SOCKET_DIR}"

printf '%s/nvim-%s-%s.sock\n' \
  "${SOCKET_DIR}" \
  "${SAFE_SESSION_NAME}" \
  "${TAB_ID}"
