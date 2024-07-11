#!/bin/bash

# Enable WOL for ethernet : g=on, d=off

project_model=$(tr -d '\0' < /proc/device-tree/model)

eth0=$(sudo ifconfig eth0 | grep "eth0")
if [ "$eth0" == "" ]; then
	echo "eth0 not exist"
else
	/usr/sbin/ethtool -s eth0 wol g
fi

if [ "$project_model" != "ASUS Tinker Board 3" ]; then
	eth1=$(sudo ifconfig eth1 | grep "eth1")
	if [ "$eth1" == "" ]; then
		echo "eth1 not exist"
	else
		/usr/sbin/ethtool -s eth1 wol g
	fi
fi

