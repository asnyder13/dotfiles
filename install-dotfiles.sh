#!/usr/bin/env bash

################
### Dotfiles ###
################
scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P )"
source "$scriptpath/stow-sources"

if command -v stow >/dev/null 2>&1; then
	stow -vR -t "$HOME" "${STOW_SOURCES[@]}"
else
	echo 'FAILURE: stow is not installed'
	exit 1
fi

