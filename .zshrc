# Path to your oh-my-zsh installation.
export ZSH=/home/snyder/.oh-my-zsh
set -o vi
export EDITOR='vim'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnosterzak"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

plugins=(git extract safe-paste vi-mode)

# User configuration
 export PATH="$PATH:/usr/lib64/ccache:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/snyder/.rvm/bin:/home/snyder/.local/bin:/home/snyder/bin:./:/home/snyder/Android/sdk/platform-tools:/home/snyder/Android/sdk/tools:/home/snyder/Android/android-studio/bin"
export DEFAULT_USER='snyder'

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
# 	export EDITOR='vim'
# else
# 	export EDITOR='mvim'
# fi

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
if [ -f ~/.bash_aliases_local ]; then
	. ~/.bash_aliases_local
fi

function gi() { curl -sL https://www.gitignore.io/api/$@ ;}

_gitignoreio_get_command_list() {
	curl -sL https://www.gitignore.io/api/list | tr "," "\n"
}

_gitignoreio () {
	compset -P '*,'
	compadd -S '' `_gitignoreio_get_command_list`
}

compdef _gitignoreio gi

