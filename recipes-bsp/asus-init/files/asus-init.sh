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

do_resize()
{
	if [ ! -e /boot/.firstrun ]; then
		/usr/bin/resize-helper
		MMC=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p8' '{print $1}' | awk -F 'mmc' '{print $2}')
		/sbin/resize2fs /dev/mmc${MMC}p7
		touch /boot/.firstrun
	fi
	/sbin/resize-data.sh
}

do_start_fotaclient()
{
	mkdir -p /data/fota
	UPG_FILE_PATH="/data/fota/recovery/update_status.txt"
	if [ -e $UPG_FILE_PATH ]; then
		UPG_STATE=$(cat $UPG_FILE_PATH)
		if [ "${UPG_STATE}" == "0" ]; then
			echo "[FotaClient]: UPG_STATE = 200" > /dev/kmsg
			echo "200" > /data/fota/upg_OTA_status
		elif [ "${UPG_STATE}" == "1" ]; then
			echo "[FotaClient]: UPG_STATE = 410" > /dev/kmsg
			echo "410" > /data/fota/upg_OTA_status
		fi
		rm $UPG_FILE_PATH
	fi
	/sbin/start-fotaclient.sh
}

do_create_xrandr()
{
	mkdir -p /boot/display/hdmi
	mkdir /boot/display/dp
	echo temp > /boot/display/hdmi/xrandr.cfg
	echo temp > /boot/display/dp/xrandr.cfg
}

do_wifi_keepalive()
{
	/sbin/wifi_keepalive.sh &
}

do_start_pulseaudio()
{
	chown weston:weston -R /run/user/1000
	sudo -u weston pulseaudio --start
}

case "$1" in
	start)
		echo -n "Starting ASUS init"
		# do_mount_boot
                do_resize
		do_set_led_trigger
		do_start_fotaclient
		# set DNS server
		echo "nameserver 8.8.8.8" > /etc/resolv.conf
		do_create_xrandr
		do_wifi_keepalive
		do_start_pulseaudio
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
