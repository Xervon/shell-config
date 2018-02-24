## variables
ASDF="/opt/asdf"
ASDF_SOURCE="$ASDF/asdf.sh"
ASDF_COMPLETION="$ASDF/completions/asdf.bash"

## functions
antigen_init() {
	local cmd_antigen

	if ! {
		cmd_antigen="$(command -v antigen)" \
	}; then
		return 255
	fi

	"$cmd_antigen" use oh-my-zsh

	"$cmd_antigen" theme nojhan/liquidprompt

	"$cmd_antigen" bundle git
	"$cmd_antigen" bundle pip
	"$cmd_antigen" bundle lein
	"$cmd_antigen" bundle command-not-found

	"$cmd_antigen" bundle zsh-users/zsh-syntax-highlighting
	"$cmd_antigen" bundle zsh-users/zsh-autosuggestions
	"$cmd_antigen" bundle zsh-users/zsh-completions

	"$cmd_antigen" apply
}

start_or_load_ssh_agent() {
	local cmd_ssh_agent cmd_rm cmd_kill cmd_source

	if ! {
		cmd_ssh_agent="$(command -v ssh-agent)" \
		&& cmd_rm="$(command -v rm)" \
		&& cmd_kill="$(command -v kill)" \
		&& cmd_source="$(command -v source)" \
	}; then
		return 255
	fi

	local ssh_env="$HOME/.ssh/.env"

	if [[ -f "$ssh_env" ]]; then
		"$cmd_source" "$ssh_env"

		if ! "$cmd_kill" -CONT "$SSH_AGENT_PID"; then
			"$cmd_rm" -f "$ssh_env"
			start_or_load_ssh_agent
		fi

		return 0
	else
		"$cmd_ssh_agent" > "$ssh_env"
		"$cmd_source" "$ssh_env"
	fi
}

load_ssh_keys() {
	local cmd_ssh_add

	if ! {
		cmd_ssh_add="$(command -v ssh-add)" \
	}; then
		return 255
	fi

	if ! "$cmd_ssh_add" -l >/dev/null; then
		"$cmd_ssh_add"
	fi
}

load_functions() {
	local i files;

	files=( "$ZDOTDIR/functions"/*.zsh(N) );
	if [ ! -z $files ]; then
		for i in $files; do
			. "$i"
		done
	fi
}

[ -e "$ASDF_SOURCE" ] && . "$ASDF_SOURCE"

if [[ $- = *i* ]]; then
	# only interactive
	# set fpath
	fpath+="$HOME/.local/usr/share/zsh/site-functions"
	
	# load antigen
	. "$ZDOTDIR/antigen/antigen.zsh"
	antigen_init
	autoload -Uz compinit && compinit

	# load ssh-agent
	if start_or_load_ssh_agent >/dev/null 2>&1; then
		load_ssh_keys
	fi

	# load custom functions
	load_functions

	## completions
	[ -e "$ASDF_COMPLETION" ] && . "$ASDF_COMPLETION"
fi

## aliases
# add config alias
alias c="git --git-dir=$HOME/.config/shell-config --work-tree=$HOME"
