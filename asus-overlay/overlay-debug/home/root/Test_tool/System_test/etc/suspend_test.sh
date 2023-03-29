#!/bin/bash

sudo sh -c 'echo 0 > /sys/class/rtc/rtc0/wakealarm'
sudo sh -c 'echo +20 > /sys/class/rtc/rtc0/wakealarm'
sudo pm-suspend
