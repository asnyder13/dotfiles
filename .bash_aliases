alias list='ls -lhgGAF --time-style=long-iso' ;

# Old shortcuts from yum
alias dnfs='sudo dnf search' ;
alias dnfi='sudo dnf install' ;
alias dnfu='sudo dnf update' ;
alias dnfe='sudo dnf erase' ;
alias yums='sudo dnf search' ;
alias yumi='sudo dnf install' ;
alias yumu='sudo dnf update' ;
alias yume='sudo dnf erase' ;

# Get current dotfile list.
source .dotfiles/.DOTFILES
i=0
# zsh is 1-indexed
if [ -n "$ZSH_VERSION" ]; then i=1; fi
for (( i=1; i<=${#DOTFILES[*]}; i++ )); do
	DOTFILES[i]="$DEFAULT_DOTFILES/${DOTFILES[i]}"
done
DOTFILES+="$DEFAULT_DOTFILES/install.sh"
DOTFILES+="$DEFAULT_DOTFILES/.DOTFILES"
alias editrcs="vim ${DOTFILES[*]}"

alias lssz='du -sh *' ;
alias tmat='tmux attach' ;
alias df='df -h' ;
alias wttr='curl --compressed wttr.in/Charlotte?F&q' ;
alias rsync='rsync --recursive --progress --human-readable --stats' ;

