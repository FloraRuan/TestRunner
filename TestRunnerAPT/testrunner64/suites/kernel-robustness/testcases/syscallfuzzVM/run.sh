#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"
MAX_CPUS=$(ls /sys/devices/system/cpu | $TOOLS/busybox grep -c "cpu[0-9].*")

# global return value
__RET=""
#LIST OF SYSCALL w.r.t VM
VMSYSCALLS=("madvise" "mbind" "migrate_pages" "mincore" "mlockall" "mlock" "move_pages" "mprotect" "mremap" "msync" "munlockall" "munlock" "munmap" "remap_file_pages" "vmsplice")

function testzone(){
    if [ -e tmp ];then
        cd tmp
    else
        mkdir tmp
        cd tmp
    fi
}
function cleanup(){
    cd ..
    if [ -e tmp ];then
        rm -rf tmp
    fi
}

function check_tainted()
{
    if [ "$(cat /proc/sys/kernel/tainted)" != $TAINT ]; then
        echo "ERROR: Taint flag changed $(cat /proc/sys/kernel/tainted)"
        exit 1
    fi
}

function run(){
    TAINT=$(cat /proc/sys/kernel/tainted)
    if [ `id -u` -eq 0 ]; then
        FLAG="--dangerous"
    else
        FLAG=""
    fi
    for each in ${VMSYSCALLS[@]}
    do
        syscalls="-c mmap"
        for i in $(seq 0 2)
        do
            syscalls=$(echo $syscalls -c ${VMSYSCALLS[$(($RANDOM % 15))]})
        done
        echo "testing $syscalls"
        $TOOLS/trinity $syscalls -l off -qq -N $((1 + RANDOM % 100000)) -C $((1 + RANDOM % $((MAX_CPUS*12)))) $FLAG > /dev/null 2>&1
        check_tainted
    done
}

testzone
run
cleanup
