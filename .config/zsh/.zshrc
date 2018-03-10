if ! cmd_source="$(command -v source)"; then
	echo "no source!"
	exit 255
fi

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
	local cmd_ssh_agent cmd_rm cmd_kill

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
			"$cmd_source" "$i"
		done
	fi
}

# set XDG_ variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# set histfile
export HISTFILE="$XDG_DATA_HOME/zsh/history"

# load asdf
[ -e "$ASDF_SOURCE" ] && "$cmd_source" "$ASDF_SOURCE"

if [[ $- = *i* ]]; then
	# only interactive
	# set fpath
	fpath+="$HOME/.local/usr/share/zsh/site-functions"
	
	# load antigen
	"$cmd_source" "$ZDOTDIR/antigen/antigen.zsh"
	antigen_init
	autoload -Uz compinit && compinit

	# load ssh-agent
	if start_or_load_ssh_agent >/dev/null 2>&1; then
		load_ssh_keys
	fi

	# load custom functions
	load_functions

	## completions
	[ -e "$ASDF_COMPLETION" ] && "$cmd_source" "$ASDF_COMPLETION"
fi

# Set vimrc's location and source it on vim startup
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/nvim/init.vim" | source $MYVIMRC'

## aliases
# add config alias
alias c="git --git-dir=$HOME/.config/shell-config --work-tree=$HOME"

## load local .zshrc if available
if [ -e "$HOME/.zshrc.local" ]; then
	"$cmd_source" "$HOME/.zshrc.local"
else
	true
fi
