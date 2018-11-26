#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"
# Source the common functions for the test cases
# source ../../functions.sh
# source ../../boota7.sh
# source ../../boota15.sh

function usage()
{
    echo ""
    echo "usage: $0 [<option> <argument>] .."
    echo ""
    echo "Options: -f <operating frequency> [big/little; Default: big]"
    echo "         -c <operate on this cpu> [this option can be specified multiple times]"
    echo "         -d <take this cpu offline>"
    echo "         -e <bring this cpu online>"
    echo "         -t <number of seconds> [Default: 10]"
    echo "         -m <amount of memory> [Default: 16M]"
    echo "         -s <periodic switching interval in msec> [Default: 50]"
    echo "         -r <random switching seed> [Default: 100]"
    echo "         -l <random switching seed limit> [Default: 1000]"
    echo "         -n <threads to be executed on specific cpus>"
    echo "         -S single-sync Sequential half transition (e.g.: big->barrier->little->barrier)"
    echo ""
    echo "Example of periodic switching: $0 -f big -c 0 -c 1 ... -c $large_cpu_number -s 50"
    echo "Example of random switching: $0 -f big -c 0 -c 1 ... -c $large_cpu_number -r 100 -l 1000"
    echo "Example of periodic switching while spawning threads on cpu0 and cpu3: $0 -f big -c 0 -c 1 ... -c $large_cpu_number -n 0 ... $large_cpu_number -s 50"
    echo "Example of simultaneous thread while spawning threads on all cpus: $0 -f big -c 0 -n 0 ... $large_cpu_number -s 100 -S"
    exit 1
}

CC_STATUS=0;
SWITCHER_STATUS=0;

total_no_of_cpu=$(ls /sys/devices/system/cpu/cpu*/online | wc -l)
large_cpu_number=$(cat /sys/devices/system/cpu/kernel_max)

TASKSET=affinity_tools

CPU_FAST=
CPU_SLOW=

#ARM
IMPLEMENTER=0x41
#A7
PART_SLOW=0xc07
#A15
PART_FAST=0xc0f
eachslow=
eachfast=
EACH_CPU=

function get_no_of_cpus ()
{
    cpu=0
    while [ $cpu -lt $total_no_of_cpu ];
    do
    $TOOLS/affinity_tools -part $cpu,$IMPLEMENTER,$PART_SLOW >/dev/null
        if [ $? == 0 ] ; then
            eachslow=" -c "
            CPU_SLOW=$CPU_SLOW$eachslow$cpu
        fi
    $TOOLS/affinity_tools -part $cpu,$IMPLEMENTER,$PART_FAST >/dev/null
        if [ $? == 0 ] ; then
            eachfast=" -c "
            CPU_FAST=$CPU_FAST$eachfast$cpu
        fi
        cpu=$((cpu+1))
    done
    EACH_CPU="$CPU_SLOW$CPU_FAST"
}

function switch()
{
    if [ "$FREQ" -eq 0 ]; then
        boot_a15
    else if [ "$FREQ" -eq 1 ]; then
        boot_a7
    else
        echo "Error: Unknown Operating frequency. Has to be set to either \"big\" or \"little\""
        usage
    fi
    fi
}

function boot_a15()
{
    echo ""
    echo "Switching to big mode if not already in."
    ../../boot-a15.sh -c $CPU_NUM
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "boot-a15 failed. Abort!!"
        exit 1
    fi
}

function boot_a7()
{
    echo ""
    echo "Switching to little mode if not already in."
    echo " boot-a7.sh -c $CPU_NUM "
    ../../boot-a7.sh -c $CPU_NUM
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "boot-a7 failed. Abort!!"
        exit 1
    fi
}

function disable_cpu()
{
    echo ""
    echo "Taking CPU$DISABLE_CPU offline .."
    STATUS=$(cat /sys/devices/system/cpu/cpu$DISABLE_CPU/online)
    if [ $STATUS -eq 1 ]; then
        echo 0 > /sys/devices/system/cpu/cpu$DISABLE_CPU/online
    else
        echo "CPU$DISABLE_CPU already in offline mode."
    fi
}

function enable_cpu()
{
    echo ""
    echo "Bringing CPU$ENABLE_CPU online .."
    STATUS=$(cat /sys/devices/system/cpu/cpu$ENABLE_CPU/online)
    if [ $STATUS -eq 0 ]; then
        echo 1 > /sys/devices/system/cpu/cpu$ENABLE_CPU/online
    else
        echo "CPU$ENABLE_CPU already in online mode."
    fi
}

function run_cache_coherency()
{
    # Set defaults for stressapptest's cache coherency test
    if [ -z "$MEM" ]; then
        # MEM=16;
        MEM=1024;
    fi
    if [ -z "$SEC" ]; then
        SEC=10;
    fi
    echo ""
    echo "Running stressapptest -M $MEM --cc_test -s $SEC"
    CC_ERROR=$($TOOLS/stressapptest -M $MEM --cc_test -s $SEC | grep "miscompare")
    if  [ -n "$CC_ERROR" ]; then
        echo "CC_ERROR: $CC_ERROR"
        echo "cache-coherency test failed. Abort!!"
        CC_STATUS=1;
        return 1
    else
        echo "cache-coherency test finished successfully"
        return 0
    fi
}

function run_periodic_switcher()
{
    echo ""
    echo "Starting bigLITTLE periodic switcher in the background"
    if [ -z "$THREAD_CPU0" ]; then
        $TOOLS/bl-agitator -s $INTR &
        BL_AGITATOR_PID=$!
    else
        echo "spawning thread(s) on specified cpu(s)"
        echo "bl-agitator -n $EACH_CPU -s $INTR &"
        $TOOLS/bl-agitator -n $EACH_CPU -s $INTR &
        BL_AGITATOR_PID=$!
    fi
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "bigLITTLE periodic switcher failed. Abort!!"
        SWITCHER_STATUS=$ERR_CODE;
        return 1
    else
        return 0
    fi
}

function run_random_switcher()
{
    echo ""
    echo "Starting bigLITTLE random switcher in the background"
    if [ -z "$THREAD_CPU0" ]; then
        $TOOLS/bl-agitator -r $SEED -l $LIMIT &
        BL_AGITATOR_PID=$!
    else
        echo "spawning thread(s) on specified cpu(s)"
        echo "bl-agitator -n $EACH_CPU -r $SEED -l $LIMIT &"
        $TOOLS/bl-agitator -n $EACH_CPU -r $SEED -l $LIMIT &
        BL_AGITATOR_PID=$!
    fi
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "bigLITTLE random switcher failed. Abort!!"
        SWITCHER_STATUS=$ERR_CODE;
        return 1
    else
        return 0
    fi
}

function simultaneous_thread_switcher()
{
    echo ""
    echo "Starting bigLITTLE simultaneous thread switcher in the background"
    if [ -z "$THREAD_CPU0" ]; then
        $TOOLS/bl-agitator -s $INTR &
        BL_AGITATOR_PID=$!
    else
        echo "spawning thread(s) on specified cpu(s)"
        echo "bl-agitator -n $EACH_CPU -s $INTR -S &"
        $TOOLS/bl-agitator -n $EACH_CPU -s $INTR -S &
        BL_AGITATOR_PID=$!
    fi
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "bigLITTLE simultaneous thread switcher failed. Abort!!"
        SWITCHER_STATUS=$ERR_CODE;
        return 1
    else
        return 0
    fi
}

function kill_switcher()
{
        echo ""
        ANDROID_MOD_PATH=/system/lib/modules
        UBUNTU_MOD_PATH=/lib/modules
        if [ -d $ANDROID_MOD_PATH ]; then
            PID_BL_CHECK=`ps | grep "$BL_AGITATOR_PID" | grep "bl-agitator" | awk '{print $2}'`
        else if [ -d $UBUNTU_MOD_PATH ]; then
            PID_BL_CHECK=`ps ax | grep "$BL_AGITATOR_PID" | grep "bl-agitator" | awk '{print $1}'`
        else
           echo "ERROR: Unexpected Environment "
           exit 1
        fi
        fi
        echo "Kill bigLITTLE switcher BL_AGITATOR_PID $BL_AGITATOR_PID"
        echo "PID_BL_CHECK= $PID_BL_CHECK"

        if [ -z "$PID_BL_CHECK" ]; then
                echo "bigLITTLE switcher not running. Report Error!!"
                exit 1
        else
                # done with bl-agitator. Kill the process
                echo "sending SIGTERM BL_AGITATOR_PID $BL_AGITATOR_PID"
                kill $BL_AGITATOR_PID

                if [ -d $ANDROID_MOD_PATH ]; then
                    PID_BL_CHECK_AGAIN=`ps | grep "$BL_AGITATOR_PID" | grep "bl-agitator" | awk '{print $2}'`
                else if [ -d $UBUNTU_MOD_PATH ]; then
                    PID_BL_CHECK_AGAIN=`ps ax | grep "$BL_AGITATOR_PID" | grep "bl-agitator" | awk '{print $1}'`
                else
                    echo "ERROR: Unexpected Environment "
                    exit 1
                fi
                fi
                if [ -n "$PID_BL_CHECK_AGAIN" ]; then
                        #if the above kill is not successfull. kill forcefully
                        echo "sending SIGKILL BL_AGITATOR_PID $BL_AGITATOR_PID"
                        kill -9 $BL_AGITATOR_PID  > /dev/null  2>&1
        fi
        fi
}

if [ -z "$1" ]; then
        usage
fi

get_no_of_cpus

while [ "$1" ]; do
        case "$1" in
        -f|--frequency)
                if [ -z "$2" ]; then
                        echo "Error: Specify the operating frequency [big/little]"
                        usage
                fi
                if [ "$2" = "big" ]; then
                        FREQ=0;
                        shift;
                else if [ "$2" = "little" ]; then
                        FREQ=1;
                        shift;
                else
                        echo "Error: Operating frequency has to be set to either \"big\" or \"little\""
                        usage
                fi
                fi
                ;;
        -c|--cpu-num)
                if [ -z "$2" ]; then
                        echo "Error: Specify the CPU core (0-$large_cpu_number) to be switched to the desired frequency"
                        usage
                fi
                if [ $(echo "$2" | grep -E "^[0-$large_cpu_number]+$") ]; then
                        CPU_NUM=$2;
            if [ -z "$FREQ" ]; then
                                echo "Error: Specify the operating frequency [big/little]"
                                usage
                        fi
                        switch
                        shift;
                else
                        usage
                fi
                ;;
        -d|--disable-cpu)
                if [ $(echo "$2" | grep -E "^[1-3]+$") ]; then
                        DISABLE_CPU=$2;
            disable_cpu
                        shift;
                fi
                ;;
        -e|--enable-cpu)
                if [ $(echo "$2" | grep -E "^[1-3]+$") ]; then
                        ENABLE_CPU=$2;
            enable_cpu
                        shift;
                fi
                ;;
        -t|--seconds)
                if [ "$2" -gt 0 ]; then
                        SEC=$2;
                        shift;
                fi
                ;;
        -m|--memory)
                if [ "$2" -gt 0 ]; then
                        MEM=$2;
                        shift;
                fi
                ;;
        -s|--periodic-switching)
                if [ -z "$RANDOM_SWITCH" ]; then
                        PERIODIC_SWITCH=y;
                        if [ "$2" -gt 0 ]; then
                                INTR=$2;
                        else
                                INTR=50;
                        fi
                else
                        echo "Invalid option (-s) !!"
                        echo "Can't do random and periodic switchings simultaneously"
                        echo "Set to Random switching mode"
                fi
                shift;
                ;;
        -r|--random-switching)
                if [ -z "$PERIODIC_SWITCH" ]; then
                        RANDOM_SWITCH=y;
                        if [ "$2" -gt 0 ]; then
                                SEED=$2;
                        else
                                SEED=100;
                        fi
                else
                        echo "Invalid option (-r) !!"
                        echo "Can't do random and periodic switchings simultaneously"
                        echo "Set to Periodic switching mode"
                fi
                shift;
                ;;
        -l|--seed-limit)
                if [ -z "$PERIODIC_SWITCH" ]; then
                if [ -z "$SEED" ]; then
                                echo "Error: Specify the Seed for the random switcher [-r 100]"
                                usage
                        fi
                        if [ "$2" -gt 0 ]; then
                                LIMIT=$2;
                        else
                                LIMIT=1000;
                        fi
                else
                        echo "Invalid option (-l) !!"
                        echo "Can't do random and periodic switchings simultaneously"
                        echo "Set to Periodic switching mode"
                fi
                shift;
                ;;
        -n|--thread-switching)
                if [ $(echo "$2" | grep -E "^[0-$large_cpu_number]+$") ]; then
                        THREAD_CPU0=$2;
                        shift;
                else
                        echo "Error: Must specify at least one CPU on which thread has to be spawned"
                        usage
                fi
                shift;
                ;;
        -S|--simultaneous_thread_switching)
                if [ -z "$RANDOM_SWITCH" ]; then
                        SIMULTANEOUS_THREAD_SWITCH=y;
                else
                        echo "Invalid option (-S) !!"
                        echo "Can't do random and simultaneous thread switching at a time"
                        echo "Set to Random switching mode"
                fi
                ;;
        -h | --help | *)
                usage
                ;;
        esac
        shift;
done

if [ -z "$FREQ" ]; then
        echo "Error: Frequency has to be set to either \"big\" or \"little\""
        usage
else if [ -z "$CPU_NUM" ]; then
        echo "Error: Specify the number of CPU core (0-$large_cpu_number) to be switched to the desired frequency"
        usage
fi
fi

if  [ "$PERIODIC_SWITCH" = "y" ]; then
    if [ "$SIMULTANEOUS_THREAD_SWITCH" = "y" ]; then
        echo ""
    else
        run_periodic_switcher
    fi
fi

if  [ "$RANDOM_SWITCH" = "y" ]; then
        if [ -z "$LIMIT" ]; then
                echo "Error: Specify the Seed Limit for the random switcher [-l 1000]"
                usage
    fi
        run_random_switcher
fi

if  [ "$SIMULTANEOUS_THREAD_SWITCH" = "y" ]; then
        simultaneous_thread_switcher
    cluster-status.sh $BL_AGITATOR_PID &
fi

run_cache_coherency

# if  ([ "$PERIODIC_SWITCH" = "y" ] || [ "$RANDOM_SWITCH" = "y" ] || [ "$SIMULTANEOUS_THREAD_SWITCH" = "y" ]); then
        # kill_switcher
# fi

# if  ([ $CC_STATUS -ne 0 ] || [ $SWITCHER_STATUS -ne 0 ]); then
        # echo "Test failed. Abort!!"
        # exit 1
# fi

KERNEL_ERR=$(dmesg | grep "Unable to handle kernel ")
if [ -n "$KERNEL_ERR" ]; then
        echo "Kernel OOPS detected. Abort!!"
        exit 1
fi

exit 0
