#--------------------------------------------------------------#
##          zsh's Environment Variables                       ##
#--------------------------------------------------------------#

### locale ###
export LANG=en_US.UTF-8
export LC_TIME=C.UTF-8

### XDG ###
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

### zsh ###
export ZDOTDIR="$HOME/.config/zsh"
export ZHOMEDIR="$HOME/.config/zsh"
export ZDATADIR="$XDG_DATA_HOME/zsh"
export ZCACHEDIR="$XDG_CACHE_HOME/zsh"
