#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"

__RET=""

function getkernelversion(){
    if [ -e /proc/version ];then
        version=$(cat /proc/version |$TOOLS/busybox awk {'print $3'}|$TOOLS/busybox cut -c0-3)
    else 
        version=$($TOOLS/busybox uname -r |$TOOLS/busybox cut -c0-3)
    fi
    __RET=$version
}
function run(){
    passcount=0
    getkernelversion
    version=$__RET  
    chk_ver=$($TOOLS/busybox awk 'BEGIN { print ('$version' >= 4.4) ? "YES" : "NO" }')
    if [ $chk_ver -eq "YES" ];then
        LISTOFTIMERS=("adjtick" "nanosleep" "set-timer-lat" "alarmtimer-suspend" "nsleep-lat" "change_skew" "posix_timers" "skew_consistency" "clocksource-switch" "raw_skew" "threadtest" "inconsistency-check" "valid-adjtimex" "set-2038" "leapcrash" "set-tz" "set-tai" "rtctest")
    else
        LISTOFTIMERS=("adjtick" "nanosleep" "set-timer-lat" "alarmtimer-suspend" "nsleep-lat" "change_skew" "posix_timers" "skew_consistency" "clocksource-switch" "raw_skew" "threadtest" "inconsistency-check" "valid-adjtimex" "set-2038" "leapcrash" "set-tai")
    fi
    for eachbin in ${LISTOFTIMERS[@]}
    do
        ./$eachbin
        if [ $? -eq 0 ];then
            passcount=$((passcount+1))
        else
            echo "Issues => $eachbin"
        fi
    done
    $TOOLS/leap-a-day -s -i 100 
    echo "${#LISTOFTIMERS[@]} $passcount"
    if [ ${#LISTOFTIMERS[@]} -eq $passcount ];then
        echo "Timer Test:PASS"
        exit 0
    else
        echo "Timer Test:Fail"
        exit 1
    fi
}

run
