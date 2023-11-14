#!/usr/bin/env bash

################
### Dotfiles ###
################
scriptpath="$( cd "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P )"
source "$scriptpath/stow-sources"

if ! command -v stow >/dev/null 2>&1; then
	echo 'FAILURE: stow is not installed'
	exit 1
fi

if [[ $# == 0 ]]; then
	stow -vR -t "$HOME" "${ALL_SOURCES[@]}"
fi

case "$1" in
	delete)
		stow -vD -t "$HOME" "${ALL_SOURCES[@]}"
		;;
	stow)
		shift
		stow -vR -t "$HOME" "$@"
		;;
	shell)
		stow -vR -t "$HOME" "${SHELL_SOURCES[@]}"
		;;
	general)
		stow -vR -t "$HOME" "${GENERAL_SOURCES[@]}"
		;;
	i3)
		stow -vR -t "$HOME" "${I3_SOURCES[@]}"
		;;
	sway)
		stow -vR -t "$HOME" "${SWAY_SOURCES[@]}"
		;;
	*)
		echo 'Unknown arg, no command run'
		;;
esac
