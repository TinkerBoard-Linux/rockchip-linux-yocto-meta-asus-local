#!/bin/bash

### BEGIN INIT INFO
# Provides:          shutdown_test.sh
# Required-Start:    $all
# Required-Stop:
# Should-Stop:
# Default-Start:     2 3 4 5
# X-Start-Before:
# Default-Stop:
# Short-Description: Shutdown auto test tool
### END INIT INFO

times=$(grep -r "shutdown_times" /etc/shutdown_times.txt | awk '{print $3}')

case "$1" in
	start)
		((times+=1))
		sleep 60
		echo "shutdown_times = "$times | sudo tee /etc/shutdown_times.txt
		sync
		echo +30 > /sys/class/rtc/rtc0/wakealarm
		sudo poweroff
		;;
	stop)
		echo "Stopping shutdown_test"
		;;
	*)
		echo "Usage: /etc/init.d/shutdown_test.sh {start|stop}"
		exit 1
		;;
esac

exit 0
