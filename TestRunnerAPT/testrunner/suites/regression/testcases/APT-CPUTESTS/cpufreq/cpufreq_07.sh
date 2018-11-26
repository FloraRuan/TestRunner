#!/system/bin/sh
# test the load of the cpu affects the frequency with 'ondemand'

source ../include/functions.sh
source ../../../../../init_env
CPUBURN=$TOOLS/cpuburn

check_interactive() {

    cpu=$1
    maxfreq=$(get_max_frequency $cpu)
    minfreq=$(get_min_frequency $cpu)
    curfreq=$(get_frequency $cpu)

    set_governor $cpu interactive

    # wait for a quescient point
    for i in $(busybox seq 1 10); do

	if [ "$minfreq" -eq "$(get_frequency $cpu)" ]; then

	    $CPUBURN $cpu &
	    pid=$!

	    sleep 1
	    # wait_latency $cpu
	    curfreq=$(get_frequency $cpu)
	    kill $pid

	    check "'interactive' increase frequency on load" "test \"$curfreq\" = \"$maxfreq\""

	    sleep 1
		counter=0
		START=$(date +%s);
		while [ 1 ]; do
			curfreq=$(get_frequency $cpu)
			if [ $curfreq -eq $minfreq ] ; then
				check "'interactive' decrease frequency on idle" "test \"$curfreq\" = \"$minfreq\""
				if [ $counter -gt 0 ] ; then
					END=$(date +%s)
					echo $((END-START)) | busybox awk '{print int($1/60)"m:"int($1%60)"s"}'
				fi
				break
			fi
			if [ $counter -ge 5 ] ; then
				echo "unable set min freq"
				END=$(date +%s)
				echo $((END-START)) | busybox awk '{print int($1/60)":"int($1%60)}'
				break
			fi
			counter=$((counter+1))
			sleep 2
		done
		# check "'interactive' decrease frequency on idle" "test \"$curfreq\" = \"$minfreq\""

	    return 0
	fi

	sleep 1

    done

    log_skip "can not reach a quescient point for 'interactive'"

    return 1
}

supported=$(cat $CPU_PATH/cpu0/cpufreq/scaling_available_governors | busybox grep "interactive")
if [ -z "$supported" ]; then
    log_skip "interactive not supported"
    return 0
fi

save_governors

trap "restore_governors; sigtrap" HUP INT TERM

for_each_cpu check_interactive

restore_governors
test_status_show
