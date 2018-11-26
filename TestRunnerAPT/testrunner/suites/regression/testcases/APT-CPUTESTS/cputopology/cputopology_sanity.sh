#!/system/bin/sh
# Checking for topology dir in each cpu
source ../include/functions.sh

is_root
if [ $? -ne 0 ]; then
    log_skip "User is not root"
    exit 0
fi

check_cputopology_sysfs_entry() {
    for cpu in $cpus; do
        cputopology_sysfs_dir="$CPU_PATH/$cpu/topology"

        test -d $cputopology_sysfs_dir
        if [ $? -ne 0 ]; then
            echo "cputopology entry not found. Skipping all cputopology tests"
            skip_tests cputopology
            return 0
        fi
    done
    return 1
}

check_cputopology_sysfs_entry
