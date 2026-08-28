#!/bin/sh

set -eu

root=$(ghq root)

find "$root" \
  \( -type d -o -type f \) \
  -name .git \
  -prune \
  -print |
  awk -v prefix="$root/" '
    index($0, prefix) == 1 {
      repository = substr($0, length(prefix) + 1)
      sub(/\/\.git\/?$/, "", repository)
      print repository
    }
  ' |
  sort
