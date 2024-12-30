#!/bin/sh

log() {
	echo "${1}"
	logger -t ${TAG} ${1}
}

log "wifi_keepalive start"
IF_DEV="wlan0"

while true; do
	state=$(nmcli device status | grep "${IF_DEV} " | head -n1 | awk '{print $3}')
	if [[ "$state" == "disconnected" ]]; then
		log "INFO: Caught NM sitting idle. Forcing it to try to reconnect again!";
		nmcli device connect "${IF_DEV}"
	fi
	sleep 10;
done
