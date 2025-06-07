
#==============================================================#
##          New Commands                                      ##
#==============================================================#

FILTER = fzf


# change git-repository's directory
function peco-cd-repo () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-cd-src


# select the command excuted in the past
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history



# https://namileriblog.com/mac/fzf/
# https://blog.tsub.me/post/move-from-peco-to-fzf/



#========================= Base =========================#
fzf --style full \
        --layout 'reverse' \
	--height '100%' \
	--border --padding 1,2 \
	--border-label '' --input-label ' Input ' --header-label ' File Type ' \
	--preview 'bat --color=always --style=numbers {}' \
	--bind 'result:transform-list-label:
        	if [[ -z $FZF_QUERY ]]; then
          	echo " $FZF_MATCH_COUNT items "
        	else
          	echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
        	fi
        ' \
        --bind 'focus:transform-preview-label:[[ -n {} ]] && printf " %s " {}' \
        --bind 'focus:+transform-header:file --brief {} || echo "No file selected"' \
        --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
        --color 'border:#aaaaaa,label:#cccccc' \
        --color 'preview-border:#9999cc,preview-label:#ccccff' \
        --color 'list-border:#669966,list-label:#99cc99' \
        --color 'input-border:#996666,input-label:#ffcccc' \
        --color 'header-border:#6699cc,header-label:#99ccff' \
        --color 'fg+:#5edecf'

#========================= history =========================#
fzf --style full \
        --layout 'reverse' \
	--height '100%' \
	--border --padding 1,2 \
	--border-label '' --input-label ' Input ' \
	--bind 'result:transform-list-label:
        	if [[ -z $FZF_QUERY ]]; then
          	echo " $FZF_MATCH_COUNT items "
        	else
          	echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
        	fi
        ' \
        --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
        --color 'border:#aaaaaa,label:#cccccc' \
        --color 'list-border:#669966,list-label:#99cc99' \
        --color 'input-border:#996666,input-label:#ffcccc' \
        --color 'fg+:#5edecf'


#========================= git =========================#
# https://tech.mti.co.jp/entry/ac2024/kodamah/1
ghq list |
fzf --style "full" \
	--layout 'reverse' \
	--height '100%' \
	--border --padding 1,2 \
	--preview-window "40%,nowrap" --preview "
        	eza -al -g --icons --color=always $(ghq root)/{} |
        	awk '{print \$8\" \"\$9\" \"}'
	" \
	--bind 'result:transform-list-label:
        	if [[ -z $FZF_QUERY ]]; then
          	echo " $FZF_MATCH_COUNT items "
        	else
          	echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
        	fi
        ' \
        --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
        --color 'border:#aaaaaa,label:#cccccc' \
        --color 'preview-border:#9999cc,preview-label:#ccccff' \
        --color 'list-border:#669966,list-label:#99cc99' \
        --color 'input-border:#996666,input-label:#ffcccc' \
        --color 'header-border:#6699cc,header-label:#99ccff' \
        --color 'fg+:#5edecf'
