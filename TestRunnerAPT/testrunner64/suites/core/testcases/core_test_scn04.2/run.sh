#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. $TOOLS/basics.sh
echo "This starts with a light task on little domain without any specific CPU affinity"
echo "defined. However the task’s CPU affinity is modified mid way through execution"
echo "to big domain. The task moves to the run queue."

ftrace_start
load_generator "0,L.$LITTLE_THRESHOLD.$CUTOFF_PRIORITY_GT:4000,L.$LITTLE_THRESHOLD.$CUTOFF_PRIORITY_GT:7000,end" START_LITTLE
PID=$RESULT
sleep 3
taskset_cpufast $PID
wait $PID
ftrace_stop

#The following variables are used by ftrace_check
EXPECTED_CHANGE_TIME_MS_MIN=2800
EXPECTED_CHANGE_TIME_MS_MAX=4200
START_LITTLE=$PID
START_LITTLE_PRIORITY=-1
START_BIG=
START_BIG_PRIORITY=
END_LITTLE=
END_LITTLE_PRIORITY=
END_BIG=$PID
END_BIG_PRIORITY=-1
ftrace_check $BIG_LITTLE_SWITCH_SO

if [ $RESULT = 0 ] ; then
	echo "SUCCESS"
else
	echo "FAILED"
fi
exit $RESULT







