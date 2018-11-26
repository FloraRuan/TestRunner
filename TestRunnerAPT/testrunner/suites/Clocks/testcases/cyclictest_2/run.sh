#!/system/bin/bash
# Import test suite definitions
source ../../../../init_env

#import test functions library
# Import functions library
source $TOOLS/functestlib.sh

RTIME='720'
ITER=$(awk 'BEGIN{srand();print int(rand()*(800-300))+300 }')
RESULT=0
DATELINE=$(date +%Y-%m-%d_%H:%M)

#Put load on CPUs 
ping -l 100000 -q -s 10 -f localhost &> /dev/null &
pid=$!
#Running cyclic test with thread priority 99
echo "cyclictest -p 99 -l 100"
$TOOLS/cyclictest -p 99 -l 100
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 500"
$TOOLS/cyclictest -p 99 -l 500
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 2000"
$TOOLS/cyclictest -p 99 -l 2000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 10000"
$TOOLS/cyclictest -p 99 -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

#run cyclictest for 5 sec with priority 99
echo "cyclictest -p 99 -D 5"
$TOOLS/cyclictest -p 99 -D 5
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -D 15"
$TOOLS/cyclictest -p 99 -D 15
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -D 30"
$TOOLS/cyclictest -p 99 -D 30
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

#
echo "cyclictest -t1 -p 99 -n -i 10000 -l 10000"
$TOOLS/cyclictest -t1 -p 99 -n -i 10000 -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t1 -p 99 -n -i 500 -l 10000"
$TOOLS/cyclictest -t1 -p 99 -n -i 500 -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t5 -p 99 -n -q -l 10000"
$TOOLS/cyclictest -t5 -p 99 -n -q -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 100"
$TOOLS/hackbench -p -g 20 -l 1000  & $TOOLS/cyclictest -p 99 -l 100
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 500"
$TOOLS/cyclictest -p 99 -l 500
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 2000"
$TOOLS/cyclictest -p 99 -l 2000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -l 10000"
$TOOLS/cyclictest -p 99 -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -D 5"
$TOOLS/cyclictest -p 99 -D 5
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -D 15"
$TOOLS/cyclictest -p 99 -D 15
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -p 99 -D 30"
$TOOLS/cyclictest -p 99 -D 30
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t1 -p 99 -n -i 10000 -l 10000"
$TOOLS/cyclictest -t1 -p 99 -n -i 10000 -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t1 -p 99 -n -i 500 -l 10000"
$TOOLS/cyclictest -t1 -p 99 -n -i 500 -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t5 -p 99 -n -q -l 10000"
$TOOLS/cyclictest -t5 -p 99 -n -q -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -l 100"
$TOOLS/hackbench -p -g 20 -l 1000 & $TOOLS/cyclictest -l 100 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -l 500"
$TOOLS/cyclictest -l 500
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -l 2000"
$TOOLS/cyclictest -l 2000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -l 10000"
$TOOLS/cyclictest -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -D 5"
$TOOLS/cyclictest -D 5
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -D 15"
$TOOLS/cyclictest -D 15
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -D 30"
$TOOLS/cyclictest -D 30
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t1 -n -i 10000 -l 10000"
$TOOLS/cyclictest -t1 -n -i 10000 -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

echo "cyclictest -t1 -n -i 500 -l 10000"
$TOOLS/cyclictest -t1 -n -i 500 -l 10000
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
#running cyclictest with 5 threads of 10000 iterations with clock_nanosleep 
echo "cyclictest -t 5 -n -q -l 10000"
$TOOLS/cyclictest -t 5 -n -q -l 10000 &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

#start with unloaded test on 500 ns
$TOOLS/cyclictest -t1 -p 80 -i 500 -n -l 10000 -h 100 -q >> "unloaded_$DATELINE.log"
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi
#Stress cpu2 
$TOOLS/taskset -c 2 $TOOLS/stress -c 1 -m 1  -d 1 &
#Launch cyclictest on CPU2
$TOOLS/taskset -c 2 $TOOLS/cyclictest -t1 -p 80 -n -i 2000 -l 10000  &> /dev/null &
if [ $? -eq 0 ];then
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

#launch cyclic test on cpu2 for 500 distances with each distance of 500usec
$TOOLS/taskset 2 $TOOLS/cyclictest -m -t3 -n -p99 -i500 -d500 &> /dev/null &
if [ $? -eq 0 ];then 
    echo "cyclictest: Passed"
    RESULT=$((RESULT+1))
else
    echo "cyclictest: Failed"
fi

if [ $RESULT -eq 33 ];then
    echo "$TESTNAME: Passed"
	if [[ "" !=  "$pid" ]]; then
		echo "killing $pid"
		kill -9 $pid
	fi
else
    echo "$TESTNAME Failed"
    exit 1
fi
