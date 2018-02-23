## variables
ASDF="/opt/asdf"
ASDF_SOURCE="$ASDF/asdf.sh"
ASDF_COMPLETION="$ASDF/completions/asdf.bash"

## functions
antigen_init() {
	local antigen="$(command -v antigen)"

	if [ ! -x "$antigen" ]; then
		return 255
	fi

	$antigen use oh-my-zsh

	$antigen theme nojhan/liquidprompt

	$antigen bundle git
	$antigen bundle pip
	$antigen bundle lein
	$antigen bundle command-not-found

	$antigen bundle zsh-users/zsh-syntax-highlighting
	$antigen bundle zsh-users/zsh-autosuggestions
	$antigen bundle zsh-users/zsh-completions

	$antigen apply
}

start_or_load_ssh_agent() {
	local ssh_agent="$(command -v ssh-agent)"
	local rm="$(command -v rm)"

	if [ ! -x "$ssh_agent" ] || [ ! -x "$rm" ]; then
		return 255
	fi

	local ssh_env="$HOME/.ssh/.env"

	if [[ -f "$ssh_env" ]]; then
		. "$ssh_env"

		if ! kill -CONT "$SSH_AGENT_PID"; then
			$rm -f "$ssh_env"
			start_or_load_ssh_agent
		fi

		return 0
	else
		$ssh_agent > "$ssh_env"
		. "$ssh_env"
	fi
}

load_ssh_keys() {
	local ssh_add="$(command -v ssh-add)"

	if [ ! -x "$ssh_add" ]; then
		return 255
	fi

	if ! ssh-add -l >/dev/null; then
		$ssh_add
	fi
}

load_functions() {
	local i;
	local files=( "$ZDOTDIR/functions"/*.zsh(N) );
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
