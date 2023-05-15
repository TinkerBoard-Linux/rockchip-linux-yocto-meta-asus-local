#!/bin/sh

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

# set act-led trigger function
do_set_led_trigger()
{
	cmdline=$(cat /proc/cmdline)
	storage=`echo $cmdline|awk '{print match($0,"storagemedia=emmc")}'`;
	if [ $storage -gt 0 ]; then
		#emmc
		echo mmc0 > /sys/class/leds/act-led/trigger
	else
		#sdcard
		echo mmc1 > /sys/class/leds/act-led/trigger
	fi
}

case "$1" in
	start)
		echo -n "Starting ASUS init"
		do_set_led_trigger
		echo "."
		;;
	stop)
		;;
	restart|reload)
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
esac

exit 0
