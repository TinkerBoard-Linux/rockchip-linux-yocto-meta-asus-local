#!/bin/bash

# Setting default-sink and move-sink.

sudo -u weston PULSE_RUNTIME_PATH=/run/user/1000/pulse pactl set-default-sink $1
sudo -u weston PULSE_RUNTIME_PATH=/run/user/1000/pulse pactl list sink-inputs | grep "Sink Input" | while read line
do
sudo -u weston PULSE_RUNTIME_PATH=/run/user/1000/pulse pactl move-sink-input `echo $line | cut -f3 -d' ' | cut -f2 -d'#' ` $1
done
