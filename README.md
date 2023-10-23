# My dotfiles

## Requirements
* GNU stow

## Installation
### All dotfiles
1. Source stow sources `source stow-sources`
2. Run stow on all sources `stow -vR -t "$HOME" "${STOW_SOURCES[@]}"`
### Some dotfiles
1. Run stow for sources you want `stow -vR -t "$HOME" zsh nvim`

## How GNU Stow works
Say you have your dotfiles here in this repo like `./tmux/.config/tmux/tmux.conf`.

When stow is run on a dir here, ex: `stow -t ~ tmux`, it will link your files in that structure under the target (`-t`) dir.

So now in `~`, there is a link to `~/.config/tmux/tmux.conf`.

If you have existing files in those locations, stow will fail and not make any links.
