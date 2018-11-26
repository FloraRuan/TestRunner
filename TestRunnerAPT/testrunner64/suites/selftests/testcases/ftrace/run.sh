#!/system/bin/bash

function prerequisite(){
    if [ -x $cwd/ftracetest ];then #True if file exists and is executable.
        echo "ftracetest exists and is executable."
    else
        type chmod &>/dev/null || echo "chmod command not found"
        chmod 777 $cwd/ftracetest
    fi
}

function cleanup(){
    type rm &>/dev/null || echo "rm command not found"
    if [ -e $cwd/logs ];then
        rm -rf $cwd/logs
    fi
}

function run(){
    $cwd/ftracetest > output.res
    if [ $? -eq 0 ];then
        echo "ftracetest: Pass"
        cleanup
        exit 0
    else
        echo "ftracetest: Fail"
        cleanup
        exit 1
    fi
}

cwd=$(pwd)
prerequisite
run
