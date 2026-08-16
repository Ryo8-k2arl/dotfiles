#!/bin/sh

set -eu

absolute_path() (
  CDPATH= cd -- "$1" 2>/dev/null
  pwd -P
)

display_path() {
  path=$1

  if command -v ghq >/dev/null 2>&1; then
    ghq_root=$(ghq root 2>/dev/null || :)

    if [ -n "$ghq_root" ]; then
      ghq_root=$(absolute_path "$ghq_root")

      case "$path" in
      "$ghq_root"/*)
        printf '%s/%s\n' \
          "$(basename "$ghq_root")" \
          "$(basename "$path")"
        return
        ;;
      esac
    fi
  fi

  case "$path" in
  "$HOME")
    printf '%s\n' '~'
    ;;

  "$HOME"/*)
    printf '%s\n' "${path#"$HOME"/}"
    ;;

  *)
    printf '%s\n' "$path"
    ;;
  esac
}

project_name() (
  path=$1

  common_dir=$(
    git -C "$path" rev-parse --git-common-dir 2>/dev/null
  ) || exit 1

  case "$common_dir" in
  /*)
    ;;
  *)
    common_dir="$path/$common_dir"
    ;;
  esac

  project_root=$(
    CDPATH= cd -- "$(dirname "$common_dir")" 2>/dev/null
    pwd -P
  )

  basename "$project_root"
)

print_worktrees() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    return 0
  fi

  git worktree list --porcelain |
    awk '
		/^worktree / {
			path = substr($0, 10)
		}

		/^branch refs\/heads\// {
			branch = substr($0, 19)
		}

		/^detached$/ {
			branch = "(detached)"
		}

		/^$/ {
			if (path != "") {
				printf "%s\t%s\n", path, branch
			}

			path = ""
			branch = ""
		}

		END {
			if (path != "") {
				printf "%s\t%s\n", path, branch
			}
		}
	' |
    while IFS="$(printf '\t')" read -r path branch; do
      path=$(absolute_path "$path")
      project=$(project_name "$path")
      shown_path=$(display_path "$path")

      # 内部:
      #   type<TAB>absolute-path<TAB>表示1行目
      #   <TAB><TAB>表示2行目
      #
      # NUL までが fzf 上の1候補。
      printf 'worktree\t%s\t%s (%s)\n\t%s\0' \
        "$path" \
        "${branch:-"(detached)"}" \
        "$project" \
        "$shown_path"
    done
}

is_listed_worktree() (
  target_path=$1

  git worktree list --porcelain 2>/dev/null |
    awk -v target="$target_path" '
			/^worktree / {
				path = substr($0, 10)

				if (path == target) {
					found = 1
				}
			}

			END {
				exit !found
			}
		'
)

print_directories() {
  if ! command -v ghq >/dev/null 2>&1; then
    return 0
  fi

  ghq list -p |
    while IFS= read -r path; do
      [ -n "$path" ] || continue
      [ -d "$path" ] || continue

      path=$(absolute_path "$path")

      if git rev-parse --git-dir >/dev/null 2>&1 &&
        is_listed_worktree "$path"; then
        continue
      fi

      shown_path=$(display_path "$path")

      printf 'directory\t%s\t\n\t%s\0' \
        "$path" \
        "$shown_path"
    done
}

print_workspaces() {
  print_worktrees
  print_directories
}

if ! command -v fzf >/dev/null 2>&1; then
  printf '%s\n' 'fzf is not installed.' >&2
  exit 1
fi

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
fzf_config="$config_home/fzf/config"
preview_command="$config_home/zellij/scripts/zellij-tab-preview.sh"
dev_layout="$config_home/zellij/layouts/dev.kdl"

if [ -r "$fzf_config" ]; then
  . "$fzf_config"
fi

selected=$(
  print_workspaces |
    FZF_DEFAULT_OPTS="${FZF_ZELLIJ_WORKSPACE_OPTS:-}" \
      fzf \
      --read0 \
      --delimiter="$(printf '\t')" \
      --nth='3..' \
      --with-nth='3..' \
      --highlight-line \
      --preview "\"$preview_command\" {1} {2}"
) || exit 0

[ -n "$selected" ] || exit 0

workspace_name() {
  workspace_type=$1
  workspace_path=$2

  case "$workspace_type" in
  worktree)
    branch=$(
      git -C "$workspace_path" \
        branch --show-current 2>/dev/null ||
        :
    )

    if [ -n "$branch" ]; then
      printf '%s\n' "$branch"
    else
      basename "$workspace_path"
    fi
    ;;

  directory)
    basename "$workspace_path"
    ;;

  *)
    basename "$workspace_path"
    ;;
  esac
}

metadata=$(
  printf '%s\n' "$selected" |
    sed -n '1p'
)

workspace_type=$(
  printf '%s\n' "$metadata" |
    cut -f1
)

workspace_path=$(
  printf '%s\n' "$metadata" |
    cut -f2
)

tab_name=$(
  workspace_name \
    "$workspace_type" \
    "$workspace_path"
)

zellij action new-tab \
  --layout "$dev_layout" \
  --cwd "$workspace_path" \
  --name "$tab_name"
