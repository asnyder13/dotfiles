#!/usr/bin/env bash
# .bashrc

commonrc=${XDG_CONFIG_HOME:-$HOME/.config}/common/commonrc
if [[ -e $commonrc ]]; then
	source $commonrc
elif [[ -e $HOME/.commonrc ]]; then
	source $HOME/.commonrc
fi

# Source global definitions
if [[ -f /etc/bashrc ]]; then
	source /etc/bashrc
fi

export PS1="\[\e[00;35m\]\u\[\e[00;34m\]@\[\e[00;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;32m\][\w]\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;34m\]>\[\e[0m\]"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Local bashrc
if [[ -f ~/.bashrc_local ]]; then
	source ~/.bashrc_local
fi

# Set Readline's ignore case
# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [[ ! -a ~/.inputrc ]]; then
	echo '$include /etc/inputrc' > ~/.inputrc;
fi
if [[ ! $(grep 'set completion-ignore-case On' ~/.inputrc) ]]; then
	# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
	echo 'set completion-ignore-case On' >> ~/.inputrc
fi

if [[ -z "$NVM_DIR" ]]; then
	if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/nvm" ]]; then
		export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"
	elif [[ -d "$HOME/.nvm" ]]; then
		export NVM_DIR="$HOME/.nvm"
	elif (( $+commands[brew] )); then
		NVM_HOMEBREW="${NVM_HOMEBREW:-${HOMEBREW_PREFIX:-$(brew --prefix)}/opt/nvm}"
		if [[ -d "$NVM_HOMEBREW" ]]; then
			export NVM_DIR="$NVM_HOMEBREW"
		fi
	fi
fi
if [[ -n "$NVM_DIR" ]]; then
	ver_dir=$(fd -d1 -HI . "$NVM_DIR/versions/node" | sort -nr | head -1)
	PATH="$PATH:$ver_dir/bin"
fi

export HISTFILE="${XDG_STATE_HOME}"/bash/history
export HISTCONTROL=ignoredups
shopt -s histverify
