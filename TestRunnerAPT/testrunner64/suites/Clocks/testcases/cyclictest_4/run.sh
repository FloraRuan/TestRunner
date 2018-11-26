#!/system/bin/bash
# Import test suite definitions
source ../../../../init_env

#import test functions library
# source $SUITES/stress/funclib.sh
# Import functions library
source $TOOLS/functestlib.sh
RESULT=0

echo -1 > /proc/sys/kernel/sched_rt_runtime_us

COMMON_OPTS="--quiet --mlockall --latency=0 --histogram=10000"

echo "Policy OTHER (1h tests)"

SPECIF_OPTS="--duration=1h --policy=other"
RESULT_PREFIX="results-$(uname -r)-other"
date +"  [%X] $TOOLS/setitimer"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS}  > "${RESULT_PREFIX}-setitimer.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/clock_nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep  > "${RESULT_PREFIX}-clocknanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep --system  > "${RESULT_PREFIX}-nanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "Policy FIFO (2h tests)"
SPECIF_OPTS="--duration=2h --policy=fifo --priority=99"
RESULT_PREFIX="results-$(uname -r)-fifo"
date +"  [%X] $TOOLS/setitimer"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS}  > "${RESULT_PREFIX}-setitimer.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/clock_nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep  > "${RESULT_PREFIX}-clocknanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep --system  > "${RESULT_PREFIX}-nanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi


echo "Policy RR (2h tests)"
SPECIF_OPTS="--duration=2h --policy=rr --priority=99"
RESULT_PREFIX="results-$(uname -r)-rr"
date +"  [%X] $TOOLS/setitimer"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS}  > "${RESULT_PREFIX}-setitimer.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/clock_nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep  > "${RESULT_PREFIX}-clocknanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
date +"  [%X] $TOOLS/nanosleep"
$TOOLS/cyclictest ${COMMON_OPTS} ${SPECIF_OPTS} --nanosleep --system  > "${RESULT_PREFIX}-nanosleep.txt"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi


if [ $RESULT -eq 9 ];then
    echo "$TESTNAME: Passed"
else
    echo "$TESTNAME Failed"
    exit 1
fi

