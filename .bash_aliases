# No shebang since this can be read from either bash or zsh.

alias list='ls -g --human-readable --no-group --almost-all --classify --time-style=long-iso --color' ;
alias list2='ls -g --human-readable --no-group --classify --time-style=long-iso --color' ;
alias ll='ls -l --human-readable --almost-all --classify --time-style=long-iso --color' ;

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
source $HOME/.dotfiles/.DOTFILES
i=0
end=${#DOTFILES[@]}
# zsh is 1-indexed
if [[ -n "$ZSH_VERSION" ]]; then i=1; (( end++ )); fi
for (( i; i < end; i++ )); do
	DOTFILES[i]="$HOME/.dotfiles/${DOTFILES[i]}"
done
if [ -f ~/.bashrc_local ]; then DOTFILES+=("$HOME/.bashrc_local"); fi
if [ -f ~/.bash_aliases_local ]; then DOTFILES+=("$HOME/.bash_aliases_local"); fi
CONFIGFILES=(
	install.sh
	.DOTFILES
)
for CONFIG in ${CONFIGFILES[@]}; do
	DOTFILES+=("$HOME/.dotfiles/$CONFIG")
done
# Only gonna work if you've installed in ~/.dotfiles
alias editrcs="vim +'set autochdir' ${DOTFILES[*]}"

# General aliases.
alias lssz='du -sh *' ;
alias tmat='tmux attach' ;
alias df='df -h' ;
alias wttr='curl --compressed "wttr.in/Charlotte?F&q"' ;
alias rsync='rsync --archive --progress --human-readable --stats' ;
alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias .....='cd .....'
alias ......='cd ......'

# Git aliases.
alias g='git'
alias ga='git add'
alias gst='git status'
alias gsts='git status --branch --short'
alias gd='git diff --ignore-all-space --diff-filter=adr --color-words'
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

# Random functions
function mkcd () {
	mkdir "$1"
	cd "$1" || return 1
	return 0
}

function vimhelp () {
	vim -c "help $1 | only"
}

function toyaml () {
	if ! command -v ruby >/dev/null 2>&1; then
		echo 'You need Ruby to run this function.'
		return 1
	fi

	if [[ $# -gt 0 ]]; then
		if [[ ! -f $1 ]]; then
			echo 'That file does not exist to parse.'
			return 1
		else
			ruby -ryaml -rjson -e "puts YAML.dump(JSON.parse(File.read(\"$1\")))"
		fi
	else
		ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse($<.read))'
	fi
}

function tojson () {
	if ! command -v ruby >/dev/null 2>&1; then
		echo 'You need Ruby to run this function.'
		return 1
	fi

	if [[ $# -gt 0 ]]; then
		if [[ ! -f $1 ]]; then
			echo 'That file does not exist to parse.'
			return 1
		else
			ruby -ryaml -rjson -e "puts JSON.pretty_generate(YAML.safe_load(File.read(\"$1\")))"
		fi
	else
		ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.safe_load($<.read))'
	fi
}
