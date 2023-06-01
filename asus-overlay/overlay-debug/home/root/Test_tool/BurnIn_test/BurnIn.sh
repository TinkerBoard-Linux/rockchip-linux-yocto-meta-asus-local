#!/bin/bash

version=1.0

log()
{
	echo $1 | sudo tee -a $logfile | sudo tee $logfile2
	logger -t BurnIn "$1"
}

declare -A mmc_type_group
for i in `ls /sys/bus/mmc/devices/`
do
	mmc_type_group[$i]=`cat /sys/bus/mmc/devices/$i/type`
done

return_emmc_dev() {
	for i in "${!mmc_type_group[@]}"
	do
		if [[ "${mmc_type_group[$i]}" == "MMC" ]];then
			echo | ls /sys/bus/mmc/devices/$i/block/
		fi
	done
}

return_sd_dev() {
	for i in "${!mmc_type_group[@]}"
	do
		if [[ "${mmc_type_group[$i]}" == "SD" ]];then
			echo | ls /sys/bus/mmc/devices/$i/block/
		fi
	done
}

emmcdev=`return_emmc_dev`
sddev=`return_sd_dev`

select_test_item()
{
	echo "============================================"
	echo
	echo                "Burn In Test v_$version"
	echo
	echo "============================================"
	echo
	echo "0. (Default) All"
	echo "1. CPU stress test"
	echo "2. GPU stress test"
	echo "3. DDR stress test"
	echo "4. eMMC stress test"
	echo "5. SD card stress test"
	echo "6. Network stress test"
	echo "7. Memory test"
	read -p "Select test case: " test_item
}
info_view()
{
	echo "============================================"
	echo
	echo "          $1 stress test start"
	echo
	echo "============================================"
}

pause(){
	read -n 1 -p "$*" INP
	if [ $INP != '' ] ; then
		echo -ne '\b \n'
	fi
}

high_performance()
{
	echo
	echo "1. disable thermal policy"
	echo "2. keep thermal policy "
	read -p  "Select thermal policy: " thermal
	echo
	sudo bash $SCRIPTPATH/test/high_performance.sh $thermal > /dev/null 2>&1
}

cpu_freq_stress_test()
{
	sudo killall stressapptest > /dev/null 2>&1
	sudo bash $SCRIPTPATH/test/cpu_freq_stress_test.sh 864000 > /dev/null 2>&1 &
}

gpu_test()
{
	sudo killall glmark2-es2-wayland > /dev/null 2>&1
	bash $SCRIPTPATH/test/gpu_stress.sh
}

ddr_test()
{
	sudo killall memtester > /dev/null 2>&1
	sudo $SCRIPTPATH/test/memtester $1 > /dev/null 2>&1 &
}

emmc_stress_test()
{
	if [ -z "$emmcdev" ];
	then
		echo "No eMMC"
		exit
	else
		sudo killall emmc_stress_test.sh > /dev/null 2>&1
		sudo bash $SCRIPTPATH/test/emmc_stress_test.sh $emmcdev $logfile
	fi
}

sd_card_stress_test()
{
	killall sd_card_stress_test.sh > /dev/null 2>&1
	sudo bash $SCRIPTPATH/test/sd_card_stress_test.sh $sddev $logfile
}

network_stress_test()
{
	killall network_stress_test.sh > /dev/null 2>&1
	sudo bash $SCRIPTPATH/test/network_stress_test.sh
}

memtest()
{
	echo "Please enter test time in second"
	echo "Ex: 12hr -> 43200"
	echo "    24hr -> 86400"
	echo "If no string is entered, 43200 will be used"
	read -p  "Test time: " ddr_test_time
	if [ -z "$ddr_test_time" ]; then
		ddr_test_time=43200
	fi
	sudo killall stressapptest > /dev/null 2>&1
	sudo bash $SCRIPTPATH/test/memtest.sh $ddr_test_time
}

CPU="stressapptest"
GPU="glmark2-es2-wayland"
DDR="memtester"
EMMC="emmc_str"
SD="sd_card"
Network="network"

check_status()
{
	Flag=$( ps | grep "$2" | grep -v "grep")
	if [ "$Flag" == ""  ]
	then
		log "$1 stress test : stop"
	else
		log "$1 stress test : running"
	fi
}

check_all_status()
{
	check_status CPU $CPU
	check_status GPU $GPU
	check_status DDR $DDR
	check_status EMMC $EMMC
	check_status SD $SD
	check_status Network $Network
#	check_status NPU $NPU
}

check_system_status=false
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
select_test_item
sudo chmod 755 $SCRIPTPATH/test/*.sh

now="$(date +'%Y%m%d_%H%M')"
logfile2="/dev/kmsg"
high_performance

case $test_item in
	1)
		check_system_status=true
		logfile="$SCRIPTPATH/$now"_cpu.txt
		info_view CPU
		cpu_freq_stress_test
		;;
	2)
		check_system_status=true
		logfile="$SCRIPTPATH/$now"_gpu.txt
		info_view GPU
		gpu_test
		;;
	3)
		check_system_status=true
		logfile="$SCRIPTPATH/$now"_ddr.txt
		info_view DDR
		ddr_test 1GB
		;;
	4)
		if [ -z "$emmcdev" ];
		then
			echo "No eMMC"
			exit
		else
			info_view eMMC_RW
			logfile="$SCRIPTPATH/$now"_emmc.txt
			emmc_stress_test -a
		fi
		;;
	5)
		if [ -z "$sddev" ];
		then
			echo "No SD card"
			exit
		else
			info_view SD_RW
			logfile="$SCRIPTPATH/$now"_sd.txt
			sd_card_stress_test -a
		fi
		;;
	6)
		logfile="$SCRIPTPATH/$now"_network.txt
		info_view Network
		network_stress_test | sudo tee -a $logfile
		;;
	7)
		check_memtest_status=true
		memtest
		;;
	*)
		check_system_status=true
		logfile="$SCRIPTPATH/$now"_BurnIn.txt
		info_view BurnIn
		cpu_freq_stress_test
		gpu_test
		ddr_test 256MB
		if [ ! -z "$emmcdev" ]; then
			emmc_stress_test -a > /dev/null 2>&1 &
		fi
		if [ ! -z "$sddev" ]; then
			sd_card_stress_test -a > /dev/null 2>&1 &
		fi
		network_stress_test > /dev/null 2>&1 &
		;;
esac

while true; do
	if [[ $check_memtest_status == true ]]; then
		read -p  "Press enter to exit"
		exit
	fi
	if [ $check_system_status == false ]; then
		exit
	fi
	cpu_usage=$(top -b -n2 -d0.1 | grep "Cpu(s)" | awk '{print $2+$4+$6+$14 "%"}' | tail -n1)
	gpu_usage=$(cat /sys/devices/platform/ff9a0000.gpu/utilisation |awk '{print $1 "%"}')
	temp1=$(cat /sys/class/thermal/thermal_zone0/temp)
	temp2=$(cat /sys/class/thermal/thermal_zone1/temp)
	cpu_temp=$(echo "scale=2; $temp1/1000" | bc)
	gpu_temp=$(echo "scale=2; $temp2/1000" | bc)
	cur_freq0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
	cur_freq0=$(echo "scale=2; $cur_freq0/1000000" | bc)
	cur_freq4=`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`
	cur_freq4=$(echo "scale=2; $cur_freq4/1000000" | bc)
	gpu_freq=`cat /sys/class/devfreq/ff9a0000.gpu/cur_freq`
	gpu_freq=$(echo "scale=2; $gpu_freq/1000000" | bc)
	ddr_freq=$(sudo cat /sys/class/devfreq/dmc/cur_freq)
	ddr_freq=$(echo "scale=2; $ddr_freq/1000000" | bc)

	log ""
	log "============================================"
	log "$(date)"
	log "CPU Usage		= $cpu_usage"
	log "GPU Usage		= $gpu_usage"
	log "CPU temp		= $cpu_temp"
	log "GPU temp		= $gpu_temp"
	log "CPU big core freq	= $cur_freq4 GHz"
	log "CPU small core freq	= $cur_freq0 GHz"
	log "GPU freq		= $gpu_freq MHz"
	log "DDR freq		= $ddr_freq MHz"
	log ""
	log "Test Status"
	check_all_status
	log "============================================"
	log ""
	sleep 9
done
