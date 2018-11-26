#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"
MAX_CPUS=$(cat /sys/devices/system/cpu/kernel_max)

# global return value
__RET=""

function getarch(){
    chk_arch=$(uname -m |$TOOLS/busybox egrep -c "(aarch64|arm)")
    if [ $chk_arch -eq 1 ];then
        ARCH=64
    else
        ARCH=32
    fi
    __RET=$ARCH
}

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

function run(){
    getarch
    ARCH=$__RET
    # Ensuring user privilege
    if [ `id -u` -eq 0 ]; then
        $TOOLS/timerun 300 $TOOLS/trinity -qq -l off -C$MAX_CPUS -a $ARCH --dangerous 
    else
        $TOOLS/timerun 300 $TOOLS/trinity -qq -l off -C$MAX_CPUS -a $ARCH > /dev/null 2>&1
    fi
}

function runforcertaintime(){
    # Get enabled syscall names
    LISTOFSYSCALLS=$($TOOLS/trinity --list | busybox grep "Enabled" | busybox awk '{print $3}')
    if [ `id -u` -eq 0 ]; then
        FLAG="--dangerous"
    else
        FLAG=""
    fi
    for eachsyscall in ${LISTOFSYSCALLS}
    do
        if ! [[ $eachsyscall = *[^0-9]* ]] ; then
            echo "syscall => $eachsyscall"
            $TOOLS/timerun 300 $TOOLS/trinity -c $eachsyscall -l off -qq $FLAG > /dev/null 2>&1
        fi
    done
    echo "syscall fuzz Test : Pass"
    exit 0
}

testzone
runforcertaintime
cleanup
