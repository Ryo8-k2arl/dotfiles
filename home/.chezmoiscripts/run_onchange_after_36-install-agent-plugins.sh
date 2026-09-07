#!/bin/sh

set -eu

# Third-party agent plugins. Plain skills belong in ~/.config/agent-skills and
# are shared by symbolic link; a plugin is installed here instead because it
# also ships hooks, commands, or MCP servers, which a link cannot register.
#
# Editing the table re-runs this script on every host.
#
# Fields: <marketplace source> <plugin id> <agents>
plugins='
DietrichGebert/ponytail ponytail@ponytail claude,codex
'

wants_agent() {
  case ",$2," in
    *",$1,"*) return 0 ;;
  esac
  return 1
}

# Both CLIs treat a marketplace that is already declared, and a plugin that is
# already installed, as success, so the calls below need no state of their own.
#
# `claude plugin install` is deliberately called without --yes: a marketplace
# that installs by running a command should be reviewed once, interactively,
# before it is trusted on a host.
install_for_claude() {
  claude plugin marketplace add "$1" >/dev/null
  claude plugin install "$2" --scope user >/dev/null
}

install_for_codex() {
  codex plugin marketplace add "$1" >/dev/null
  codex plugin add "$2" >/dev/null
}

printf '%s\n' "$plugins" | while read -r marketplace_source plugin_id agents; do
  [ -n "$marketplace_source" ] || continue
  case "$marketplace_source" in \#*) continue ;; esac

  for agent in claude codex; do
    wants_agent "$agent" "$agents" || continue
    command -v "$agent" >/dev/null 2>&1 || continue

    printf '%s\n' "Installing $plugin_id for $agent"
    "install_for_$agent" "$marketplace_source" "$plugin_id"
  done
done
