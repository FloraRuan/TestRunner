#!/system/bin/bash
# Import test suite definitions
source ../../../../init_env

source $TOOLS/functestlib.sh

# global return value
__RET=""

passcount=0
function hotplug_cpu(){
    echo "Running hotplug_cpu"
    cur_cpus=$(cat $__CPUHOTPLUG_DIR/kernel_max)
    hot_plug "$(seq 0 $cur_cpus)"
    chk=$__RET
    if [ $chk -eq 0 ]; then 
        passcount=$((passcount + 1))
    fi
    sleep 1
    hot_unplug "$(seq 0 $cur_cpus)"
    chk=$__RET
    if [ $chk -eq 0 ]; then 
        passcount=$((passcount + 1))
    fi
}

function clusterhotplug(){
    echo "Running clusterhotplug"
    if [ -e $__CPUHOTPLUG_DIR/cpu0/core_ctl ]; then
        if [ `cat $__CPUHOTPLUG_DIR/cpu0/core_ctl/is_big_cluster` -eq 1 ]; then
            cur_cpus=$(cat $__CPUHOTPLUG_DIR/cpu0/core_ctl/cpus|grep -c "cpus")
            hot_unplug "$(seq 0 $cur_cpus)"
            chk=$__RET
            if [ $chk -eq 0 ]; then 
                passcount=$((passcount + 1))
            fi
            sleep 1
            cluster2=$(cat $__CPUHOTPLUG_DIR/kernel_max)
            hot_plug "$(seq $cur_cpus $cluster2)"
            chk=$__RET
            if [ $chk -eq 0 ]; then 
                passcount=$((passcount + 1))
            fi
        elif [ `cat $__CPUHOTPLUG_DIR/cpu4/core_ctl/is_big_cluster` -eq 1  ]; then
            cur_cpus=$(cat $__CPUHOTPLUG_DIR/kernel_max)
            hot_unplug "$(seq 4 $cur_cpus)"
            chk=$__RET
            if [ $chk -eq 0 ]; then 
                passcount=$((passcount + 1))
            fi
            sleep 1
            hot_plug "$(seq 0 $cur_cpus)"
            chk=$__RET
            if [ $chk -eq 0 ]; then 
                passcount=$((passcount + 1))
            fi
        else
            hotplug_cpu
        fi
        
    else 
        cur_cpus=$(cat $__CPUHOTPLUG_DIR/kernel_max)
        cluster1=$((cur_cpus/2))
        hot_unplug "$(seq 0 $cluster1)"
        chk=$__RET
        if [ $chk -eq 0 ]; then 
            passcount=$((passcount + 1))
        fi
        sleep 1
        cluster2=$((cluster1 + 1))
        hot_plug "$(seq $cluster2 $cur_cpus)"
        chk=$__RET
        if [ $chk -eq 0 ]; then 
            passcount=$((passcount + 1))
        fi
    fi
}

disable_core_ctl
hotplug_cpu
clusterhotplug

if [ $passcount -ge 3 ]; then
    echo "hotplug: Passed"
else
    echo "hotplug: Failed"
    exit 1
fi
