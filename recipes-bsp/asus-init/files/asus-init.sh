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

do_mount_boot()
{
	MMC=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p8' '{print $1}' | awk -F 'mmc' '{print $2}')
	mount "/dev/mmc${MMC}p7" /boot/
}

case "$1" in
	start)
		echo -n "Starting ASUS init"
		do_mount_boot
		do_set_led_trigger
		# set DNS server
		echo "nameserver 8.8.8.8" > /etc/resolv.conf
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
