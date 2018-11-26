#!/system/bin/bash
export TOOLS='/data/local/tmp/testrunner/common'

CPUHOTPLUG_DIR="/sys/devices/system/cpu"

#Pick random src from SRC
Filepath=("/data/local/tmp/affinity.txt" "/sdcard/affinity.txt")
SRC=("/dev/random" "/dev/urandom" "/dev/zero")
BYTES=("128" "64" "32")
CONV=("notrunc" "noerror" "sync" "fsync")
RANDOMSRC=${SRC[$RANDOM % ${#SRC[@]} ]}
passcount=0
# global return value
__RET=""
function getofflinecpu(){
    offlinecpus=$(cat $CPUHOTPLUG_DIR/offline|$TOOLS/busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
    NR > 1  { print "," }
    NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
           { print $1 }')
    __RET=$(echo $offlinecpus)
}

function getonlinecpu(){
    onlinecpus=$(cat $CPUHOTPLUG_DIR/online|$TOOLS/busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
    NR > 1  { print "," }
    NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
           { print $1 }')
    __RET=$(echo $onlinecpus)
}

function setaffinity_offlinecore(){
    pid=$1
    getofflinecpu
    offlinecpu=$__RET
    array=(${offlinecpu//,/ })
    $TOOLS/taskset -cp ${array[0]} $pid #taskset -c -p 1 31777
    if [ $? -ne 0 ];then
        passcount=$((passcount + 1))
    fi
}
function hotplugcore(){
    pid=$1
    getonlinecpu
    onlinecpu=$__RET
    array=(${onlinecpu//,/ })
    $TOOLS/busybox nohup $TOOLS/taskset -cp ${array[0]} $pid & #taskset -c -p 1 31777
    echo 0 > $CPUHOTPLUG_DIR/cpu${array[0]}/online
    if [ `cat $CPUHOTPLUG_DIR/cpu${array[0]}/online` -eq 0 ];then
        sleep 2
        $TOOLS/taskset -p $pid #taskset -c -p 1 31777
        if [ $? -eq 0 ];then
            passcount=$((passcount + 1))
        fi
    fi
}
# How many kilobytes free space do we have?
function check_free()
{
    sync
    dataval=`echo $RANDOMSRC | $TOOLS/busybox grep -c "/data"`
    if [ $dataval -eq 1 ]
    then
        $TOOLS/busybox df /data | $TOOLS/busybox tail -1 | $TOOLS/busybox awk '{print $4}'
    else
        $TOOLS/busybox df /data | $TOOLS/busybox tail -1 | $TOOLS/busybox awk '{print $4}'
    fi
}
function cleanup(){
    if [ -e "/data/local/tmp/affinity.txt" ];then
        rm -rf "/data/local/tmp/affinity.txt"
    fi
    if [ -e "/sdcard/affinity.txt" ];then
        rm -rf "/sdcard/affinity.txt"
    fi
}
function run(){
    Value=$((`check_free`-(1024)))

    #Pick random path from Filepath
    RANDOMFILE=${Filepath[$RANDOM % ${#Filepath[@]} ]}

    # Pick random src from SRC
    RANDOMSRC=${SRC[$RANDOM % ${#SRC[@]} ]}

    #Pick random bytes from BYTES
    RANDOMBYTES=${BYTES[$RANDOM % ${#BYTES[@]} ]}

    #Pick random conv from CONV
    RANDOMCONV=${CONV[$RANDOM % ${#CONV[@]} ]}

    $TOOLS/busybox dd if=$RANDOMSRC of=$RANDOMFILE bs=$RANDOMBYTES conv=$RANDOMCONV seek=$Value &
    pid1=$!
    setaffinity_offlinecore $pid1
    sleep 2
    hotplugcore $pid1
    type kill &>/dev/null || echo "kill command not found"
    if [ $? -ne 0 ];then
        $TOOLS/busybox kill $pid1
    else
        kill -9 $pid1
    fi
}

run
if [ "$passcount" == "2" ];then
    echo "Offline and online taskset:PASS"
    cleanup
    exit 0
else
    echo "Offline and online taskset:Fail"
    cleanup
    exit 1
fi
