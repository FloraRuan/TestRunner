#!/system/bin/sh
# Test capacity calculation (this is based on the algorithm in arch/arm/kernel/topology.c)
# make sure that the information in /sys/firmware/devicetree/base/cpus corresponds to that reported by the kernel log.

source ../include/functions.sh

calc_freq()
{
    byte1=$1
    byte2=$2
    byte3=$3
    byte4=$4
    freq=$((byte1*0x1000000+byte2*0x10000+byte3*0x100+byte4))
}

# eff is the relative cpu efficiency of each processor
set_eff() {
    type=$1

    case $type in
        arm,cortex-a15) eff=3891 ;;
        arm,cortex-a7)  eff=2048 ;;
        * ) eff=1024 ;;
    esac
}

# Calculate a middle efficiency, This is later used to scale
# the cpu_capacity such that an 'average' CPU is of middle capacity.

calc_mid_capacity()
{
    dt_cpus=$(ls /sys/firmware/devicetree/base/cpus | grep "cpu@[0-9].*")
    min_capacity=$((0xffffffff))
    max_capacity=0
    sched_capacity_shift=10

    for dt_cpu in $dt_cpus; do
        if [ ! -f /sys/firmware/devicetree/base/cpus/$dt_cpu/clock-frequency ]; then
           log_skip "no clock frequency file present"
           return
        fi
        if [ ! -f /sys/firmware/devicetree/base/cpus/$dt_cpu/compatible ]; then
           log_skip "no compatible file present"
           return
        fi
        filename=/sys/firmware/devicetree/base/cpus/$dt_cpu/clock-frequency
        bytes=$(od -t u1 -A n $filename)
        calc_freq $bytes
        cpu_type=$(cat /sys/firmware/devicetree/base/cpus/$dt_cpu/compatible)
   set_eff $cpu_type
   capacity=$((($freq>>20)*$eff))
   if [ $capacity -gt $max_capacity ]; then
       max_capacity=$capacity
   fi
   if [ $capacity -lt $min_capacity ]; then
       min_capacity=$capacity
   fi
        if [ $(((4 * $max_capacity))) -lt $(((3 * ($max_capacity + $min_capacity)))) ]; then
                middle_capacity=$((($min_capacity + $max_capacity)>>($sched_capacity_shift+1)))
        else
                middle_capacity=$(((($max_capacity / 3)>>($sched_capacity_shift-1))+1))
        fi
    done
}

cpu_num=0

verify_cpu_capacity()
{
    for dt_cpu in $dt_cpus; do
        if [ ! -f /sys/firmware/devicetree/base/cpus/$dt_cpu/clock-frequency ]; then
           log_skip "no clock frequency file present"
           return
        fi
        if [ ! -f /sys/firmware/devicetree/base/cpus/$dt_cpu/compatible ]; then
           log_skip "no compatible file present"
           return
        fi
        filename=/sys/firmware/devicetree/base/cpus/$dt_cpu/clock-frequency
        bytes=$(od -t u1 -A n $filename)
        calc_freq $bytes
        cpu_type=$(cat /sys/firmware/devicetree/base/cpus/$dt_cpu/compatible)
   set_eff $cpu_type
   capacity=$((($freq>>20)*$eff/$middle_capacity))
   expected_capacity_string=$(dmesg | grep "CPU$cpu_num: update cpu_capacity")
   expected_capacity=${expected_capacity_string##*cpu_capacity}
   echo "cpu num: $cpu_num capacity $capacity expected capacity $expected_capacity"
   check "expected capacity for cpu$cpu_num equal to computed capacity" "test $expected_capacity -eq $capacity"

   cpu_num=$((cpu_num+1))
    done
}

verify_capacity()
{
    if ! [ -d /sys/firmware/devicetree/base/cpus ]; then
   log_skip "no cpus directory present"
       return
    fi

    calc_mid_capacity
    dt_cpus=$(ls -l /sys/firmware/devicetree/base/cpus | busybox egrep "cpu@.{1,2}$")
    verify_cpu_capacity
    dt_cpus=$(ls -l /sys/firmware/devicetree/base/cpus | busybox egrep "cpu@.{3,4}$")
    verify_cpu_capacity
}

verify_capacity || exit 1
test_status_show
