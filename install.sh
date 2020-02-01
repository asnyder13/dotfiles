#!bash

# Dotfiles
DOTFILES=(
	.bashrc
	.bash_aliases
	.vimrc
	.zshrc
)

for DOTFILE in ${DOTFILES[*]}; do
	ln -sfv "$HOME/.dotfiles/$DOTFILE" "$HOME/$DOTFILE"
done

# Vim config
test -d ~/.vim || mkdir ~/.vim

# Vim theme
test -d ~/.vim/colors || mkdir ~/.vim/colors
test -e ~/.vim/colors/monokai.vim || wget -O ~/.vim/colors/monokai.vim https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim

# Vim plugins
GITHUB="https://github.com/"
PLUGINS=(
	vim-airline/vim-airline
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
(cd ~/.vim/pack/packs/start
	for PLUG in ${PLUGINS[*]}; do
		git clone "$GITHUB$PLUG"
	done
	for NEWPLUG in `find . -maxdepth 1 -type d | grep -Pv '^\.$'`; do
		vim -u NONE -c "helptags $NEWPLUG/doc" -c q
	done
)

