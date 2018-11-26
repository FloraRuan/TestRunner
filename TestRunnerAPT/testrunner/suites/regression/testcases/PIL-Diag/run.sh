#!/system/bin/bash
source ../../../../init_env

subsysdir="/sys/bus/msm_subsys/devices"

count=0
dmesg -c > /dev/null

# global return value
__RET=1

# subsys_count=$(ls /sys/bus/msm_subsys/devices/|grep -c "subsys*")
function presetup(){
    ssr=$1
    for subsys in $subsysdir/*
    do
        req_ssr=$(cat $subsys/name)
        if [ "$req_ssr" == "$ssr" ]; then 
            echo "RELATED" > $subsys/restart_level
            __RET=0
            break
        fi
    done
}

function subsysrestart_modem(){
    __RET=1
    presetup "modem"
    res=$__RET
    if [ $res -eq 0 ];then
        $TOOLS/diag_callback_client --mf
        sleep 5
        $TOOLS/diag_callback_client --mn
        sleep 5
        $TOOLS/diag_callback_client --mw
        sleep 5
    else
        echo "Precondition failure:unable to set RELATED in restart_level for modem"
    fi
}

function subsysrestart_adsp(){
    __RET=1
    presetup "adsp"
    res=$__RET
    if [ $res -eq 0 ];then
        $TOOLS/diag_callback_client --af
        sleep 5
        $TOOLS/diag_callback_client --an
        sleep 5
        $TOOLS/diag_callback_client --aw
        sleep 5
    else
        echo "Precondition failure:unable to set RELATED in restart_level for adsp"
    fi
}

function subsysrestart_wcnss(){
    __RET=1
    presetup "wcnss"
    res=$__RET
    if [ $res -eq 0 ];then
        $TOOLS/diag_callback_client --pf
        sleep 5
        $TOOLS/diag_callback_client --pn
        sleep 5
        $TOOLS/diag_callback_client --pw
        sleep 5
    else
        echo "Precondition failure:unable to set RELATED in restart_level for wcnss"
    fi
}

function subsysrestart_venus(){ 
    __RET=1
    presetup "venus"
    res=$__RET
    if [ $res -eq 0 ];then
        $TOOLS/diag_callback_client --vf
        sleep 5
        $TOOLS/diag_callback_client --vw
        sleep 5
    else
        echo "Precondition failure:unable to set RELATED in restart_level for venus"
    fi
}

function check(){
    restartcount=0
    #ignore:Venus as we need to play the video for restartcount increment
    for each in adsp modem wcnss
    do
        restartcount=$(dmesg | grep -c "$each: Brought out of reset")
        if [ $restartcount -ge 3 ];then
            echo "PIL load/Unload:Success for $each"
            count=$((count + 1))
        else
            echo "PIL load/Unload:Failure for $each"
        fi
    done
}

subsysrestart_adsp
subsysrestart_modem
subsysrestart_wcnss
subsysrestart_venus
check
if [ $count -eq 3 ]; then 
    echo "PIL-diag: Success"
    exit 0
else
    echo "PIL-diag: Failure"
    exit 1
fi