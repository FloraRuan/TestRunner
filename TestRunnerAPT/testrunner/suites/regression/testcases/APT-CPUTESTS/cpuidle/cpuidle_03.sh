#!/system/bin/sh
# Run a cpuidle program killer and unplug one by one the cpus (except cpu0)

source ../include/functions.sh

CPUIDLE_KILLER="$TOOLS/cpuidle_killer"

is_root
if [ $? -ne 0 ]; then
    log_skip "run as non-root"
    exit 0
fi

restore_cpus() {
    for_each_cpu set_online
}

check_cpuidle_kill() {

    if [ "$1" = "cpu0" ]; then
	log_skip "skipping cpu0"
	return 0
    fi

    set_offline $1
    check "cpuidle program runs successfully (120 secs)" "$CPUIDLE_KILLER"
}

trap "restore_cpus; sigtrap" HUP INT TERM

for_each_cpu check_cpuidle_kill
restore_cpus
test_status_show
