#!/system/bin/sh
# test the change of the frequency is effective in 'userspace' mode
source ../include/functions.sh

check_frequency() {

    cpu=$1
    newfreq=$2

    shift 2

    oldgov=$(get_governor $cpu)
    oldfreq=$(get_frequency $cpu)

    set_governor $cpu userspace
    set_frequency $cpu $newfreq

    check "setting frequency '$(frequnit $newfreq)'" "test \"$(get_frequency $cpu)\" = \"$newfreq\""

    set_frequency $cpu $oldfreq
    set_governor $cpu $oldgov
}

supported=$(cat $CPU_PATH/cpu0/cpufreq/scaling_available_governors | grep "userspace")
if [ -z "$supported" ]; then
    log_skip "userspace not supported"
else
    for_each_cpu for_each_frequency check_frequency || exit 1
fi
test_status_show
