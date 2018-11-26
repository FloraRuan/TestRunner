#!/system/bin/bash

function prerequisite(){
    chk=$(busybox zcat /proc/config.gz|grep -c "CONFIG_ZRAM=y")
    if [ $chk -eq 0 ];then
        echo "zram is not configured"
        exit 1
    fi
}

function run(){
    passcount=0
    ./zram.sh
    if [ $? -eq 0 ];then
        echo "Test Zram :Pass"
    else
        echo "Test Zram :Fail"
    fi
}

prerequisite
run
