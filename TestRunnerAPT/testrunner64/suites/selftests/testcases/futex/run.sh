#!/system/bin/bash

function run(){
    ./run_futex
    if [ $? -eq 0 ];then
        echo "futex test: Pass"
        exit 0
    else
        echo "futex test: Fail"
        exit 1
    fi
}

run
