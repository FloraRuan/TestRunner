#!/system/bin/bash

function run(){
    ./seccomp_bpf > output.res 
    if [ $? -eq 0 ];then
        echo "Test seccomp :Pass"
        exit 0
    else
        echo "Test seccomp :Fail"
        exit 1
    fi
}

run
