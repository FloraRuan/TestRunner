#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#Android framework start/stop service
function framework(){
	cmd=$1
	if [ $cmd == "start" ]; then
	ps | grep zygote
		if [ $? -eq 1 ]; then
			echo "Starting Android FW."
			start
			sleep 2
		else
			echo "Framework is running."
		fi
	else
		ps | grep zygote
		if [ $? -eq 0 ]; then
 			echo "Stopping Android FW."
			stop
			sleep 2
		else
			echo "Framework is not running."
		fi
	fi
}

#
# This test case is to verify interrupts are scheduled on CPU0 by stopping msm_irqbalance
#

cpu0=$(cat /sys/devices/system/cpu/cpu0/online)
if [ $cpu0 -eq 0 ]; then
	echo 1 > /sys/devices/system/cpu/cpu0/online
fi

#Start Android framework
framework "start"
sleep 5
stop msm_irqbalance
if [ $? -eq 0 ];then
    echo "IRQ Balance disabled"
fi
	cat /proc/interrupts > default_irqs.txt
	monkey --ignore-crashes --ignore-timeouts --ignore-security-exceptions 1000 &
	pid1=$!
	#setting task on CPU0
	 $TOOLS/taskset -pc 0,0 ${pid1}
	wait $pid1
	cat /proc/interrupts > taskset_irqs.txt 
	
while IFS= read -r lineA && IFS= read -r lineB <&3; do
	var1=$(echo "$lineA"| awk '{print $2}')
	var2=$(echo "$lineB"| awk '{print $2}')
	if [ $var2 -ge $var1 ]; then
		count=$((count+1))
		if [ $var2 -gt $var1 ]; then
			ints=$((ints+1))
		fi	
	else
		count=0
	fi
done <default_irqs.txt 3<taskset_irqs.txt
#Stop Android framework
framework "stop"

if [ $count == 0 ]; then
	echo "testcase failed"
else
	echo "Testcase passed"
	echo "Total no.of interrupts are $count"
	echo "Number of interrupts scheduled/serviced on CPU$cpu is $ints"
fi
