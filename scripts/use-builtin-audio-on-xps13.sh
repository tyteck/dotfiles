#!/usr/bin/zsh
# This script is setting builtin audio card as default periph
# source : https://gist.github.com/ChriRas/b9aef9771a97249cb4620e0d6ef538c4
# for input and output

# how to find default output
# > pactl list short sinks
# will display
# 33	alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.iec958-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
# 38	alsa_output.pci-0000_00_1f.3.analog-stereo	module-alsa-card.c	s16le 2ch 48000Hz	RUNNING
# then
pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo

# how to find default input (mic)
# > pactl list short sources
# will display
# 2	alsa_input.pci-0000_00_1f.3.analog-stereo	module-alsa-card.c	s16le 2ch 48000Hz	RUNNING
# 39	alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.iec958-stereo.monitor	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
# 45	alsa_output.pci-0000_00_1f.3.analog-stereo.monitor	module-alsa-card.c	s16le 2ch 48000Hz	IDLE
# 46	alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.multichannel-input	module-alsa-card.c	s16le 1ch 44100Hz	SUSPENDED
# then
pactl set-default-source alsa_input.pci-0000_00_1f.3.analog-stereo

# add this script to your startup programs
