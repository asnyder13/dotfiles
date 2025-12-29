
if [[ "$XDG_SESSION_TYPE" = "wayland" ]]; then
	export QT_QPA_PLATFORM=wayland
	export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
	export GDK_BACKEND=wayland
fi

# if [[ -z $TMUX ]]; then
# 	start-sway
# fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
