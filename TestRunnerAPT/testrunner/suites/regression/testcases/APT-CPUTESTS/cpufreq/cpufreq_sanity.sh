#!/system/bin/sh
# cpufreq is not supported or not the root user. Skipping all cpufreq tests...

source ../include/functions.sh

is_root
if [ $? -ne 0 ]; then
    log_skip "user is not root"
    exit 0
fi

check_cpufreq_sysfs_entry() {

    dirpath=$CPU_PATH/cpufreq

    test -d $dirpath
    if [ $? -ne 0 ]; then
        echo "cpufreq is not supported. Skipping all cpufreq tests"
        skip_tests cpufreq
        return 0
    fi
    return 1
}

check_cpufreq_sysfs_entry
