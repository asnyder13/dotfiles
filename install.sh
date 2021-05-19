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

	mkdir -p "$linkpath"
	ln -sfv "$scriptpath/$dotfile" "$linkfile"
}

if [[ ${#DOTFILES[@]} -ne ${#DOTFILE_LINKS[@]} ]]; then
	echo 'The arrays in .DOTFILES are not the same length'
	exit 1
fi
for ((i = 0; i < ${#DOTFILES[@]}; i++)); do
	link_dotfile ${DOTFILES[i]} ${DOTFILE_LINKS[i]}
done

has_vim=$(command -v vim)
has_neovim=$(command -v nvim)

if [[ has_neovim ]]; then
	if ! command -v git >/dev/null 2>&1; then
		echo 'You need git to retrieve Paq.'
		exit 1
	fi

	paq_loc="$HOME/.local/share/nvim/site/pack/paqs/opt/paq-nvim"
	if [[ ! -d "$paq_loc" ]]; then
		echo 'Cloning Paq'
		git clone -q https://github.com/savq/paq-nvim.git "$paq_loc"
	else
		echo 'Paq is already installed, run :PaqInstall or :PaqUpdate'
	fi
elif [[ has_vim ]]; then
	# Vim theme
	if command -v wget >/dev/null 2>&1;   then fetcher='wget -O'
	elif command -v curl >/dev/null 2>&1; then fetcher='curl -o'
	fi

	mkdir -p ~/.vim/colors
	test -e ~/.vim/colors/monokai.vim || $fetcher ~/.vim/colors/monokai.vim https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim

	# General plugins
	plugins=(
		vim-airline/vim-airline
		ntpeters/vim-better-whitespace
		tpope/vim-commentary
		ctrlpvim/ctrlp.vim
		easymotion/vim-easymotion
		airblade/vim-gitgutter
		machakann/vim-highlightedyank
		adelarsq/vim-matchit
		sheerun/vim-polyglot
		vim-scripts/ReplaceWithRegister
		ngmy/vim-rubocop
		justinmk/vim-sneak
		kshenoy/vim-signature
		tpope/vim-surround
		tpope/vim-vinegar
	)

	if ! command -v git >/dev/null 2>&1; then
		echo 'You need git to retrieve the plugins.'
		exit 1
	fi

	# Clone a plugin
	# param $1: base dir
	# param $2: plugin github
	clone_plugin () {
		local plugdir=$(echo "$2" | cut -f2 -d/);
		(cd "$1" || exit 1
			if [[ ! -d $plugdir ]]; then
				echo "Cloning:  $2"
				git clone -q --depth=1 "https://github.com/$2"
			else
				(cd "$plugdir" || exit 1
					echo "Updating: $2"
					git pull -q
				)
			fi

			vim -u NONE -c "helptags $plugdir/doc" -c q
		)
	}

	# Iterate the list of plugins and clone.
	# $1 config location
	# $2 plugin list
	install_plugins () {
		config="$1"
		mkdir -p "$config"
		shift
		plugins=("$@")
		for plug in "${plugins[@]}"; do
			clone_plugin "$config" "$plug"
		done
	}

	vim_config="$HOME/.vim/pack/packs/start"
	# Regular vim plugins
	install_plugins "$vim_config" "${plugins[@]}"
fi
