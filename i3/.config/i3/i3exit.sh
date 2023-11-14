#!/bin/sh
lock() {
	i3lock -c 3d3d3d
}

case "$1" in
	lock)
		lock
		;;
	logout)
		i3-msg exit
		;;
	suspend)
		lock && systemctl suspend
		;;
	hibernate)
		lock && systemctl hibernate
		;;
	reboot)
		systemctl reboot
		;;
	shutdown)
		systemctl poweroff
		;;
	*)
		echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
		exit 2
esac

exit 0
