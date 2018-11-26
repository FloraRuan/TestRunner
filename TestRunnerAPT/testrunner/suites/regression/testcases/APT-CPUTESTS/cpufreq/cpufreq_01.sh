#!/system/bin/sh
#
#test the cpufreq framework is available for frequency

source ../include/functions.sh

FILES="scaling_available_frequencies scaling_cur_freq scaling_setspeed"

for_each_cpu check_cpufreq_files $FILES
test_status_show
