#!/system/bin/bash

function prerequisite(){
    if [ -x ./run_netsocktests ] && [ -x ./run_afpackettests ] ;then #True if file exists and is executable.
        echo "run_afpackettests,run_netsocktests exists and is executable."
    else
        type chmod &>/dev/null || echo "chmod command not found"
        chmod 777 $cwd/run_*
    fi
}

function run(){
    passcount=0
    ./run_netsocktests
    if [ $? -eq 0 ];then
        passcount=$((passcount+1))
    fi
    ./run_afpackettests
    if [ $? -eq 0 ];then
        passcount=$((passcount+1))
    fi
    if [ $passcount -eq 2 ];then
        echo "Test net:PASS"
    else
        echo "Test net:FAIL"
    fi
}

cwd=$(pwd)
prerequisite
run
