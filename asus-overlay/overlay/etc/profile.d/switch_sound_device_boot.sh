#!/bin/sh
(
# Config audio output devices at boot time
hdmi_status=$(cat /sys/class/drm/card0-HDMI-A-1/status)
#jack_tb3n_status=$(cat /sys/class/extcon/extcon4/cable.1/state)
#jack_tb3_status=$(cat /sys/class/extcon/extcon3/cable.1/state)
max_timeout=6
elapsed=0
board_name=$(cat /proc/device-tree/boardinfo/model | awk '{gsub("\0","")} 1')

while ! pidof pulseaudio >/dev/null; do
    if [ "$elapsed" -ge "$max_timeout" ]; then
            echo "switch_sound_device_boot: PulseAudio did not start within $max_timeout seconds." > /dev/kmsg
            exit 1
    fi
    echo "switch_sound_device_boot: Waiting for PulseAudio to start..." > /dev/kmsg
    sleep 1
    elapsed=$((elapsed + 1))
done

if [ $board_name = "rk3566" ];
then
    jack_status=$(cat /sys/class/extcon/extcon3/cable.1/state)
else
    jack_status=$(cat /sys/class/extcon/extcon3/cable.0/state)
fi

if [ $hdmi_status = "connected" ];
then
    if [ $jack_status = 1 ];
    then
            echo "switch_sound_device_boot: Audio jack is connected, set default sound card to RK809" > /dev/kmsg
            /bin/bash  /etc/pulse/switch_sound_device.sh "alsa_output.0.HiFi__Headphones__sink"
    else
            echo "switch_sound_device_boot: HDMI is connected, set default sound card to HDMI" > /dev/kmsg
            /bin/bash /etc/pulse/switch_sound_device.sh "alsa_output.1.stereo-fallback"
    fi
else
    echo "switch_sound_device_boot: HDMI is disconnected, set default sound card to RK809" > /dev/kmsg
    /bin/bash  /etc/pulse/switch_sound_device.sh "alsa_output.0.HiFi__Headphones__sink"
fi
) &
