# .bashrc
set -o vi
export EDITOR='vim'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PS1="\[\e[00;35m\]\u\[\e[00;34m\]@\[\e[00;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;32m\][\w]\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;34m\]>\[\e[0m\]"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
if [ -f ~/.bash_aliases_local ]; then
	. ~/.bash_aliases_local
fi
if [ -f ~/.bashrc_local ]; then
	. ~/.bashrc_local
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
