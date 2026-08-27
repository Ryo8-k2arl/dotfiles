#!/bin/sh

set -eu


get_current_tab_id()
{
	pane_id=${ZELLIJ_PANE_ID:-}

	if [ -z "$pane_id" ]; then
		printf '%s\n' \
			'Failed to get the current Zellij pane ID.' >&2
		return 1
	fi

	case "$pane_id" in
	terminal_* | plugin_*) ;;
	*) pane_id="terminal_$pane_id" ;;
	esac
	bare_pane_id=${pane_id#*_}

	attempt=0
	while [ "$attempt" -lt 50 ]; do
		tab_id=$(
			zellij --session "$ZELLIJ_SESSION_NAME" \
				action list-panes --tab 2>/dev/null |
				awk \
					-v pane_id="$pane_id" \
					-v bare_pane_id="$bare_pane_id" '
					{
						for (field = 1; field <= NF; field++) {
							if ($field == pane_id || $field == bare_pane_id) {
								print $1
								exit
							}
						}
					}
				'
		)

		if [ -n "$tab_id" ]; then
			printf '%s\n' "$tab_id"
			return 0
		fi

		attempt=$((attempt + 1))
		sleep 0.1
	done

	printf '%s\n' \
		'Failed to get the Zellij tab ID for the current pane.' >&2
	return 1
}


sanitize_session_name()
{
	printf '%s' "$1" |
		tr -c 'A-Za-z0-9_.-' '_'
}


if [ -z "${ZELLIJ_SESSION_NAME:-}" ]; then
	printf '%s\n' \
		'Not running inside a Zellij session.' >&2
	exit 1
fi


socket_dir="${XDG_RUNTIME_DIR:-/tmp}/nvim-zellij-$(id -u)"
tab_id=$(get_current_tab_id)
session_name=$(sanitize_session_name "$ZELLIJ_SESSION_NAME")

umask 077
mkdir -p "$socket_dir"

printf '%s/nvim-%s-%s.sock\n' \
	"$socket_dir" \
	"$session_name" \
	"$tab_id"
