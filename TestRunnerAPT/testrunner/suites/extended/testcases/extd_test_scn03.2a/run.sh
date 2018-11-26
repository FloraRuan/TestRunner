#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. $TOOLS/basics.sh
echo "This scenario assumes the heavy task is already in big"
echo "domain however its computed load is decreasing due to"
echo "the load pattern (due to idling). The task moves to the little"
echo "domain since the big domain is oversubscribed. "

ftrace_start
load_generator "0,B.$BIG_THRESHOLD.$CUTOFF_PRIORITY_GT:3000,B.$NODOWN_THRESHOLD.$CUTOFF_PRIORITY_GT:7000,end" START_FAST
PID=$RESULT
sleep 4
hog_cpu_fast
wait $PID
ftrace_stop
unhog_cpu

#The following variables are used by ftrace_check
EXPECTED_CHANGE_TIME_MS_MIN=3500
EXPECTED_CHANGE_TIME_MS_MAX=4500
EXPECTED_TIME_IN_END_STATE_MS=2500
START_LITTLE=
START_LITTLE_PRIORITY=
START_BIG=$PID
START_BIG_PRIORITY=-1
END_LITTLE=$PID
END_LITTLE_PRIORITY=-1
END_BIG=
END_BIG_PRIORITY=
ftrace_check $BIG_LITTLE_SWITCH_SO

if [ $RESULT = 0 ] ; then
	echo "SUCCESS"
else
	echo "FAILED"
fi
exit $RESULT
