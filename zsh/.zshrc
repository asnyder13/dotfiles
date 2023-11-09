# zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:rvm' lazy yes
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	dotnet
	extract
	fd
	git
	ng
	npm
	nvm
	ripgrep
	rvm
	safe-paste
	sudo
	vi-mode
	zbell
	# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	zsh-syntax-highlighting
)
zbell_ignore=(
	$EDITOR
	$PAGER
	nvim
	vim
	less
	tail
	editrcs
	tmux
	irb
	fg
	nload
	htop
	timer
)
# By default don't pop up notify
zbell_use_notify_send=false
# Fedora/Gnome terminal doesn't do `print -n '\a'`?  In that case just paplay some sound.
zbell_use_paplay=false

if [[ -e $ZSH/oh-my-zsh.sh ]]; then
	source $ZSH/oh-my-zsh.sh
fi

# User configuration
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS

# export MANPATH="/usr/local/man:$MANPATH"
export DEFAULT_USER='snyder'

### Fancier cursor switching for vim-mode.
_cursor_line() { echo -ne '\e[5 q' }
_cursor_block() { echo -ne '\e[1 q' }
# Starts in insert
precmd_functions+=(_cursor_line)

# Remove mode switching delay.
KEYTIMEOUT=15

# Change cursor shape for different vi modes.
function zle-keymap-select {
	case ${KEYMAP} in
		vicmd)
			_cursor_block
			;;
		main | viins | '')
			_cursor_line
			;;
	esac
}
zle -N zle-keymap-select

# Allow editing commands in vim
autoload -U edit-command-line
zle -N edit-command-line
# Emacs style
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
# Vi style
bindkey -M vicmd '^xe' edit-command-line
bindkey -M vicmd '^x^e' edit-command-line

# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		BUFFER="fg"
		zle accept-line
	else
		zle push-input
		# zle clear-screen
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

bindkey '^Xa' _expand_alias

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
#
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

if [[ -e $HOME/.commonrc ]]; then
	source $HOME/.commonrc
fi
if [[ -e $HOME/.zshrc_local ]]; then
	source $HOME/.zshrc_local
fi

if [[ -e $HOME/.fzf.zsh ]]; then
	export FZF_DEFAULT_COMMAND="command fd -L . -tf --hidden | cut -b3-"
	export FZF_CTRL_T_COMMAND="command fd -L . --min-depth 1 -tf -td -tl 2> /dev/null | cut -b3-"
	export FZF_ALT_C_COMMAND="command fd -L . --min-depth 1 -td 2> /dev/null | cut -b3-"
	source $HOME/.fzf.zsh
fi

# zprof
