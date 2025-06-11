#=================================================================================================#
##					New Commands						 ##
#=================================================================================================#

FILTER=fzf

# change git-repository's directory
function FILTER-cd-src() {
	local selected_dir=$(ghq list | FZF_DEFAULT_OPTS="$FZF_GIT_REPO_SEARCH_OPTS" "$FILTER" --query "$LBUFFER")
	if [ -n "$selected_dir" ]; then
		BUFFER="cd ${selected_dir}"
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
	local selected_host=$(awk '/Host / {hostname=$2; print hostname }' ~/.ssh/config | FZF_DEFAULT_OPTS="$FZF_SSH_HOST_SEARCH_OPTS" fzf --query "$L_BUFFER")

	if [ -n "$selected_host" ]; then
		BUFFER="ssh ${selected_host}"
		zle accept-line
	fi
	zle reset-prompt
}
zle -N FILTER-select-ssh
