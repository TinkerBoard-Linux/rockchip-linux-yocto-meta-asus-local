#!/bin/sh

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

MMC=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p8' '{print $1}' | awk -F 'mmc' '{print $2}')

case "$1" in
	start)
		echo -n "Starting mountboot"
		mount "/dev/mmc${MMC}p7" /boot/
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
