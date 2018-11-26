#!/system/bin/bash

function prerequisite(){
    if [ -x $cwd/on-off-test.sh ];then #True if file exists and is executable.
        echo "on-off-test.sh exists and is executable."
    else
        type chmod &>/dev/null || echo "chmod command not found"
        chmod 777 $cwd/on-off-test.sh
    fi
}

function run(){
    sh $cwd/on-off-test.sh -a
    if [ $? -eq 0 ];then
        echo "Test cpu-hotplug: Pass"
        exit 0
    else
        echo "Test cpu-hotplug: Fail"
        exit 1
    fi
}

cwd=$(pwd)
prerequisite
run
