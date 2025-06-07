
#--------------------------------------------------------------#
##          Environment Variables                             ##
#--------------------------------------------------------------#


# export ZDOTDIR=$HOME
export ZDOTDIR=$HOME/.config/zsh
export ZHOMEDIR=$HOME/.config/zsh
export ZRCDIR=$ZHOMEDIR/rc


path=(
	# $HOME/.local/share/zsh/zinit/polaris/bin(N-/)
	# $HOME/bin(N-/)
	# $HOME/.local/bin(N-/)
	# $HOME/go/bin(N-/)
	# $HOME/.go/bin(N-/)
	# $HOME/.cargo/bin(N-/)
	# $HOME/.rustup/toolchains/*/bin(N-/)
	# $HOME/.nimble/bin(N-/)
	# $HOME/.yarn/bin(N-/)
	# ./node_modules/.bin(N-/) # don't work relative path. so this set automatically by chpwd
	# $HOME/.config/yarn/global/node_modules/.bin(N-/)
	# $HOME/.deno/bin(N-/)
	# $path
)
export PATH

# zsh function search path
fpath=(
	$HOME/.zfunc(N-/)
	$ZHOMEDIR/zfunc(N-/)
	$ZHOMEDIR/completions.local(N-/)
	$ZHOMEDIR/completions(N-/)
	/usr/local/share/zsh/site-functions(N-/)
	/usr/share/zsh/site-functions(N-/)
	$fpath
)
export FPATH
