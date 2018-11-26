#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"
SUCCESS=0
THREADNUMBER=10
MALLOCCOUNT=3
MALLOCSIZE=2
LOOPCOUNT=100
DURATION=900

function malloctests(){
    passcount=0
    MALLACTESTLIST=("mallacTest1" "mallacTest2" "mallacTest3" "mallacTest4" "mallacTest5")
    for eachmallactest in ${MALLACTESTLIST[@]}
    do
        $TOOLS/timerun $DURATION $TOOLS/$eachmallactest > /dev/null 2>&1
        if [ $? -eq 0 ];then
            passcount=$((passcount+1))
        fi
    done
    if [ ${#MALLACTESTLIST[@]} -eq $passcount ];then
        SUCCESS=$((SUCCESS+1))
    fi
}

function ptmalloctests(){
    passcount=0
    COUNT=("7" "5" "3" "1")
    MALLOCCOUNT=${COUNT[$RANDOM % ${#COUNT[@]} ]}
    type time &>/dev/null || echo "time command not found"
    PTMALLOCTESTLIST=(64 128 256 512 1024 2048)
    for eachptmallactest in "${PTMALLOCTESTLIST[@]}"
    do
        /system/bin/time $TOOLS/ptmalloc_test $eachptmallactest $MALLOCCOUNT > /dev/null 2>&1
        if [ $? -eq 0 ];then
            passcount=$((passcount+1))
        fi
    done
    if [ ${#PTMALLOCTESTLIST[@]} -eq $passcount ];then
        SUCCESS=$((SUCCESS+1))
    fi
}

function benchmark(){
    passcount=0
    BENCHMARKLIST=("tinymembench" "arm_c_benchmark_arm_generic")
    for eachbenchmark in ${BENCHMARKLIST[@]}
    do
        $TOOLS/timerun $DURATION $TOOLS/$eachbenchmark > /dev/null 2>&1
        if [ $? -eq 0 ];then
            passcount=$((passcount+1))
        fi
    done
    $TOOLS/timerun $DURATION $TOOLS/multithread-malloc-benchmark-malloc --thread=$THREADNUMBER --size=$MALLOCSIZE --count=$MALLOCCOUNT --loop=$LOOPCOUNT > /dev/null 2>&1
    if [ $? -eq 0 ];then
        passcount=$((passcount+1))
    fi
    if [ $passcount -eq 3 ];then
        SUCCESS=$((SUCCESS+1))
    fi
}
malloctests
ptmalloctests
benchmark
if [ $SUCCESS -eq 3 ];then
    echo "Test Success."
    exit 0
fi
echo "Test Failure."
exit 1
