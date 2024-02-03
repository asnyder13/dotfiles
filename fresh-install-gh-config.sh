#!/usr/bin/env bash

# dotfiles
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
	read -rp 'Create new SSH key for Github? [Y/n]' createghssh
	createghssh=${createghssh:-'Y'}
	case "$createghssh" in
		y|Y)
			ssh-keygen -t ed25519 -a 100
			ssh-add ~/.ssh/id_ed25519
			read -rp "Enter the details of your \`~/.ssh/id_ed25519.pub\` to Github. Press key to continue." noop
	esac
fi

if [[ ! -d ".dotfiles" ]]; then
	git clone git@github.com:asnyder13/dotfiles.git .dotfiles
	cd .dotfiles/ || { echo 'Could not cd into .dotfiles'; exit 1; }
	chmod u+x install.sh
	./install.sh
	cd ~ || { echo 'Could not cd back to ~'; exit 1; }
fi
