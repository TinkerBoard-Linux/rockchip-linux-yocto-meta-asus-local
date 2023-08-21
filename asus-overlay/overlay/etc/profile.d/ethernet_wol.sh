#!/bin/bash

# Enable WOL for ethernet : g=on, d=off

eth0=$(sudo ifconfig eth0 | grep "eth0")
if [ "$eth0" == "" ]; then
	echo "eth0 not exist"
else
	/usr/sbin/ethtool -s eth0 wol g
fi

