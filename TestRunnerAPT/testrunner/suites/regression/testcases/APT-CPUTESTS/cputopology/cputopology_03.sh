#!/system/bin/sh
# test that the sched_domain files are present and show the topology related flags

source ../include/functions.sh

is_flag_set() {
    flag=$1
    mask=$2
    message=$3

    value=$(( $flag & $mask ))

    if [ $value -ne 0 ]; then
       echo "$message set"
    else 
       echo "$message not set"
    fi
}

are_flags_set() {
    val=$1
    domain_num=$2

    # flag value, flag description
    set -- 0x80  "domain$domain_num share cpu capacity flag" 0x100  "domain$domain_num share power domain flag" 0x200  "domain$domain_num share cpu package resources flag"

    if [ $(($# % 2)) -ne 0 ]; then
        echo "WARNING: malformed flag value, description in test"
    fi

    nflags=$(($# / 2))
    i=1

    while [ $i -le $nflags ] ; do
   flagval=$((2*i-1))
        eval "var1=\${$flagval}"
   flagstr=$((2*i))
        eval "var2=\${$flagstr}"
        is_flag_set $val "$var1" "$var2"
   i=$(( i + 1))
    done
}

check_sched_domain_flags() {

    cpu_num=$1
    domain_num=$2

    sched_domain_flags=/proc/sys/kernel/sched_domain/$cpu_num/domain$domain_num/flags
    val=$(cat $sched_domain_flags)

    check "sched_domain_flags (domain $domain_num)" "test \"$val\" != \"-1\""
    busybox printf "domain$domain_num flag 0x%x\n" $val

    mask=$((0x7fff))
    unexpected_bits=$((val & ~mask))

    if [ $unexpected_bits -ne 0 ]; then
        busybox printf "NOTE: unexpected flag bits 0x%x set\n" $unexpected_bits
    fi

    are_flags_set $val $domain_num
}

check_all_sched_domain_flags() {

    sched_domain_0_path=/proc/sys/kernel/sched_domain/cpu0

    if [ ! -d $sched_domain_0_path ]; then
        log_skip "no sched_domain directory present"
       return
    fi

    n=0

    sched_domain_flags_path=/proc/sys/kernel/sched_domain/$1/domain0/flags

    while [ -e $sched_domain_flags_path ]; do
        check_sched_domain_flags $1 $n
   n=$(( n + 1))
        sched_domain_flags_path=/proc/sys/kernel/sched_domain/$1/domain$n/flags
    done
}

for_each_cpu check_all_sched_domain_flags 1 || exit 1
test_status_show
