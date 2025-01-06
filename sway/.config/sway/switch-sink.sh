#! /usr/bin/env bash

headset=$(pactl list sinks | awk '/Name: alsa_output.pci.+analog-stereo/ {print $2}')

if [[ ${#headset[@]} -gt 1 ]]; then
	message="More than one analog-stereo sink"
else
	sinks=(alsa_output.usb-Kingston_HyperX_7.1_Audio_00000000-00.analog-stereo)
	sinks+=("${headset[@]}")
	current_sink=$(pactl get-default-sink)
	message=
	case $current_sink in
		"${sinks[0]}")
			pactl set-default-sink "${sinks[1]}"
			message="Output set to ${sinks[1]}"
			;;
		"${sinks[1]}")
			pactl set-default-sink "${sinks[0]}"
			message="Output set to ${sinks[0]}"
			;;
		*)
			message="Unknown current sink: $current_sink"
			;;
	esac
fi

notify-send \
	--app-name sway \
	--expire-time 3000 \
	--transient \
	--icon /usr/share/icons/Adwaita/symbolic/devices/audio-headphones-symbolic.svg \
	"${message}"
