#!/bin/bash

hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)

if [ "$1" == "1" ]; then
	echo "jack_hotplug: Plug-in headphone, set default sound card to RK809" > /dev/kmsg
	/etc/pulse/switch_sound_device.sh "alsa_output.0.HiFi__Headphones__sink"
fi

if [ "$1" == "0" ]; then
	if [ $hdmi_status = "connected" ]; then
		echo "jack_hotplug: Plug-out headphone, HDMI is connected, set default sound card to HDMI" > /dev/kmsg
		/etc/pulse/switch_sound_device.sh "alsa_output.1.stereo-fallback"
	fi
	if [ $hdmi_status = "disconnected" ]; then
		echo "jack_hotplug: Plug-out headphone, HDMI is disconnected, set default sound card to RK809" > /dev/kmsg
                /etc/pulse/switch_sound_device.sh "alsa_output.0.HiFi__Headphones__sink"
	fi
fi
