#! /usr/bin/env bash

sinks=(
	alsa_output.usb-Kingston_HyperX_7.1_Audio_00000000-00.analog-stereo
	alsa_output.pci-0000_0b_00.4.analog-stereo
)
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

notify-send \
	--app-name sway \
	--expire-time 2000 \
	--transient \
	--icon /usr/share/icons/Adwaita/symbolic/devices/audio-headphones-symbolic.svg \
	"${message}"
