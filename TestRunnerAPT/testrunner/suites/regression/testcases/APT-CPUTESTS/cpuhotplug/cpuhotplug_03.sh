#!/system/bin/sh
# test the affinity does not work on an offline cpu

source ../include/functions.sh
source ../../../../../init_env

check_affinity_fails() {
    cpu=$1
    cpuid=$(echo $cpu | busybox awk '{print substr($0,4)}')

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    set_offline $cpu

    $TOOLS/taskset -c $cpuid busybox true 2> /dev/null
    ret=$?
    check "setting affinity on $cpu" "test $ret -ne 0"

    set_online $cpu

    return 0
}

for_each_cpu check_affinity_fails
test_status_show
