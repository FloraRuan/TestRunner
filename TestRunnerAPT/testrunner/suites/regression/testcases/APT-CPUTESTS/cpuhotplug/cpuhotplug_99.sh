#!/system/bin/sh
# ensure all the cpus are online when the tests are finished

source ../include/functions.sh

sanity_check() {
	ret=$(cat $CPU_PATH/online)
	if [ -n "$ret" ]; then
		return 0
	else
		return 1
	fi
}

check "all cpu are back online" "sanity_check"
test_status_show
