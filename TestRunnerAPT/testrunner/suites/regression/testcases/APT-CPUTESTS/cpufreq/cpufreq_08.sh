#!/system/bin/sh
# test the load of the cpu does not affect the frequency with 'userspace'

source ../include/functions.sh

CPUBURN=$TOOLS/cpuburn

check_frequency() {
    cpu=$1
    freq=$2

    $CPUBURN $cpu &
    pid=$!

    set_frequency $cpu $freq

    wait_latency $cpu
    curfreq=$(get_frequency $cpu)
    kill $pid

    check "'userspace' $(frequnit $freq) is fixed" "test \"$curfreq\" = \"$freq\""

    return 0
}

check_userspace() {

    cpu=$1
    maxfreq=$(get_max_frequency $cpu)
    minfreq=$(get_min_frequency $cpu)
    curfreq=$(get_frequency $cpu)

    set_governor $cpu userspace

    for_each_frequency $cpu check_frequency $minfreq
}

save_governors

supported=$(cat $CPU_PATH/cpu0/cpufreq/scaling_available_governors | busybox grep "userspace")
if [ -z "$supported" ]; then
    log_skip "userspace not supported"
    return 0
fi

trap "restore_governors; sigtrap" HUP INT TERM

for_each_cpu check_userspace

restore_governors
test_status_show
