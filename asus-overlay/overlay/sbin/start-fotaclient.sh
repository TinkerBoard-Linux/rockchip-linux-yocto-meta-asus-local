#!/bin/sh

echo "fotaclient start" > /dev/kmsg

#while true; do
alived=$(ps | grep -v 'grep' | grep 'ota_daemon.pyc')
if [ "${alived}" != "" ]; then
    echo "[fotaclient]: fota is running" > /dev/kmsg
    #break
else
    echo "[fotaclient]: fota is not running, restart" > /dev/kmsg
    /usr/bin/python3 /usr/share/FotaClient/ota_daemon.pyc &
fi
    #sleep 5
#done

echo "fotaclient end" > /dev/kmsg
