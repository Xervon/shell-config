# set dotdir for antigen
ADOTDIR="$ZDOTDIR/.antigen"

# set $EDITOR and $VISUAL
EDITOR="$(command -v nvim)"
EDITOR="${EDITOR:-$(command -v vim)}"
EDITOR="${EDITOR:-$(command -v vi)}"
VISUAL="$EDITOR"

# set $PATH
PATH="$HOME/bin:$HOME/.bin:$HOME/.local/bin:$PATH"
