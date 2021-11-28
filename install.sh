#!/usr/bin/env bash

################
### Dotfiles ###
################
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
	echo 'The arrays in .DOTFILES are not the same length.'
	exit 1
fi
for ((i = 0; i < ${#DOTFILES[@]}; i++)); do
	link_dotfile ${DOTFILES[i]} ${DOTFILE_LINKS[i]}
done

####################
### n/vim setup. ###
####################
if command -v nvim >/dev/null 2>&1; then
	echo 'Found neovim.'
	if ! command -v git >/dev/null 2>&1; then
		echo 'You need git to retrieve Paq.'
		exit 1
	fi

	paq_loc="$HOME/.local/share/nvim/site/pack/paqs/opt/paq-nvim"
	if [[ ! -d "$paq_loc" ]]; then
		echo 'Cloning Paq.'
		git clone -q https://github.com/savq/paq-nvim.git "$paq_loc"
	else
		echo 'Paq is already installed, run :PaqInstall or :PaqUpdate.'
	fi
elif command -v vim >/dev/null 2>&1; then
	echo 'Found vim.'
	# Vim theme
	if command -v wget >/dev/null 2>&1;   then fetcher='wget -O'
	elif command -v curl >/dev/null 2>&1; then fetcher='curl -o'
	else
		echo 'wget nor curl are installed!'
		exit 1
	fi

	mkdir -p ~/.vim/colors
	test -e ~/.vim/colors/monokai.vim || $fetcher ~/.vim/colors/monokai.vim https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim

	# General plugins
	plugins=(
		vim-airline/vim-airline
		ntpeters/vim-better-whitespace
		tpope/vim-commentary
		ctrlpvim/ctrlp.vim
		justinmk/vim-dirvish
		easymotion/vim-easymotion
		tpope/vim-fugitive
		airblade/vim-gitgutter
		machakann/vim-highlightedyank
		adelarsq/vim-matchit
		sheerun/vim-polyglot
		vim-scripts/ReplaceWithRegister
		ngmy/vim-rubocop
		vim-ruby/vim-ruby
		justinmk/vim-sneak
		kshenoy/vim-signature
		tpope/vim-sleuth
		AndrewRadev/splitjoin.vim
		tpope/vim-surround
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
else
	echo "Didn't find either neovim nor vim."
fi

#####################
### zsh specifics ###
#####################
if command -v zsh >/dev/null 2>&1; then
	echo 'zsh is installed'

	if command -v wget >/dev/null 2>&1;   then fetcher='wget -O-'
	elif command -v curl >/dev/null 2>&1; then fetcher='curl -fsSL'
	else
		echo 'wget nor curl are installed!'
		exit 1
	fi

	### oh-my-zsh
	if [[ ! -f "~/.oh-my-zsh" ]]; then
		omz_get="$fetcher https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
		export CHSH=yes
		export RUNZSH=no
		export KEEP_ZSHRC=yes
		sh -c "$($omz_get)"
	fi

	### Extra plugins
	if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
		echo 'Fetching zsh-syntax-highlighting'
		git clone \
			https://github.com/zsh-users/zsh-syntax-highlighting.git \
			${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	else
		echo 'zsh-syntax-highlighting already present'
	fi
else
	echo 'zsh not installed'
fi
