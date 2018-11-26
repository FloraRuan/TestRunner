#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. ../../non_functional_script.sh
echo "Large task pool for HMP migration"
# Stop all android services
if [ $ANDROID -eq 1 ]; then
	stop
fi

create_task 0 200
PID=$RESULT
RESULT=0
while [ $RESULT -le 0 ] ; do
	sleep 2
	save_proc proc.dat
	check_running $PID
done
save_proc proc.dat

if [ $RESULT -le 1 ] ; then
	echo SUCCESS
	exit 0
fi
echo FAILED
exit 1
