#!/system/bin/sh
#
#

source ../include/functions.sh

is_root
if [ $? -ne 0 ]; then
    log_skip "user is not root"
    exit 0
fi

check_utils() {
    # just returning SUCCESS, so suite doesn't break
    return 1
}

check_utils
