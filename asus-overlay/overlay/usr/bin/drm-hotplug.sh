#!/bin/sh


hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
dp_status=$(cat /sys/class/drm/card0-DP-1/status)
board_name=$(cat /proc/device-tree/boardinfo/model | awk '{gsub("\0","")} 1')

if [ $board_name = "rk3566" ];
then
    jack_status=$(cat /sys/class/extcon/extcon3/cable.1/state)
else
    jack_status=$(cat /sys/class/extcon/extcon3/cable.0/state)
fi

# Config audio output devices when HDMI hot-plug
if [ $hdmi_status = "connected" ] && [ $jack_status = 0 ];
then
	echo "Plug-in HDMI, set default sound card to HDMI" > /dev/kmsg
	/etc/pulse/switch_sound_device.sh "alsa_output.platform-hdmi-sound.stereo-fallback"
else
	echo "Plug-out HDMI, set default sound card to RK809" > /dev/kmsg
	/etc/pulse/switch_sound_device.sh "alsa_output.platform-rk809-sound.HiFi__hw_rockchiprk809__sink"
fi

exit 0
