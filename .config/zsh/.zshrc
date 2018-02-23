antigen_init() {
	antigen use oh-my-zsh

	antigen theme nojhan/liquidprompt

	antigen bundle git
	antigen bundle pip
	antigen bundle lein
	antigen bundle command-not-found

	antigen bundle zsh-users/zsh-syntax-highlighting
	antigen bundle zsh-users/zsh-autosuggestions
	antigen bundle zsh-users/zsh-completions

	antigen apply
}

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
	if ! ssh-add -l >/dev/null; then
		ssh-add
	fi
}

load_functions() {
	local i;
	local files=( "$ZDOTDIR/functions"/*.zsh );
	if [ ! -z $files ]; then
		for i in $files; do
			. "$i"
		done
	fi
}

if [[ $- = *i* ]]; then
	# only interactive
	
	# load antigen
	. "$ZDOTDIR/antigen/antigen.zsh"
	antigen_init

	# load ssh-agent
	start_or_load_ssh_agent >/dev/null 2>&1
	load_ssh_keys

	# load custom functions
	load_functions
fi

# add config alias
alias c="git --git-dir=$HOME/.config/shell-config --work-tree=$HOME"
