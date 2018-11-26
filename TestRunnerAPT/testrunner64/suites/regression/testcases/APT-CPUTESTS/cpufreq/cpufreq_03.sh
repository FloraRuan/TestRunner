#!/system/bin/sh
# test the governor change is effective

source ../include/functions.sh

check_governor() {

    cpu=$1
    newgov=$2

    shift 2

    oldgov=$(get_governor $cpu)

    set_governor $cpu $newgov

    check "governor change to '$newgov'" "test \"$(get_governor $cpu)\" = \"$newgov\""

    set_governor $cpu $oldgov
}

for_each_cpu for_each_governor check_governor || exit 1
test_status_show
