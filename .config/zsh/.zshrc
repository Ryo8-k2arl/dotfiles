#                                     _
#                             _______| |__  _ __ ___
#                            |_  / __| '_ \| '__/ __|
#                           _ / /\__ \ | | | | | (__
#                          (_)___|___/_| |_|_|  \___|
#


#-------------------------------------------------------------------------------------------------#
##	 Base Configuration									 ##
#-------------------------------------------------------------------------------------------------#

source "$ZHOMEDIR/base.zsh"
source "$ZHOMEDIR/history.zsh"


#-------------------------------------------------------------------------------------------------#
##	Tool											 ##
#-------------------------------------------------------------------------------------------------#

## Plugin Manager
if builtin command -v sheldon > /dev/null 2>&1; then
	eval "$(sheldon source)"
fi

## Terminal Prompt
if builtin command -v starship > /dev/null 2>&1; then
	eval "$(starship init zsh)"
else
	PROMPT='[%n@%m]%~%# '
fi


#-------------------------------------------------------------------------------------------------#
##	Function										 ##
#-------------------------------------------------------------------------------------------------#

source "$ZHOMEDIR/function.zsh"


#-------------------------------------------------------------------------------------------------#
##	Aliases											 ##
#-------------------------------------------------------------------------------------------------#

source "$RCDIR/alias.rc"


#-------------------------------------------------------------------------------------------------#
##	Key Bindings										 ##
#-------------------------------------------------------------------------------------------------#

source "$ZHOMEDIR/bindkey.zsh"

