
# コマンドラインがヒストリに追加される直前に実行
# ref: https://qiita.com/sho-t/items/d44bfbc783db7ca278c0

function zshaddhistory() {
	emulate -L zsh
	[[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
}
