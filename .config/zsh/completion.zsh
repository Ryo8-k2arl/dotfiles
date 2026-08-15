#=================================================================================================#
##                                Completion                                                     ##
#=================================================================================================#

autoload -Uz compinit

if [[ ! -d "$ZCACHEDIR" ]]; then
	mkdir -p -- "$ZCACHEDIR"
fi

compinit -d "$ZCACHEDIR/zcompdump"

# Task runner
function _setup_task_completion() {
	local task_command

	if builtin command -v task > /dev/null 2>&1; then
		task_command=task
	elif builtin command -v go-task > /dev/null 2>&1; then
		task_command=go-task
	else
		return
	fi

	TASK_EXE="$task_command" eval "$("$task_command" --completion zsh)"
}

_setup_task_completion
unfunction _setup_task_completion
