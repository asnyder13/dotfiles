alias list='ls -g --human-readable --no-group --almost-all --classify --time-style=long-iso' ;
alias list2='ls -g --human-readable --no-group --classify --time-style=long-iso' ;
alias ll='ls -l --human-readable --almost-all --classify --time-style=long-iso' ;

# Old shortcuts from yum
alias dnfs='sudo dnf search' ;
alias dnfi='sudo dnf install' ;
alias dnfu='sudo dnf update' ;
alias dnfe='sudo dnf erase' ;
alias yums='sudo dnf search' ;
alias yumi='sudo dnf install' ;
alias yumu='sudo dnf update' ;
alias yume='sudo dnf erase' ;

# Alias editing these files.
# Get current dotfile list.
source ~/.dotfiles/.DOTFILES
i=0
end=${#DOTFILES[*]}
# zsh is 1-indexed
if [ -n "$ZSH_VERSION" ]; then i=1; (( end++ )); fi
for (( i; i<end; i++ )); do
	DOTFILES[i]="$DEFAULT_DOTFILES/${DOTFILES[i]}"
done
if [ -f ~/.bashrc_local ]; then DOTFILES+=("~/.bashrc_local"); fi
if [ -f ~/.bash_aliases_local ]; then DOTFILES+=("~/.bash_aliases_local"); fi
CONFIGFILES=(
	install.sh
	.DOTFILES
)
for CONFIG in ${CONFIGFILES[*]}; do
	DOTFILES+=("$DEFAULT_DOTFILES/$CONFIG")
done
alias editrcs="vim ${DOTFILES[*]}"

# General aliases.
alias lssz='du -sh *' ;
alias tmat='tmux attach' ;
alias df='df -h' ;
alias wttr='curl --compressed wttr.in/Charlotte?F&q' ;
alias rsync='rsync --recursive --progress --human-readable --stats' ;
alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias .....='cd .....'
alias ......='cd ......'

# Git aliases.
alias g='git'
alias ga='git add'
alias gst='git status'
alias gd='git diff --ignore-all-space --diff-filter=adr'
alias gco='git checkout'
alias gb='git branch'
alias gc='git commit -v'
alias gl='git pull'
alias gp='git push'
alias gm='git merge --no-ff'
alias gmff='git merge --ff-only'
alias gf='git fetch -v'
alias gt='git tag'
alias gwt='git worktree'
alias gbl='git blame -cw'
alias gcp='git cherry-pick'

