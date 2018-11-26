#!/system/bin/bash

export TOOLS="/data/local/tmp/testrunner/common"
SUCCESS=0
DEFAULTDURATION=60
# No matter how many busy threads you start, you can only execute one per core at a time
MAX_CPUS=$(cat /sys/devices/system/cpu/kernel_max)
MEMORYCOPYTHREADS=2
MEMORYINVERTTHREADS=4
FILES=("sat.diskthread.a" "sat.diskthread.b")
LOGFILE="xxx.log"
VERBOSE=20
FILE=("/data/local/tmp/sat-file-test" "/sdcard/sat-file-test")
FILESIZE=("1024" "1gb")
COUNT=("7" "5" "3" "4")
STRESSTHREADS=${COUNT[$RANDOM % ${#COUNT[@]} ]}
# global return value
__RET=""

function removelogfiles(){
    rm -rf $LOGFILE ${FILES[0]} ${FILES[1]} ${FILE[0]} ${FILE[1]}
}

function getfreemem(){
    # Need to run drop_caches before checking free memory Linux typically ends up allocating pages pretty randomly overy system memory so you will likely end up allocating memory on every memory bank and rank
    sysctl -w vm.drop_caches=3 > /dev/null 2>&1
    # type free &>/dev/null || echo "free command not found"
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    BUFFER=$(intrandfromrange 4 $MAX_CPUS)
    DDR=$($TOOLS/busybox free -m | $TOOLS/busybox awk '$2~/buf/{print $4}') 
    DDR=$((DDR-BUFFER))
    __RET=$DDR
}

function getonlinecpu(){
    onlinecpus=$(cat /sys/devices/system/cpu/online|$TOOLS/busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
    NR > 1  { print "," }
    NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
           { print $1 }')
    __RET=$(echo $onlinecpus)
}

function stressapptest1(){
    sysctl -w vm.drop_caches=3 > /dev/null 2>&1
    $TOOLS/stressapptest -s $DEFAULTDURATION -M 32 -C $STRESSTHREADS -W  > /dev/null 2>&1
}

function stressapptest2(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 256 ];then
        DDR_MB=256
    fi
    $TOOLS/stressapptest -s $((DEFAULTDURATION*2)) -M $DDR_MB -C $STRESSTHREADS -W -v $VERBOSE > /dev/null 2>&1
}
function stressapptest3(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    $TOOLS/stressapptest -s $((DEFAULTDURATION*15)) -M $DDR_MB --max_errors 1 > /dev/null 2>&1
}
function stressapptest4(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 562 ];then
        DDR_MB=562
    fi
    $TOOLS/stressapptest -s $((DEFAULTDURATION*600)) -M $DDR_MB -m $MEMORYCOPYTHREADS -W -f ${FILES[0]} -f ${FILES[1]} -l $LOGFILE > /dev/null 2>&1
}
function stressapptest5(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    $TOOLS/stressapptest -s $((DEFAULTDURATION*120)) -M $DDR_MB -m $MEMORYCOPYTHREADS -W > /dev/null 2>&1
}
function stressapptest6(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) –M $DDR_MB -i $MEMORYINVERTTHREADS -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS > /dev/null 2>&1
}

function stressapptest7(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) –M $DDR_MB -i $MEMORYINVERTTHREADS -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS -f $RANDOMFILE --filesize ${FILESIZE[1]} > /dev/null 2>&1
}
function stressapptest8(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) –M $DDR_MB -i $MEMORYINVERTTHREADS -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS -f $RANDOMFILE --filesize ${FILESIZE[1]} > /dev/null 2>&1
}
function stressapptest9(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) -i $MEMORYINVERTTHREADS -M $DDR_MB -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS -f $RANDOMFILE --filesize ${FILESIZE[0]} --random-threads $MEMORYINVERTTHREADS > /dev/null 2>&1
}
function stressapptest10(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) -i $MEMORYINVERTTHREADS -M $DDR_MB -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS -f $RANDOMFILE --filesize ${FILESIZE[0]} --random-threads $MEMORYINVERTTHREADS > /dev/null 2>&1
}
function stressapptest11(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) -i $MEMORYINVERTTHREADS -M $DDR_MB -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS --cc_test > /dev/null 2>&1
}
function stressapptest12(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) -i $MEMORYINVERTTHREADS -M $DDR_MB -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS --local_numa > /dev/null 2>&1

}
function stressapptest13(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    $TOOLS/stressapptest -s $((DEFAULTDURATION/2)) -i $MEMORYINVERTTHREADS -M $DDR_MB -m $MEMORYTHREADS -W -C $MEMORYINVERTTHREADS -n 127.0.0.1 --listen > /dev/null 2>&1
}
function stressapptest14(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    MEMORYINVERT=$((MEMORYINVERTTHREADS+4))
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -s $((DEFAULTDURATION*50)) -m $MEMORYTHREADS -M $DDR_MB -i $MEMORYINVERT -C $MEMORYTHREADS -W -f $RANDOMFILE --filesize ${FILESIZE[0]} --random-threads 4 -n 127.0.0.1 --listen > /dev/null 2>&1
}
function stressapptest15(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 512 ];then
        DDR_MB=512
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    MEMORYINVERT=$((MEMORYINVERTTHREADS+4))
    RANDOMFILE=${FILE[$RANDOM % ${#FILE[@]} ]}
    $TOOLS/stressapptest -m $MEMORYTHREADS -s 10000 -M $DDR_MB -l $RANDOMFILE -A -C $MEMORYTHREADS -W --cc_test > /dev/null 2>&1
}
function stressapptest16(){
    getfreemem 
    DDR_MB=$__RET
    if [ $DDR_MB -gt 256 ];then
        DDR_MB=256
    fi
    intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
    MEMORYTHREADS=$(intrandfromrange 0 $MAX_CPUS)
    
    getonlinecpu
    onlinecpu=$__RET
    array=(${onlinecpu//,/ })
    
    $TOOLS/stressapptest -m $MEMORYTHREADS -M $DDR_MB -s $DEFAULTDURATION &
    pid1=$!
    $TOOLS/stressapptest -m $MEMORYTHREADS -M $DDR_MB -s $DEFAULTDURATION & 
    pid2=$!
    $TOOLS/stressapptest -m $MEMORYTHREADS -M $DDR_MB -s $DEFAULTDURATION & 
    pid3=$!
    $TOOLS/taskset -cp ${array[0]} $pid1
    $TOOLS/taskset -cp ${array[1]} $pid2
    $TOOLS/taskset -cp ${array[2]} $pid3
}
