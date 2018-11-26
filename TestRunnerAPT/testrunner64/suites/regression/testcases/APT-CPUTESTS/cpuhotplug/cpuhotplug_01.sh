#!/system/bin/sh
# test the sysfs files are present

source ../include/functions.sh

FILES="online offline possible present"

for i in $FILES; do
    check_file $i $CPU_PATH || return 1
done

for_each_cpu check_cpuhotplug_files online
test_status_show
