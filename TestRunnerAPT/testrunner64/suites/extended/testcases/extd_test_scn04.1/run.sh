#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. $TOOLS/basics.sh
echo "This is a light task which started with Big domain due to"
echo "CPU affinity and despite migration criteria satisfied is"
echo "continuing on Big domain. The task gets CPU immediately."

ftrace_start
load_generator "0,L.$LITTLE_THRESHOLD.$CUTOFF_PRIORITY_GT:3000,L.$NOUP_THRESHOLD.$CUTOFF_PRIORITY_GT:7000,end" STARTSTOP_FAST
PID=$RESULT
wait $PID
ftrace_stop

#The following variables are used by ftrace_check
EXPECTED_CHANGE_TIME_MS_MIN=
EXPECTED_CHANGE_TIME_MS_MAX=
START_LITTLE=
START_LITTLE_PRIORITY=
START_BIG=$PID
START_BIG_PRIORITY=-1
END_LITTLE=
END_LITTLE_PRIORITY=
END_BIG=$PID
END_BIG_PRIORITY=-1
EXPECTED_TIME_IN_END_STATE_MS=5000

ftrace_check $BIG_LITTLE_SWITCH_SO

if [ $RESULT = 0 ] ; then
	echo "SUCCESS"
else
	echo "FAILED"
fi
exit $RESULT







