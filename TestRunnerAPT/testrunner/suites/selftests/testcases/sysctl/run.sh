#!/system/bin/bash

function prerequisite(){
    if [ -x ./run_numerictests ] && [ -x ./run_stringtests ] && [ -x ./common_tests ];then #True if file exists and is executable.
        echo "sysctl files exists and is executable."
    else
        type chmod &>/dev/null || echo "chmod command not found"
        chmod 777 $cwd/*
    fi
}

function run(){
    passcount=0
    ./run_numerictests
    if [ $? -eq 0 ];then
        passcount=$((passcount+1))
    fi
    ./run_stringtests
    if [ $? -eq 0 ];then
        passcount=$((passcount+1))
    fi
    if [ $passcount -eq 2 ];then
        echo "Test Sysctl :Pass"
        exit 0
    else
        echo "Test Sysctl :Fail"
        exit 1
    fi
}

cwd=$(pwd)
prerequisite
run
