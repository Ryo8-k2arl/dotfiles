#=================================================================================================#
##					New Commands						 ##
#=================================================================================================#

# Fuzzy Finder
FILTER=fzf
# Terminal Multiplexer
TMUX=zellij

# change git-repository's directory
function FILTER-cd-src() {
	local selected_dir=$(ghq list | FZF_DEFAULT_OPTS="$FZF_GIT_REPO_SEARCH_OPTS" "$FILTER" --query "$LBUFFER")
	if [ -n "$selected_dir" ]; then
		BUFFER="cd $(ghq root)/${selected_dir}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N FILTER-cd-src

# select the command executed in the past
function FILTER-select-history() {
	BUFFER=$(\history -n -r 1 | FZF_DEFAULT_OPTS="$FZF_HISTORY_OPTS" "$FILTER" --query "$LBUFFER")
	CURSOR=$#BUFFER
	zle clear-screen
}
zle -N FILTER-select-history

# select host to ssh
function FILTER-select-ssh() {
	local selected_host=$(awk '/Host / {hostname=$2; print hostname }' ~/.ssh/config | FZF_DEFAULT_OPTS="$FZF_SSH_HOST_SEARCH_OPTS" fzf --query "$LBUFFER")

	if [ -n "$selected_host" ]; then
		BUFFER="ssh ${selected_host}"
		zle accept-line
	fi
	zle reset-prompt
}
zle -N FILTER-select-ssh

# select TMUX's session
function FILTER-select-TMUX() {
	local selected_session=$("$TMUX" ls --no-formatting | FZF_DEFAULT_OPTS="$FZF_HISTORY_OPTS" "$FILTER" --query "$LBUFFER")
	echo "$selected_session" | cut -d' ' -f1
}

# mycli with XDG Support
function mycli() {
	local -a config_args

	if [[ -r "$XDG_CONFIG_HOME/mycli/myclirc" ]]; then
		config_args+=(--myclirc "$XDG_CONFIG_HOME/mycli/myclirc")
	fi

	if [[ -r "$XDG_CONFIG_HOME/mysql/my.cnf" ]]; then
		config_args+=(--defaults-file "$XDG_CONFIG_HOME/mysql/my.cnf")
	fi

	command mycli "${config_args[@]}" "$@"
}
