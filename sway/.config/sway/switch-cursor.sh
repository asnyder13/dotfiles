#!/usr/bin/env bash

set -euo pipefail
CURRENT_STATE_FILE="/tmp/sway_cursor_state"

if [ -f $CURRENT_STATE_FILE ] && [ "$(cat $CURRENT_STATE_FILE)" = "disable" ]; then
	swaymsg 'seat * hide_cursor when-typing enable'
	echo 'enable' > $CURRENT_STATE_FILE
else
	swaymsg 'seat * hide_cursor when-typing disable'
	echo 'disable' > $CURRENT_STATE_FILE
fi
