#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. $TOOLS/basics.sh
echo "This scenario assumes the light task is already in little domain however"
echo "its computed load is increasing due to the load pattern (due to run queue"
echo "residency). The task stays in little domain since the task load has not"
echo "yet crossed above the up-threshold. The runnable task gets the CPU immediately. "

ftrace_start
load_generator "0,L.$LITTLE_THRESHOLD.$CUTOFF_PRIORITY_GT:3000,L.$NOUP_THRESHOLD.$CUTOFF_PRIORITY_GT:7000,end" START_LITTLE
PID=$RESULT
wait $PID
ftrace_stop

#The following variables are used by ftrace_check
EXPECTED_CHANGE_TIME_MS_MIN=
EXPECTED_CHANGE_TIME_MS_MAX=
START_LITTLE=$PID
START_LITTLE_PRIORITY=-1
START_BIG=
START_BIG_PRIORITY=
END_LITTLE=$PID
END_LITTLE_PRIORITY=-1
END_BIG=
END_BIG_PRIORITY=
EXPECTED_TIME_IN_END_STATE_MS=5000

ftrace_check $BIG_LITTLE_SWITCH_SO

if [ $RESULT = 0 ] ; then
	echo "SUCCESS"
else
	echo "FAILED"
fi
exit $RESULT







