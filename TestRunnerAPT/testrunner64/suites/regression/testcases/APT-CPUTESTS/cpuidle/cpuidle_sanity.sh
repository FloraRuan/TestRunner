#!/system/bin/sh
# cpuidle is not supported or not the root user. Skipping all cpuidle tests...
source ../include/functions.sh

is_root
if [ $? -ne 0 ]; then
    log_skip "user is not root"
    exit 0
fi

check_cpuidle_sysfs_entry() {

    dirpath=$CPU_PATH/cpuidle

    busybox test -d $dirpath
    if [ $? -ne 0 ]; then
        echo "cpuidle is not supported. Skipping all cpuidle tests"
        skip_tests cpuidle
        return 0
    fi
    return 1
}

check_cpuidle_sysfs_entry
