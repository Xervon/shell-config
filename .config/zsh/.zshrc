start_or_load_ssh_agent() {
	local ssh_env="$HOME/.ssh/.env"

	if [[ -f "$ssh_env" ]]; then
		. "$ssh_env"

		if ! kill -CONT "$SSH_AGENT_PID"; then
			rm -f "$ssh_env"
			start_or_load_ssh_agent
		fi

		return
	else
		ssh-agent > "$ssh_env"
		. "$ssh_env"
	fi
}

load_ssh_keys() {
	if ! ssh-add -l; then
		ssh-add
	fi
}

if [[ $- = *i* ]]; then
	# only interactive
	
	# load ssh-agent
	start_or_load_ssh_agent >/dev/null 2>&1
	load_ssh_keys
fi

# add config alias
alias c="git --git-dir=$HOME/.config/shell-config --work-tree=$HOME"
