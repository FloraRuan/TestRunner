#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
# source $SUITES/stress/funclib.sh
# Import functions library
source $TOOLS/functestlib.sh

CPUHOTPLUG_DIR="/sys/devices/system/cpu"
RMMOD="/system/bin/rmmod"
INSMOD="/system/bin/insmod"
CORECTL_MODULE="/system/lib/modules/core_ctl.ko"
CORECTL_PRESENT=$(lsmod | grep core_ctl)
verbosity=0

#
# This test case use to chech whether IRQs are scheduled among all the CPUs are not  
# TO generate random IRQs we are running monkey test on each individual CPU
#

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

#Get no.of CPUs
get_num_cpu()
{
	num_cpu=`ls $CPUHOTPLUG_DIR | grep "cpu[0-9]" | wc -l`
}
#Running monkey test upto 500 events to generate random interrupts
run_menkey_test()
{
	 monkey --ignore-crashes --ignore-timeouts --ignore-security-exceptions 500 &
	 pid1=$!
	 $TOOLS/taskset -pc $1,$1 ${pid1}
	 wait $pid1
}
# Function flip_value
# Parameters:
# 1) cpu index
# 2) new online value
# return 0 if sucessfully change online to new online value
# - otherwise, return 1
flip_value(){
	echo $2 > "$CPUHOTPLUG_DIR/cpu$i/online"
	if [ `cat $CPUHOTPLUG_DIR/cpu$1/online` -ne $2 ]; then
		echo "flip online value for cpu$i failed"
		return 1
	fi
	return 0
}

# Function test_cpu_offline
# Parameters:
# 1) cpu index
# 2) online value
# return 0 on success otherwise return 1
test_cpu_offline(){

offline_info=`cat /sys/devices/system/cpu/offline`
if [ "$offline_info" = "" ];then offline_info="X"
fi
cpu_info=`echo $1 | awk '/['$offline_info']/ {print}'`

if [ $2 -eq 0 ]
then
    if [ "$cpu_info" = "" ];then
		echo "ERROR: cpu$1 not present in /sys/devices/system/cpu/offline"
		return 1
    fi
fi
return 0
}

# Function test_interrupts
# Parameters:
# 1) cpu index
# 2) online value
# return 0 on success otherwise return 1
test_interrupts(){

interrupt_col=$(( 2 + $1 ))

echo "interrput_col is $interrupt_col"

if [ $2 -eq 0 ];then
	cpu_match=`cat /proc/interrupts | awk '/'CPU$1'/ {print}'`
	if [ "$cpu_match" != "" ];then
	echo "ERROR: cpu$1 is not offline"
	return 1
	fi
else
	cpu_irs_1=`cat /proc/interrupts | awk '{print $'$interrupt_col'}'`

	run_menkey_test $1

	cpu_irs_2=`cat /proc/interrupts | awk '{print $'$interrupt_col'}'`

	if [ "$cpu_irs_1" = "$cpu_irs_2" ];then
		echo "ERROR: cpu$1 is not receiving irq when it is online"
		return 1
	fi
fi

return 0
}

do_test()
{
get_num_cpu
	if [ $verbosity -gt 0 ];then
		echo "num_cpu is $num_cpu"
	fi

	if [ $num_cpu -le 1 ];then
		echo "WARN: Test only supported on SMP system"
		return 0
	fi

num_cpu_test=$(($num_cpu - 1))

	if [ -n "$CORECTL_PRESENT" ]; then
		if [ $verbosity -gt 0 ];then
			echo "Core control module detected. Saving and disabling core control..."
		fi
			save_disable_core_ctl
	fi

for i in $(seq 0 $num_cpu_test)
do
    old_online=`cat $CPUHOTPLUG_DIR/cpu$i/online`
	new_online=$(( ! $old_online  ))

		echo "Testing CPU$i..."

	if [ $verbosity -gt 0 ];then
		echo "old online is $old_online"
		echo "new online is $new_online"
	fi

	flip_value $i $new_online

		if [ $? -ne 0 ]; then
		return 1
		fi

	test_cpu_offline $i $new_online

	if [ $? -ne 0 ]; then
		#flip online value back
		flip_value $i $old_online
		return 1
	fi

	test_interrupts $i $new_online

	if [ $? -ne 0 ]; then
		#flip online value back
		flip_value $i $old_online
		return 1
	fi

	#flip online value back
	flip_value $i $old_online

	if [ $? -ne 0 ]; then
		return 1
    fi

	test_cpu_offline $i $old_online

	if [ $? -ne 0 ]; then
		return 1
	fi

	test_interrupts $i $old_online

	if [ $? -ne 0 ]; then
		return 1
	fi
done

if [ -n "$CORECTL_PRESENT" ]; then
	if [ $verbosity -gt 0 ];then
		echo "Restoring core control"
	fi
	enable_restore_core_ctl
fi

return 0
}

# Do Irq_Balance test

	echo "##### Running Irq_Balance Test #####"
	framework "start"
	sleep 5
	start msm_irqbalance
	if [ $? -eq 0 ];then
		echo "IRQ Balance Enabled"
	fi
	do_test
	if [ $? -eq 0 ];then
		echo "Irq_balance Test Passed"
		framework "stop"
	else
		echo "Irq_Balance Test Failed"
		framework "stop"
		exit 1
	fi
