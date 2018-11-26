#!/system/bin/bash
source ../../../../init_env

source $TOOLS/functestlib.sh
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=$(cat /sys/devices/soc0/soc_id)
else
    soc_id=$(cat /sys/devices/system/soc/soc0/id)
fi
if [ $soc_id -eq 293 ]; then
    target="MSM8953"
elif [ $soc_id -eq 294 ]; then  
    target="MSM8937"
elif [ $soc_id -eq 303 ]; then  
    target="MSM8917"
elif [ $soc_id -eq 313 ]; then  
    target="MSM8940"
elif [ $soc_id -eq 246 ]; then  
    target="MSM8996"
elif [ $soc_id -eq 276 ]; then  
    target="MSM8976"
elif [ $soc_id -eq 292 ]; then
    target="8998"
elif [ $soc_id -eq 317 ]; then 
    target="660"
elif [$soc_id -eq 318 ]; then
    target="630" 
fi


## Test case definitions
# Check if /proc/device-tree is available
function test_has_proc_device_tree() {
    TEST="has_proc_device_tree"

    if [ ! -d /proc/device-tree ]; then
        echo "Unable to find /proc/device-tree"
    fi
    type find &>/dev/null || echo "find command not found"
    find /proc/device-tree &>/dev/null
    if [ $? -eq 0 ];then
        passcount=$((passcount + 1))
        # echo "has_proc_device_tree:Pass"
    fi
}

# Check if model is not empty
function test_device_tree_model_not_empty() {
    TEST="device_tree_model_not_empty"

    if [ ! -f /proc/device-tree/model ]; then
        echo "Unable to find /proc/device-tree/model"
    fi

    model=$(cat /proc/device-tree/model)
    if [ -z "$model" ]; then
        echo "Empty model description at /proc/device-tree/model"
        return 1
    fi

    echo "MODEL: $model" >/dev/null
    type grep &>/dev/null || echo "grep not found"
    echo "$model"|grep $target &>/dev/null
    if [ $? -eq 0 ]; then 
        # echo "device_tree_model_not_empty:Pass"
        passcount=$((passcount + 1)) 
    else
        echo "device_tree_model_not_empty but does not match with SocId:Fail"
    fi
}

passcount=0
# check we're root
if ! check_root; then
    echo "Please run the test case as root"
fi
# run the tests
test_has_proc_device_tree
test_device_tree_model_not_empty
if [ $passcount -eq 2 ];then
    # clean exit so lava-test can trust the results
    echo "Device tree test:Pass"
    exit 0
else
    echo "Device tree test:Fail"
    exit 1
fi
