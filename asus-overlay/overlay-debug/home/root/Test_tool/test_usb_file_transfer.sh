#!/bin/bash

version=1.0

info_view()
{
	echo "************************************************"
	echo
	echo                "USB File Transfer Test v_$version"
	echo
	echo "************************************************"
	echo
	echo
}

info_view
usbdev=$(lsblk|grep sda1)
if [ -z "$usbdev" ];then
	echo "No USB Storage found"
	exit
else
	while [ 1 != 2 ]
	do
		sudo mount /dev/sda1 /mnt/usb_storage

		echo "Start Write Test"
		sync
		echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1
		sudo dd if=/dev/zero of=/mnt/usb_storage/tmpfile bs=256M count=15 conv=fdatasync

		echo "Start Read Test"
		sync
		echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1
		sudo dd if=/mnt/usb_storage/tmpfile of=/dev/null bs=256M count=15
		sudo rm /mnt/usb_storage/tmpfile
		sudo umount /dev/sda1
	done
fi
