#!/bin/sh


hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)
jack_status=$(cat /sys/class/extcon/extcon4/cable.1/state)

# Config audio output devices when HDMI hot-plug
if [ $hdmi_status = "connected" ] && [ $jack_status = 0 ];
then
	echo "Plug-in HDMI, set default sound card to HDMI"
	/etc/pulse/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
else
	echo "Plug-out HDMI, set default sound card to RK809"
	/etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi

exit 0
