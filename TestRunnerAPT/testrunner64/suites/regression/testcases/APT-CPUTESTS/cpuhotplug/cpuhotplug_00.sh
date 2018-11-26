#!/system/bin/sh
# ensure all the cpus are online before the tests

source ../include/functions.sh

sanity_check() {
	CPU=${1#cpu}
	ret=$(cat $CPU_PATH/online)
	if [ -n "$ret" ]; then
		return 0
	else
		return 1
	fi
}

check "all cpu are online" "sanity_check"
test_status_show
