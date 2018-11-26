#!/system/bin/sh
# cpuhotplug is not supported or not the root user. Skipping all cpuhotplug tests...

source ../include/functions.sh

is_root
if [ $? -ne 0 ]; then
    log_skip "user is not root"
    exit 0
fi

check_cpuhotplug_sysfs_entry() {

    cpunum=$(ls $CPU_PATH | busybox grep "cpu[0-9].*" -c)

    if [ $cpunum -eq 1 ]; then
        echo "skip test, uniprocessor system"
        skip_tests cpuhotplug
        return 0
    fi

    for cpu in $cpus; do
        # assuming cpu0 can't be plugged out
        if [ $cpu != "cpu0" ]; then
            test -f $CPU_PATH/$cpu/online
            if [ $? -ne 0 ]; then
                echo "cpuhotplug is not supported. Skipping all cpuhotplug tests"
                skip_tests cpuhotplug
                return 0
            fi
        fi
    done
    return 1
}

check_cpuhotplug_sysfs_entry
