#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# Import test suite definitions
source $TOOLS/functestlib.sh

. ../../library.sh

#
# Config options
#

# set time delay between frequency steps
STEP_DELAY=1
# set frequency of big cluster
fetchbigcpufreq
BIG_FREQ=$__RET
# set frequency of little cluster
fetchlittlecpufreq
LITTLE_FREQ=$__RET
# location of tracing in filesystem
TRACEDIR="/sys/kernel/debug/tracing"

#
# test start
#

# interrogate system to determine big/little CPUs
# after this:
#  FIRST_BIG_CPU= lowest numbered big cpu
#  FIRST_LITTLE_CPU= lowest numbered little cpu
#  TARGET_LITTLE_CPU= highest numbered little cpu, where test runs

default_big_cpulist
FIRST_BIG_CPU=`echo $__RET|busybox awk {'print $1'}`
default_little_cpulist
littlecpu=$__RET
TARGET_LITTLE_CPU=`echo $littlecpu|busybox awk {'print $NF'}`
FIRST_LITTLE_CPU=`echo $littlecpu|busybox awk {'print $1'}`

echo "Using cpu $FIRST_BIG_CPU to set frequency of big cluster, max freq: $BIG_FREQ"
echo "Using cpu $FIRST_LITTLE_CPU to set frequency of little cluster, max freq: $LITTLE_FREQ"
echo "Using cpu $TARGET_LITTLE_CPU to test load scaling"

check_userspace_exists
if [ "${RET}" == "0" ] ; then
  echo "FAIL: Userspace governor not available"
  exit 1
fi

# clear existing tasks from little cpu if possible
clear_little_cpu $TARGET_LITTLE_CPU

# set userspace governors
userspace_governors $FIRST_BIG_CPU $FIRST_LITTLE_CPU

# start task load
echo "starting load task"
$SHELL_CMD -c 'while [ 1 ]; do I=1; done' &
TIMERLOOPPID=$!

# place task load on target CPU
move_load $TARGET_LITTLE_CPU

reset_tracing

# run test without frequency-invariant load scaling
echo "disabling frequency-invariant load scaling"

echo ${LITTLE_FREQ} > /sys/devices/system/cpu/cpu$TARGET_LITTLE_CPU/cpufreq/scaling_setspeed
echo "starting test"
run_test
echo "done, copying trace"
cat ${TRACEDIR}/trace > ./trace_static.txt


# clean up
pidkiller $TIMERLOOPPID

# restore governors
echo "${OLD_BIG_GOVERNOR}" > /sys/devices/system/cpu/cpu$FIRST_BIG_CPU/cpufreq/scaling_governor
echo "${OLD_LITTLE_GOVERNOR}"> /sys/devices/system/cpu/cpu$FIRST_LITTLE_CPU/cpufreq/scaling_governor

# restore task affinity it it was modified
if [ "${AFFINITY}" == "cpusets" ] ; then
  echo "restoring tasks"
  for I in `cat /dev/cpuctl/all/tasks`; do
    echo $I > /dev/cpuctl/tasks
  done
  rmdir /dev/cpuctl/all
  rmdir /dev/cpuctl/cpu$TARGET_LITTLE_CPU
fi

echo "Filtering Static Trace:"
build_csv trace_static.txt $TARGET_LITTLE_CPU > trace_static.csv.txt

echo "Checking for a result"
OVERALL_RESULT=1
echo "Evaluating Static Load Test Run"
STATIC_TEST1=1
RATIO_RANGE=10
# pass criteria 1 - at all trace points, the ratio is the same (within +/- 10)
FIRST=1
while read TIMESTAMP FREQUENCY RATIO
do
  if [ $FIRST == 1 ] ; then
    FIRST=0
    LOWEST_RATIO=$((${RATIO}-${RATIO_RANGE}))
    HIGHEST_RATIO=$((${RATIO}+${RATIO_RANGE}))
    echo "Ratio must be between ${LOWEST_RATIO} and ${HIGHEST_RATIO}"
  fi
  if (( ( $RATIO < $LOWEST_RATIO ) )) ; then
    STATIC_TEST1=0
  fi
  if (( ( $RATIO > $HIGHEST_RATIO ) )); then
    STATIC_TEST1=0
  fi
done < trace_static.csv.txt

if (( $STATIC_TEST1 == 1 )); then
  echo "scaleinvar OFF passed expected ratio value test"
else
  echo "scaleinvar OFF failed expected ratio value test due to ratio outside expected tolerance"
  OVERALL_RESULT=0
fi

if [ $OVERALL_RESULT == 1 ] ; then
  # clean up temp files
  rm trace_static.txt
  rm trace_static.csv.txt
else
  gzip trace_static.txt
  gzip trace_static.csv.txt
fi

if [ ${OVERALL_RESULT} != 1 ] ; then
  echo "Test FAILED"
  exit 1
else
  echo "Test PASSED"
  exit 0
fi

