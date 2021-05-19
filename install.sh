#!/usr/bin/env bash

# Dotfiles
scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P )"
source "$scriptpath/.DOTFILES"

# Link a dot file
# $1 dotfile name
# $2 link location (default: $HOME)
link_dotfile () {
	local dotfile=$1
	local linkpath=${2:-$HOME}
	local linkfile="$linkpath/$dotfile"

	if [[ -L $linkfile ]]; then
		printf "%s is already linked\n" "$linkfile"
		return 0
	elif [[ ! -L $linkfile && -f $linkfile ]]; then
		printf "%s renamed to %s-bkup\n" "$linkfile" "$linkfile"
		cp "$linkfile" "$linkfile-bkup"
	fi

	ln -sfv "$scriptpath/$dotfile" "$linkfile"
}

if [[ ${#DOTFILES[@]} -ne ${#DOTFILE_LINKS[@]} ]]; then
	echo 'The arrays in .DOTFILES are not the same length'
	exit 1
fi
for ((i = 0; i < ${#DOTFILES[@]}; i++)); do
	link_dotfile ${DOTFILES[i]} ${DOTFILE_LINKS[i]}
done

### Vim config
# Vim theme
if command -v wget >/dev/null 2>&1;   then fetcher='wget -O'
elif command -v curl >/dev/null 2>&1; then fetcher='curl -o'
fi

mkdir -p ~/.vim/colors
test -e ~/.vim/colors/monokai.vim || $fetcher ~/.vim/colors/monokai.vim https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim

# General plugins
plugins=(
	ntpeters/vim-better-whitespace
	tpope/vim-commentary
	airblade/vim-gitgutter
	machakann/vim-highlightedyank
	sheerun/vim-polyglot
	vim-scripts/ReplaceWithRegister
	ngmy/vim-rubocop
	justinmk/vim-sneak
	kshenoy/vim-signature
	tpope/vim-surround
	tpope/vim-vinegar
)

# Regular Vim specific
vim_plugins=(
	vim-airline/vim-airline
	ctrlpvim/ctrlp.vim
	easymotion/vim-easymotion
	adelarsq/vim-matchit
)

# Neovim specific
neovim_plugins=(
	norcalli/nvim-colorizer.lua
	ojroques/nvim-hardline
	phaazon/hop.nvim
	nvim-lua/plenary.nvim
	nvim-lua/popup.nvim
	nvim-telescope/telescope.nvim
)

if ! command -v git >/dev/null 2>&1; then
	echo 'You need git to retrieve the plugins.'
	exit 1
fi

# Clone a plugin
# param $1: base dir
# param $2: plugin github
clone_plugin () {
	(cd "$1" || exit 1
		local plugdir=$(echo "$2" | cut -f2 -d/);
		if [[ ! -d $plugdir ]]; then
			git clone --depth=1 "https://github.com/$2"
			vim -u NONE -c "helptags $plugdir/doc" -c q
		fi
	)
}

vim_config="$HOME/.vim/pack/packs/start"
if command -v vim >/dev/null 2>&1 || command -v nvim >/dev/null 2>&1; then
	mkdir -p "$vim_config"
	for plug in ${plugins[*]}; do
		clone_plugin "$vim_config" "$plug"
	done
fi

if command -v nvim >/dev/null 2>&1; then
	# Neovim plugins
	neovim_config="$HOME/.local/share/nvim/site/start"
	mkdir -p "$neovim_config"
	for plug in ${neovim_plugins[*]}; do
		clone_plugin "$neovim_config" "$plug"
	done
elif command -v vim >/dev/null 2>&1; then
	# Regular vim plugins
	mkdir -p "$vim_config"
	for plug in ${vim_plugins[*]}; do
		clone_plugin "$vim_config" "$plug"
	done
fi

