#!/system/bin/sh
# test the topology files are present

source ../include/functions.sh

FILES="core_id core_siblings core_siblings_list physical_package_id \
thread_siblings thread_siblings_list"

for_each_cpu check_topology_files $FILES
test_status_show
