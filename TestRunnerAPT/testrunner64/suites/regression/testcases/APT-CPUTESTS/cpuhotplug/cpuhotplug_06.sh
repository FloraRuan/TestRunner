#!/system/bin/sh
# test interrupts show the right configuration in /proc/interrupts

source ../include/functions.sh

check_procinfo() {
    cpu=$1
    cpuid=$(echo $cpu | busybox awk '{print substr($0,4)}')

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    set_offline $cpu

    grep "CPU$cpuid" /proc/interrupts
    ret=$?

    check "offline processor not found in interrupts" "test $ret -ne 0"

    set_online $cpu
}

for_each_cpu check_procinfo
test_status_show
