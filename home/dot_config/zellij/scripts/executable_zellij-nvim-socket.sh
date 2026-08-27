#!/bin/sh

set -eu


get_current_tab_id()
{
	tab_id=$(
		zellij action current-tab-info |
			awk '$1 == "id:" { print $2; exit }'
	)

	if [ -z "$tab_id" ]; then
		printf '%s\n' \
			'Failed to get the current Zellij tab ID.' >&2
		return 1
	fi

	printf '%s\n' "$tab_id"
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
