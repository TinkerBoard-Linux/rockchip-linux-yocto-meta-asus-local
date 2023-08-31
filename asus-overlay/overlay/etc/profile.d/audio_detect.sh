#!/bin/bash

# Audio detect on boot.

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)

if [ $hdmi_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
elif [ $dp_status = "connected" ]
then
	/etc/pulse/movesinks.sh "alsa_output.platform-dp-sound.stereo-fallback"
else
	/etc/pulse/movesinks.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
fi

