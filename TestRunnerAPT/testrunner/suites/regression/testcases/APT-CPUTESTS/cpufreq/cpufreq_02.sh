#!/system/bin/sh
# test the cpufreq framework is available for governor

source ../include/functions.sh

FILES="scaling_available_governors scaling_governor"

for_each_cpu check_cpufreq_files $FILES
test_status_show
