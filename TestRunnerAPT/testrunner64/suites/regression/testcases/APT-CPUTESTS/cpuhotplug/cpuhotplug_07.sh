#!/system/bin/sh
# test userspace notification

source ../include/functions.sh
TMPFILE=cpuhotplug_07.tmp
UEVENT_READER="$TOOLS/uevent_reader"

check_notification() {
    cpu=$1

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    # damn ! udevadm is buffering the output, we have to use a temp file
    # to retrieve the output

    busybox rm -f $TMPFILE
    $UEVENT_READER $TMPFILE &
    pid=$!
    sleep 1

    set_offline $cpu
    set_online $cpu

    # let the time the notification to reach userspace
    # and buffered in the file
    sleep 1
    busybox kill -s INT $pid

    busybox grep "offline@/devices/system/cpu/$cpu" $TMPFILE
    ret=$?
    check "offline event was received" "test $ret -eq 0"

    busybox grep "online@/devices/system/cpu/$cpu" $TMPFILE
    ret=$?
    check "online event was received" "test $ret -eq 0"

    busybox rm -f $TMPFILE
}

for_each_cpu check_notification
test_status_show
