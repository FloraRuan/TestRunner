#!/system/bin/bash

function run(){
    ./get_size
    if [ $? -eq 0 ];then
        echo "Test size :Pass"
    else
        echo "Test size :Fail"
    fi
}

run
