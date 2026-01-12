#!/usr/bin/env bash

source ./common/.xdg_fixes

if ! command -v git >/dev/null 2>&1; then
	echo 'FAILURE: You need git.'
	exit 1
fi

if command -v wget >/dev/null 2>&1;   then fetcher='wget -O'
elif command -v curl >/dev/null 2>&1; then fetcher='curl -fsSLo'
else
	echo 'FAILURE: wget nor curl are installed.'
	exit 1
fi

####################
### n/vim setup. ###
####################
if command -v nvim >/dev/null 2>&1; then
	echo 'Found neovim.'

	echo "Neovim will bootstrap it's own package manager."
elif command -v vim >/dev/null 2>&1; then
	echo 'Found vim.'
	# Vim theme
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

	### oh-my-zsh
	export ZSH=$XDG_DATA_HOME/oh-my-zsh
	ZSH_CUSTOM=${ZSH_CUSTOM:-$XDG_DATA_HOME/oh-my-zsh/custom}
	if [[ ! -d $ZSH ]]; then
		omz_get="$fetcher- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
		export CHSH=yes
		export RUNZSH=no
		export KEEP_ZSHRC=yes
		sh -c "$($omz_get)"
	else
		echo "ohmyzsh present at $ZSH"
	fi

	### Extra plugins
	zsh_highlight_loc="$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
	if [[ ! -d $zsh_highlight_loc ]]; then
		echo 'Fetching fast-syntax-highlighting'
		git clone \
			https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
			"$zsh_highlight_loc"
	else
		echo 'fast-syntax-highlighting already present'
	fi

	zsh_autosuggest_loc="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
	if [[ ! -d $zsh_autosuggest_loc ]]; then
		echo 'Fetching zsh-autosuggestions'
		git clone \
			https://github.com/zsh-users/zsh-autosuggestions.git \
			"$zsh_autosuggest_loc"
	else
		echo 'zsh-autosuggestions already present'
	fi

	spaceship_loc="$ZSH_CUSTOM/themes/spaceship-prompt"
	if [[ ! -d $spaceship_loc ]]; then
		echo 'Fetching spaceship-prompt'
		git clone \
			https://github.com/spaceship-prompt/spaceship-prompt.git \
			"$spaceship_loc"
	else
		echo 'spaceship-prompt already present'
	fi
	ln -vfs "$spaceship_loc/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

	if ! grep --quiet --no-messages ZDOTDIR /etc/zshenv; then
		echo '/ect/zshenv is missing the ZDOTDIR export (reproduced in this script)'

		# export XDG_DATA_HOME="$HOME/.local/share"
		# export XDG_CONFIG_HOME="$HOME/.config"
		# export XDG_STATE_HOME="$HOME/.local/state"
		# export XDG_CACHE_HOME="$HOME/.cache"
		#
		# if [[ ! -d "$XDG_CONFIG_HOME"/zsh ]]; then
		# 	mkdir -p "$XDG_CONFIG_HOME"/zsh
		# fi
		# if [[ ! -d "$XDG_CACHE_HOME"/zsh ]]; then
		# 	mkdir -p "$XDG_CACHE_HOME"/zsh
		# fi
		#
		# export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
	fi
else
	echo 'zsh not installed'
fi
