# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PS1="\[\e[00;35m\]\u\[\e[00;34m\]@\[\e[00;35m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;32m\][\w]\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;34m\]>\[\e[0m\]"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Local bashrc
if [ -f ~/.bashrc_local ]; then
	. ~/.bashrc_local
fi

# Set Readline's ignore case
# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc

source "~/.commonrc"
