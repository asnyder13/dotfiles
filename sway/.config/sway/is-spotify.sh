#!/bin/sh

if pgrep -x spotify >/dev/null; then
	echo 'spotify'
else
	echo ''
fi
