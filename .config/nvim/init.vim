" vim XDG paths
if ! has('nvim')
	set directory=$XDG_CACHE_HOME/vim,/tmp
	set backupdir=$XDG_CACHE_HOME/vim,/tmp
	set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
	set runtimepath=$XDG_CONFIG_HOME/nvim,$XDG_CONFIG_HOME/nvim/after,$VIM,$VIMRUNTIME
	let $MYVIMRC="$XDG_CONFIG_HOME/nvim/init.vim"
endif

runtime bundle/tpope\:vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
