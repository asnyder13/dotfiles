# .bashrc
set -o vi
export EDITOR='vim'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PS1="\[\e[00;35m\]\u\[\e[00;34m\]@\[\e[00;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;32m\][\w]\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;34m\]>\[\e[0m\]"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
function gi() { curl -sL https://www.gitignore.io/api/$@ ;}

_gitignoreio_get_command_list() {
	curl -sL https://www.gitignore.io/api/list | tr "," "\n"
}

_gitignoreio () {
	compset -P '*,'
	compadd -S '' `_gitignoreio_get_command_list`
}

compdef _gitignoreio gi

# Aliases/Local Aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
if [ -f ~/.bash_aliases_local ]; then
	. ~/.bash_aliases_local
fi
# Local bashrc
if [ -f ~/.bashrc_local ]; then
	. ~/.bashrc_local
fi

