#!/bin/sh

set -eu

command=${RESURRECT_COMMAND:-}

case "$command" in
*nvim*"--server"*"--remote-ui"* | \
  *nvim*"--listen"*"nvim-zellij-"* | \
  *"[nvim]"*"<defunct>"*)
  printf '%s\n' \
    "${XDG_CONFIG_HOME:-$HOME/.config}/zellij/scripts/zellij-nvim-editor.sh"
  ;;

*)
  printf '%s\n' "$command"
  ;;
esac
