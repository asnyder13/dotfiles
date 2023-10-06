#!/usr/bin/env bash
# .bashrc

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

if [[ -d "$HOME/.nvm" ]]; then
	export NVM_DIR="$HOME/.nvm"
	if [[ -f "$NVM_DIR/nvm.sh" ]]; then
		source "$NVM_DIR/nvm.sh"  # This loads nvm
	fi
	if [[ -f "$NVM_DIR/bash_completion"  ]]; then
		source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	fi
fi

export HISTCONTROL=ignoredups
shopt -s histverify

source ~/.commonrc
