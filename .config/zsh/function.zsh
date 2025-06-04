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
