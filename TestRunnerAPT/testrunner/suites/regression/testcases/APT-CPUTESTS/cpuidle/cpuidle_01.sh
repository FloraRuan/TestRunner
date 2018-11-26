#!/system/bin/sh
# test the cpuidle files are present in the sysfs
source ../include/functions.sh

STATES="desc latency name power time usage"
FILES="current_driver current_governor_ro"

check_cpuidle_state_files() {

    dirpath=$CPU_PATH/$1/cpuidle
    shift 1

    for i in $(ls -d $dirpath/state*); do
	for j in $STATES; do
	    check_file $j $i || return 1
	done
    done

    return 0
}

check_cpuidle_files() {

    dirpath=$CPU_PATH/cpuidle

    for i in $FILES; do
	check_file $i $CPU_PATH/cpuidle || return 1
    done

    return 0
}

check_cpuidle_files

for_each_cpu check_cpuidle_state_files
test_status_show
