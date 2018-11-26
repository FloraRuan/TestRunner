#!/system/bin/bash
source ../../../../init_env

subsysfs="/sys/kernel/debug/msm_subsys"
subsysdir="/sys/bus/msm_subsys/devices"

count=0
dmesg -c > /dev/null

function presetup(){
    for subsys in $subsysdir/*
    do
        if [ "$subsys" != "$subsysdir/subsys0" ]; then 
            echo "RELATED" > $subsys/restart_level
        fi
    done
}
function execute(){
    subsystem=$1
    cd $subsysfs
    if [ -e $subsystem ];then
        while true; 
        do
            status=$(cat $subsystem)
             sleep 1
            if [ $status -eq 0 ];then
                echo get > $subsystem
                break
            else
                echo put > $subsystem
            fi
        done
    fi
}
function check(){
    subsystem=$1
    restartcount=0
    restartcount=$(dmesg | grep -c "$subsystem: Brought out of reset")
    if [ $restartcount -ge 1 ];then
        echo "PIL load/Unload:Success for $subsystem"
        count=$((count+1))
    else
        echo "PIL load/Unload:Failure for $subsystem"
    fi
}
presetup
for each in adsp modem venus wcnss
do
    echo "Picking ${each}"
    execute ${each}
    check ${each}
done
if [ $count -eq 4 ];then
    echo "PIL load/Unload :Success"
    exit 0
else
    echo "PIL load/Unload :Failure"
    exit 1
fi

