#!/bin/sh

set -eu


workspace_type=${1:-}
workspace_path=${2:-}


preview_directory()
{
	if command -v eza >/dev/null 2>&1; then
		eza \
			-al \
			-g \
			--icons \
			--color=always \
			"$workspace_path/" |
			awk '{
				icon = $(NF-1)
				name = $NF
				print icon, name
			}'
	else
		ls -la "$workspace_path"
	fi
}


preview_worktree()
{
	branch=$(
		git -C "$workspace_path" branch --show-current 2>/dev/null ||
			printf '%s\n' '(detached)'
	)

	printf '\033[1mBranch\033[0m\n'
	printf '%s\n' "$branch"

	printf '\n\033[1mChanges\033[0m\n'

	if [ -n "$(git -C "$workspace_path" status --porcelain)" ]; then
		git -C "$workspace_path" \
			-c color.status=always \
			status --short
	else
		printf '%s\n' 'Working tree clean'
	fi

	printf '\n\033[1mDiff Stat\033[0m\n'

	diff_stat=$(
		git -C "$workspace_path" \
			--no-pager \
			diff --stat
	)

	cached_stat=$(
		git -C "$workspace_path" \
			--no-pager \
			diff --cached --stat
	)

	if [ -n "$cached_stat" ]; then
		printf '%s\n' "$cached_stat"
	fi

	if [ -n "$diff_stat" ]; then
		printf '%s\n' "$diff_stat"
	fi

	if [ -z "$cached_stat" ] && [ -z "$diff_stat" ]; then
		printf '%s\n' 'No uncommitted changes'
	fi

	printf '\n\033[1mRecent Commits\033[0m\n'

	git -C "$workspace_path" \
		--no-pager \
		log \
		--graph \
		--decorate \
		--oneline \
		--color=always \
		-12
}


case "$workspace_type" in
	worktree)
		preview_worktree
		;;

	directory)
		preview_directory
		;;

	*)
		printf 'Unknown workspace type: %s\n' \
			"$workspace_type" >&2
		exit 1
		;;
esac
