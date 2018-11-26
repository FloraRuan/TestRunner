#!/system/bin/sh
# randomly hotplug cpus for 100 times (not percpu)

source ../include/functions.sh

randomize() {
    random=$(busybox od -A n -N 2 -t u2 /dev/urandom)
    number=$(echo $random % $1)

    if [ $hotplug_allow_cpu0 -eq 0 ]; then
        number=$(($number + 1))
    fi

    echo $number
}

random_stress() {
    cpu_present=$(cat /sys/devices/system/cpu/present | busybox cut -d '-' -f 2)
    #cpurand=$(randomize $cpu_present)
	intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
	cpurand=$(intrandfromrange 0 $cpu_present)
    # randomize will in range "1-$cpu_present) so cpu0 is ignored
    set_offline cpu$cpurand
    ret=$?
    check "cpu$cpurand is offline" "test $ret -eq 0"

    set_online cpu$cpurand
    ret=$?
    check "cpu$cpurand is online" "test $ret -eq 0"
}

for i in $(busybox seq 1 100); do random_stress ; done
test_status_show
