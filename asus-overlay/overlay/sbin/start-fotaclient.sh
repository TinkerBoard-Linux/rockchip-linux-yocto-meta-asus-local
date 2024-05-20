#!/bin/sh

echo "[FotaClient]: Start" > /dev/kmsg

alived=$(ps | grep -v 'grep' | grep 'ota_daemon.pyc')
if [ "${alived}" != "" ]; then
    echo "[FotaClient]: Client is running" > /dev/kmsg
else
    echo "[FotaClient]: Client is not running, restart" > /dev/kmsg
    /usr/bin/python3 /usr/share/FotaClient/ota_daemon.pyc &
fi