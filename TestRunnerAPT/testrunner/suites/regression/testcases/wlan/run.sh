# /system/bin/bash

source ../../../../init_env
RESULT=0
# $TOOLS/regression output cpuhog
WLAN_MODULE="/system/lib/modules/pronto/pronto_wlan.ko"
# global return value
__RET=""

#Disabling wlan 
disable_wlan(){
    lsmod | grep wlan > /dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        rmmod wlan
        if [ $? -eq 0 ]; then
            # echo "wlan disabled"
            __RET=0
        else
            echo "unable to disable wlan"
            __RET=1
        fi
    fi
}

insert_wlan(){
    lsmod |grep wlan
    if [[ $? -ne 0 ]] ; then
        insmod $WLAN_MODULE
    fi
}


testcase(){
    echo "Running Rmmod and lsmod of Wlan stress test for 100 iterations..."
    success=0
    for i in $(seq 1 100); 
    do 
        disable_wlan
        isdisabled=$__RET
        if [[ $isdisabled -eq 0 ]]; then
            success=$((success + 1))
        fi
        insert_wlan
        sleep 1
    done
    if [[ $success -eq 100 ]];then
        echo "EnableandDisableWlanStressTest:Pass"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "EnableandDisableWlanStressTest:Fail"
    fi
}
testcase
if [ "$SUCCESS" == "1" ] ; then
	echo SUCCESS
else
	echo FAILED
	RESULT=1
fi
exit $RESULT
