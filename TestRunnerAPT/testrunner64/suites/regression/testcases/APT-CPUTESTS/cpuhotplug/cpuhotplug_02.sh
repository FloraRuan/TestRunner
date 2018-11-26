#!/system/bin/sh
# test the cpu state is reflected in sysfs


source ../include/functions.sh

check_state() {
    cpu=$1
    dirpath=$CPU_PATH/$cpu
    shift 1

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    set_offline $cpu
    state=$(get_online $cpu)

    check "$cpu is offline" "test $state -eq 0"
    if [ $? -ne 0 ]; then
	set_online $cpu
	return 1
    fi

    set_online $cpu
    state=$(get_online $cpu)

    check "$cpu is online" "test $state -eq 1"
    if [ $? -ne 0 ]; then
	return 1
    fi

    return 0
}

for_each_cpu check_state
test_status_show
