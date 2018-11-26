#!/ssytem/system/bin/sh
# test the load of the cpu does not affect the frequency with 'powersave'


source ../include/functions.sh

CPUBURN=$TOOLS/cpuburn

check_powersave() {

    cpu=$1
    minfreq=$(get_min_frequency $cpu)
    curfreq=$(get_frequency $cpu)

    set_governor $cpu powersave

    wait_latency $cpu
    curfreq=$(get_frequency $cpu)

    check "'powersave' sets frequency to $(frequnit $minfreq)" "test \"$curfreq\" = \"$minfreq\""

    $CPUBURN $cpu &
    pid=$!

    wait_latency $cpu
    curfreq=$(get_frequency $cpu)
    kill $pid

    check "'powersave' frequency $(frequnit $minfreq) is fixed" "test \"$curfreq\" = \"$minfreq\""

    return 0
}

save_governors

supported=$(cat $CPU_PATH/cpu0/cpufreq/scaling_available_governors | busybox grep "powersave")
if [ -z "$supported" ]; then
    log_skip "powersave not supported"
    return 0
fi

trap "restore_governors; sigtrap" HUP INT TERM

for_each_cpu check_powersave

restore_governors
test_status_show
