#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. ../../non_functional_script.sh
function idle_test()
{
	save_proc proc.dat

	for i in 1 2 3 4 ; do
	# sleep to let cpuidle menu understand we always sleep for a while
		sleep 1
	done

	get_cpuidle_usage C2 0
	CPU0_C2=$RESULT
	get_cpuidle_usage C1 0
	CPU0_C1=$RESULT

	CPU0_C2_START=$CPU0_C2
	CPU0_C1_START=$CPU0_C1

	i=0
	while [ $i -le 20 ] ; do
		prev_i=$i
		let i=$i+1
		save_cpuidle cpuidle.log
		sleep 1

		CPU0_C2_OLD=$CPU0_C2
		CPU0_C1_OLD=$CPU0_C1
		get_cpuidle_usage C2 0
		CPU0_C2=$RESULT
		get_cpuidle_usage C1 0
		CPU0_C1=$RESULT

		if [ "$CPU0_C2" == "$CPU0_C2_OLD" ] ; then
			if [ "$CPU0_C1" == "$CPU0_C1_OLD" ] ; then
				echo "Not entered in C2 or C1 in CPU0, during the last seconds - $prev_i s to $i s-."
				echo "cpuidle might be broken."
			fi
		fi
	done

	save_proc proc.dat

	let CPU0_C1=$CPU0_C1-$CPU0_C1_START
	let CPU0_C2=$CPU0_C2-$CPU0_C2_START

	if [ "$CPU0_C2" == "0" ] ; then
		if [ "$CPU0_C1" == "0" ] ; then
			echo "Not entered in C2 or C1 in CPU0, during the test."
			echo "cpuidle might be broken."
		fi
	fi
	echo "CPU0 was $CPU0_C1 times in state C1 and $CPU0_C2 times in state C2"
}

function busy_test()
{
	create_task 0 10
	PID=$RESULT
	RESULT=0
	while [ $RESULT -le 0 ] ; do
        	sleep 2
        	save_proc proc.dat
        	check_running $PID
	done
	save_proc proc.dat
	#don't check if the result was successful or not, just continue
}




echo "Repeated entry of idle scenario"
# Stop all android services
if [ $ANDROID -eq 1 ]; then
	stop
fi
get_time
START=$RESULT
#8 hours
let STOP=$START+28800
loop_counter=0
while [ $RESULT -le $STOP ] ; do
	let loop_counter=$loop_counter+1
	echo
	echo "------------- BUSY START"
	echo
	busy_test
	echo
	echo "------------- BUSY STOP"
	echo
	echo "------------- IDLE START"
	echo
	idle_test
	echo
	echo "------------- IDLE STOP"
	get_time
	echo "---- Start $START -- Current $RESULT -- Stop $STOP -- loop $loop_counter --------"
done

echo SUCCESS
exit 0
