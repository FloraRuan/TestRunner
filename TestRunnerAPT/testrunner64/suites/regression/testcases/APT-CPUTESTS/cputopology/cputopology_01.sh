#!/system/bin/sh
# test the topology is implemented in the kernel

source ../include/functions.sh

check_physical_package_id() {

    package_id=$CPU_PATH/$1/topology/physical_package_id
    val=$(cat $package_id)

    check "topology is enabled" "test \"$val\" != \"-1\""
}

for_each_cpu check_physical_package_id || exit 1
test_status_show
