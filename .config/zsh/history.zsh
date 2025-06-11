#=================================================================================================#
##					History							 ##
#=================================================================================================#

HISTFILE="${ZDATADIR}/zsh_history"
HISTSIZE=10000                    		# Number of histories in memory
SAVEHIST=100000                   		# Number of histories to be saved
HISTORY_IGNORE="(l[sal\.]|cd|pwd|zsh|exit|cd ..)"


## ref:
##		https://qiita.com/sho-t/items/d553dd694900cae0966d

setopt extended_history				# 開始時刻(タイムスタンプ)、経過秒数も保存
setopt hist_allow_clobber			# リダイレクト > したとき、履歴上で |> に置換（リダイレクトしないようにする）
setopt hist_find_no_dups			# 履歴検索時に以前見たものを2度は表示しない
setopt hist_ignore_all_dups			# 履歴にあるコマンドと同じコマンドは履歴に保存しない
setopt hist_ignore_dups				# 直前のコマンドと同じコマンドは履歴に保存しない
setopt hist_ignore_space			# 行頭がスペースのコマンドは履歴に保存しない
setopt hist_no_functions			# ヒストリから関数定義を除去する
setopt hist_no_store				# ヒストリコマンドをヒストリから取り除く

setopt hist_reduce_blanks			# ヒストリ保存時に余分な空白を除去する
setopt hist_save_no_dups			# ヒストリファイルに書き出すときに以前のコマンドと同じものを除去する
setopt hist_verify				# ヒストリコマンドを直接実行しない
setopt inc_append_history_time			# コマンド終了時に、履歴ファイルに書き込む
