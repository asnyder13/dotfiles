#!/usr/bin/env bash

# Dotfiles
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P )"
DOTFILES=(
	.bashrc
	.bash_aliases
	.vimrc
	.zshrc
	.tmux.conf
)

LINKDIR="$HOME"
if [[ $# -eq 1 ]]; then
	LINKDIR=$1
fi
for DOTFILE in ${DOTFILES[*]}; do
	LINKFILE="$LINKDIR/$DOTFILE"
	if [[ -L $LINKFILE ]]; then
		printf "%s is already linked\n" "$LINKFILE"
		continue
	elif [[ ! -L $LINKFILE && -f $LINKFILE ]]; then
		printf "%s renamed to %s-bkup\n" "$LINKFILE" "$LINKFILE"
		cp "$LINKFILE" "$LINKFILE-bkup"
	fi

	ln -sfv "$SCRIPTPATH/$DOTFILE" "$LINKFILE"
done

# Vim config
test -d ~/.vim || mkdir ~/.vim

# Vim theme
test -d ~/.vim/colors || mkdir ~/.vim/colors
test -e ~/.vim/colors/monokai.vim || wget -O ~/.vim/colors/monokai.vim https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim

# Vim plugins
PLUGINS=(
	vim-airline/vim-airline
	ntpeters/vim-better-whitespace
	ctrlpvim/ctrlp.vim
	easymotion/vim-easymotion
	airblade/vim-gitgutter
	yggdroot/indentline
	sheerun/vim-polyglot
	vim-scripts/ReplaceWithRegister
	justinmk/vim-sneak
	tpope/vim-surround
	tpope/vim-vinegar
)

test -d ~/.vim/pack || mkdir ~/.vim/pack
test -d ~/.vim/pack/packs || mkdir ~/.vim/pack/packs
test -d ~/.vim/pack/packs/start || mkdir ~/.vim/pack/packs/start

(cd ~/.vim/pack/packs/start || exit 1
	# Per-repo plugins
	for PLUG in ${PLUGINS[*]}; do
		PLUGDIR=$(echo "$PLUG" | cut -f2 -d/)
		if [[ ! -d $PLUGDIR ]]; then
			git clone "https://github.com/$PLUG"
			vim -u NONE -c "helptags $PLUGDIR/doc" -c q
		fi
	done
)

