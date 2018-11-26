#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. ../../non_functional_script.sh
echo "Hot unplug cores from either domains when large pool of tasks are being active"
# Stop all android services
if [ $ANDROID -eq 1 ]; then
	stop
fi

create_task 0 200
PID=$RESULT

#last fast cpu
for i in $CPU_FAST ; do
	CPU0=$i
done
#last slow cpu
for i in $CPU_SLOW ; do
	CPU1=$i
done

#Make sure everythings is started
sleep 4

echo "Unplug fast cpu"
hot_unplug "$CPU0 $CPU1"

RESULT=0
while [ $RESULT -le 0 ] ; do
	sleep 2
	save_proc proc.dat
	check_running $PID
done
save_proc proc.dat
hot_plug "$CPU0 $CPU1"

if [ $RESULT -le 1 ] ; then
	echo SUCCESS
	exit 0
fi
echo FAILED
exit 1
