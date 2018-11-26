#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

RTIME='720'
ITER='300'
RESULT=0
TESTNAME="00_RTTests"
TASKSET=$TOOLS/taskset
CYCLICTEST=$TOOLS/cyclictest
HACKBENCH=$TOOLS/hackbench
PISTRESS=$TOOLS/pi_stress
PTSEMATEST=$TOOLS/ptsematest
RTMIGRATETEST=$TOOLS/rt-migrate-test
SIGNALTEST=$TOOLS/signaltest
SIGWAITTEST=$TOOLS/sigwaittest
SVSEMATEST=$TOOLS/svsematest
runcyclictest()
{
$CYCLICTEST -t 3 -D $RTIME -m -M -c 1 -b USEC -q -Q -y fifo &
pid=$!
busybox ping -l 100000 -q -s 10 -f localhost &> /dev/null &
$CYCLICTEST -t 1 -p 80 -X -S -i $ITER -n -c 1 -r -h 3 -y rr -D $(busybox expr $RTIME / 2)
$CYCLICTEST -t 50 -p 80 -i $ITER -n -a 1 -q -D $RTIME
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
if [[ "" !=  "$pid" ]]; then
  echo "killing $pid"
  kill -9 $pid
fi
}

runhackbench()
{
$HACKBENCH -s 512 -l $ITER -g 15 -f 25 -P
$HACKBENCH --pipe --threads
if [ $? -eq 0 ];then
    echo "hackbench: Passed"
    RESULT=$((RESULT+1))
else
    echo "hackbench: Failed"
fi
}
runpi_stress()
{
$PISTRESS --duration=$RTIME --rr --uniprocessor
$PISTRESS --duration=$RTIME --mlockall --sched id=med,policy=rr,priority=80
if [ $? -eq 0 ];then
    echo "pi_stress: Passed"
    RESULT=$((RESULT+1))
else
    echo "pi_stress: Failed"
fi
}
runptsematest()
{
$PTSEMATEST --smp -t 10 --loops=$ITER
$PTSEMATEST -b USEC -a 3 --loops=$ITER
if [ $? -eq 0 ];then
    echo "ptsematest: Passed"
    RESULT=$((RESULT+1))
else
    echo "ptsematest: Failed"
fi
}
runrt-migrate-test()
{
$RTMIGRATETEST -p 3 -l $ITER
$RTMIGRATETEST -s 10 -l $ITER
$RTMIGRATETEST -r 80 -l $ITER
$RTMIGRATETEST -c -l $ITER
if [ $? -eq 0 ];then
    echo "rt-migrate-test: Passed"
    RESULT=$((RESULT+1))
else
    echo "rt-migrate-test: Failed"
fi
}
runsignaltest()
{
$SIGNALTEST -b USEC -l $ITER
$SIGNALTEST -p 10 -l $ITER
$SIGNALTEST -m -l $ITER
$SIGNALTEST -t 10 -l $ITER
if [ $? -eq 0 ];then
    echo "signaltest: Passed"
    RESULT=$((RESULT+1))
else
    echo "signaltest: Failed"
fi
}
runsigwaittest()
{
$SIGWAITTEST -l $ITER -b USEC
$SIGWAITTEST -l $ITER -d 10
$SIGWAITTEST -l $ITER -f
$SIGWAITTEST -l $ITER -p 50
$SIGWAITTEST -l $ITER -t 20
$SIGWAITTEST -l $ITER -a 2
$SIGWAITTEST -l $ITER -i 20
if [ $? -eq 0 ];then
    echo "sigwaittest: Passed"
    RESULT=$((RESULT+1))
else
    echo "sigwaittest: Failed"
fi
}
runsvsematest()
{
$SVSEMATEST -p 10 --loops=$ITER
$SVSEMATEST -b USEC --loops=$ITER
$SVSEMATEST -d 100 --loops=$ITER
$SVSEMATEST -f --loops=$ITER
$SVSEMATEST -S --loops=$ITER
$SVSEMATEST -S -i 10 --loops=$ITER
$SVSEMATEST -t 10 --loops=$ITER
if [ $? -eq 0 ];then
    echo "svsematest: Passed"
    RESULT=$((RESULT+1))
else
    echo "svsematest: Failed"
fi
}
runcyclictest
runhackbench
runpi_stress
runptsematest
runrt-migrate-test
runsignaltest
runsvsematest
if [ $RESULT -eq 7 ];then
    echo "$TESTNAME: Passed"
else
    echo "$TESTNAME Failed"
    exit 1
fi

