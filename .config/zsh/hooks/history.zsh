
# コマンドラインがヒストリに追加される直前に実行

function zshaddhistory() {
	emulate -L zsh
	[[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
}
