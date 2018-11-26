#!/system/bin/bash

function run(){
    ./peeksiginfo
    if [ $? -eq 0 ];then
        echo "ptrace: Pass"
        exit 0
    else
        echo "ptrace: Fail"
        exit 1
    fi
}

run
