#!/system/bin/bash
# source ../../../../init_env

function precheck(){
    #To-handle: can't create /sys/kernel/debug/tracing/tracing_max_latency: Permission denied
    if [ -e "/proc/config.gz" ]; then
        chk=$(busybox zcat /proc/config.gz |grep -c "CONFIG_PREEMPT_TRACER=y")
        if [ $chk -eq 0 ];then
            echo "IRQ PREEMPT is not enabled"
            exit 0
        fi
    fi
    framework "start"
}

function execute(){
    echo "0 0 0 0" > /proc/sys/kernel/printk
    echo 120000 > /d/tracing/buffer_size_kb
    echo 120000 > /d/tracing/buffer_size_kb
    cat /d/tracing/buffer_size_kb
    echo 0 > /sys/kernel/debug/tracing/tracing_on
    echo ''  > /d/tracing/set_event
    echo latency-format > /d/tracing/trace_options
    echo 0 > /d/tracing/options/function-trace
    echo preemptoff > /d/tracing/current_tracer
    sleep 5
    cat /d/tracing/current_tracer
    echo 1 > /sys/kernel/debug/tracing/tracing_on
    echo 0 > /sys/kernel/debug/tracing/tracing_max_latency
    /system/bin/monkey --ignore-crashes --ignore-timeouts --ignore-security-exceptions 5000
    echo 0 > /sys/kernel/debug/tracing/tracing_on
    sleep 2
    cat /d/tracing/trace > trace.txt
}

function check(){
    # Verify trace for any process blocking interrupts on any cpu for > 500 us is a failure
    startpattern=$(busybox grep "started at" trace.txt |busybox awk {'print $5'})
    endpattern=$(busybox grep "ended at" trace.txt |busybox awk {'print $5'})
    if [ "$startpattern" != "$endpattern" ];then
        starttime=$(busybox grep "<-$endpattern" trace.txt |busybox head -n 1|busybox awk {'print $3'}|busybox grep -o "[0-9]*")
    else
        starttime=$(busybox grep "<-$endpattern" trace.txt |busybox head -n 2|busybox tail -1|busybox awk {'print $3'}| busybox grep -o "[0-9]*")
    fi
    endtime=$(busybox grep "trace_hardirqs_on" trace.txt |busybox head -n 1|busybox awk {'print $3'}|busybox grep -o "[0-9]*")
    diff=$(($endtime-$starttime))
    framework "stop"
    if [ $diff -le 500 ];then
        echo "preemptoff: Success"
    else
        echo "preemptoff: Failure"
    fi
}
function framework(){
    cmd=$1
    if [ $cmd == "start" ]; then
        ps  | grep zygote
        if [ $? -eq 1 ]; then
            echo "Starting Android FW."
            start
            sleep 2
        else
            echo "Framework is running."
        fi
    else
        ps  | grep zygote
        if [ $? -eq 0 ]; then
            echo "Stopping Android FW."
            stop
            sleep 2
        else
            echo "Framework is not running."
        fi
    fi
}
precheck
execute
check
