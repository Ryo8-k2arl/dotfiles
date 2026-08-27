#!/bin/sh

set -eu

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
config_dir="$config_home/git/conf.d"
user_config="$config_dir/user.local"

umask 077
mkdir -p "$config_dir"

if [ ! -e "$user_config" ]; then
    : >"$user_config"
fi

chmod 600 "$user_config"
