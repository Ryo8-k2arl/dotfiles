#=================================================================================================#
##          New Commands                                      																	 ##
#=================================================================================================#

FILTER=fzf

# change git-repository's directory
function FILTER-cd-repo() {
	local selected_dir=$(ghq list -p | "$FILTER" --query "$LBUFFER")
	if [ -n "$selected_dir" ]; then
		BUFFER="cd ${selected_dir}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N FILTER-cd-src

# select the command executed in the past
function FILTER-select-history() {
	BUFFER=$(\history -n -r 1 | "$FILTER" --query "$LBUFFER")
	CURSOR=$#BUFFER
	zle clear-screen
}
zle -N FILTER-select-history

# select host to ssh
function FILTER-select-ssh() {
	local selected_host=$(grep "Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf --query "$LBUFFER")

	if [ -n "$selected_host" ]; then
		BUFFER="ssh ${selected_host}"
		zle accept-line
	fi
	zle reset-prompt
}

zle -N FILTER-select-ssh
