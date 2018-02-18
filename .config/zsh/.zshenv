ADOTDIR="$ZDOTDIR/.antigen"

EDITOR="$(command -v nvim)"
EDITOR="${EDITOR:-$(command -v vim)}"
EDITOR="${EDITOR:-$(command -v vi)}"
VISUAL="$EDITOR"

PATH="$HOME/bin:$HOME/.bin:$HOME/.local/bin:$PATH"
