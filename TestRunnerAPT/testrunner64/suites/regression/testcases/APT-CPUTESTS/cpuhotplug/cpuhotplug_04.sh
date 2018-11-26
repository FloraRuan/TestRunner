#!/system/bin/sh
# test task is migrated with task affinity

source ../include/functions.sh

source ../../../../../init_env

CPUBURN=$TOOLS/cpuburn

check_task_migrate() {
    cpu=$1
    cpuid=$(echo $cpu | busybox awk '{print substr($0,4)}')
    cpumask=$((1 << cpuid))
    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    $TOOLS/taskset 0x$cpumask $CPUBURN $cpu &
    pid=$!
    sleep 1 # let taskset to do setaffinity before checking

    ret=$($TOOLS/taskset -p $pid | busybox cut -d ':' -f 2)
    ret=$(echo $ret) # remove trailing whitespace
    ret=$(busybox printf "%d" 0x$ret)
    check "affinity is set" "test $cpumask -eq $ret"

    sleep 1
    set_offline $cpu
    ret=$?

    check "offlining a cpu with affinity succeed" "test $ret -eq 0"

    ret=$($TOOLS/taskset -p $pid | busybox cut -d ':' -f 2)
    ret=$(echo $ret)
    ret=$(busybox printf "%d" 0x$ret)
    check "affinity changed" "test $cpumask -ne $ret"

    busybox kill $pid

    # in any case we set the cpu online in case of the test fails
    set_online $cpu

    return 0
}

for_each_cpu check_task_migrate
test_status_show
