#!/system/bin/bash
export TOOLS='/data/local/tmp/testrunner/common'
FTRACE_LOGS_PATH="/data/local/tmp/testrunner/suites/regression/testcases/core_ctl/logs"
CPUHOTPLUG_DIR="/sys/devices/system/cpu"
MAXCPU=$(cat /sys/devices/system/cpu/kernel_max)
# global return value
__RET=""
JSONFILE="test.json"

SUCCESS=0
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=`cat /sys/devices/soc0/soc_id`
else
    soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

#set the trace buffer size
function settrace()
{
    if [ -d $FTRACE_LOGS_PATH ] ; then
        rm -rf $FTRACE_LOGS_PATH
    fi
    mkdir $FTRACE_LOGS_PATH
    TARGET_BUFFER=20000
    target=$TARGET_BUFFER
    counter=0
    targetIncremetalBufSize=10000;
    actual=`cat /d/tracing/buffer_size_kb | busybox tr -d '[[:space:]]'`
    echo "Initial size: $actual"
    while [[ $actual -le $target ]]; do
        echo $targetIncremetalBufSize > /d/tracing/buffer_size_kb
        sleep 3
        actual=`cat /d/tracing/buffer_size_kb | busybox tr -d '[[:space:]]'`
        echo "Current size: $actual"
        targetIncremetalBufSize=$((targetIncremetalBufSize+10000))
        counter=$((counter+1))
        if [ $counter -gt 15 ] ; then
            echo $TARGET_BUFFER > /d/tracing/buffer_size_kb
            sleep 3
            actual=`cat /d/tracing/buffer_size_kb | busybox tr -d '[[:space:]]'`
            if [ $actual -lt $target ] ; then
                echo "unable set trace size"
                exit 1
            else
                break 2
            fi
        fi
    done
}

function getlittlecpulist(){
    for each in $(seq 0 $MAXCPU);do
        if [ -e $CPUHOTPLUG_DIR/cpu$each/core_ctl ]; then
            if [ `cat $CPUHOTPLUG_DIR/cpu$each/core_ctl/is_big_cluster` -eq 0 ]; then
                if [ -e $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list ];then
                    tmp=$(cat $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list|busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
                        NR > 1  { print "," }
                        NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
                        { print $1 }')
                    array=(${tmp//,/ })
                    arr=$(echo "${array[@]}" | busybox tr ' ' '\n' | busybox sort -u | busybox tr '\n' ' ')
                    littlecpulist=(${arr// / })
                    break
                fi
            fi
        fi
    done
    __RET=`echo ${littlecpulist[@]}`
}
function getbigcpulist(){
    for each in $(seq 0 $MAXCPU);do
        if [ -e $CPUHOTPLUG_DIR/cpu$each/core_ctl ]; then
            if [ `cat $CPUHOTPLUG_DIR/cpu$each/core_ctl/is_big_cluster` -eq 1 ]; then
                if [ -e $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list ];then
                    tmp=$(cat $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list|busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
                    NR > 1  { print "," }
                    NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
                    { print $1 }')
                    array=(${tmp//,/ })
                    arr=$(echo "${array[@]}" | busybox tr ' ' '\n' | busybox sort -u | busybox tr '\n' ' ')
                    bigcpulist=(${arr// / })
                    break
                fi
            elif [ `cat $CPUHOTPLUG_DIR/cpu$each/core_ctl/is_big_cluster` -eq 0 ]; then
                if [ -e $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list ];then
                    tmp=$(cat $CPUHOTPLUG_DIR/cpu$each/topology/core_siblings_list|busybox awk 'BEGIN { RS=","; FS="-"; ORS="" }
                    NR > 1  { print "," }
                    NF > 1  { for (i=$1; i<$2; ++i) { print i "," } print $2; next }
                    { print $1 }')
                    array=(${tmp//,/ })
                    arr=$(echo "${array[@]}" | busybox tr ' ' '\n' | busybox sort -u | busybox tr '\n' ' ')
                    littlecpulist=(${arr// / })
                    break
                fi
            fi
        fi
    done
    unset IFS
    val="${#bigcpulist[@]}"
    if [ $val -eq 0 ];then 
        bigcpulist=()
        for i in $(seq 0 $MAXCPU); do
            skip=
            for j in "${littlecpulist[@]}"; do
                [[ $i == $j ]] && { skip=1; break; }
                done
            [[ -n $skip ]] || bigcpulist+=("$i")
        done
    fi
    __RET=`echo ${bigcpulist[@]}`
}

#Start the trace buffer
function starttrace(){
    # echo 3 > /proc/sys/vm/drop_caches
    echo > /sys/kernel/debug/tracing/set_event
    echo "power:core_ctl_set_busy power:core_ctl_eval_need sched:*" > /sys/kernel/debug/tracing/set_event
    if [ $? -eq 1 ];then
        echo "sched:*" > /sys/kernel/debug/tracing/set_event
    fi
    > /sys/kernel/debug/tracing/trace
    echo 1 > /sys/kernel/debug/tracing/tracing_on
    echo "starting trace "
}

#stop trace buffer
function stoptrace()
{
  echo "Stopping trace"
  echo 0 > /sys/kernel/debug/tracing/tracing_on
  cat /sys/kernel/debug/tracing/trace > $FTRACE_LOGS_PATH/trace.txt
}

function TestCompareCore_ctlentrywithPostboot(){
    #'''
    ## Desc : Compare Core_ctl entry with Postboot scripts
    #'''
    if [ -e /etc/init.qcom.post_boot.sh ];then
        passcount=0
        if [ "$soc_id" -eq "294" ] || [ "$soc_id" -eq "295" ] || [ "$soc_id" -eq "313" ];then #msm8937
            fetchcontent=$($TOOLS/busybox awk '/"294" | "295" | "313" )"/{flag=1;next}/"# Set Memory parameters"/{flag=0}flag' /etc/init.qcom.post_boot.sh|grep -A15 "# Enable core control")
            export IFS=$'\n'
            for each_line in ${fetchcontent}
            do
                echo $each_line|grep "min_cpus" &> /dev/null
                if [ $? -eq 0 ];then
                    min_cpus=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "max_cpus" &> /dev/null
                if [ $? -eq 0 ];then
                    max_cpus=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "busy_up_thres" &> /dev/null
                if [ $? -eq 0 ];then
                    busy_up_thres=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "busy_down_thres" &> /dev/null
                if [ $? -eq 0 ];then
                    busy_down_thres=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "offline_delay_ms" &> /dev/null
                if [ $? -eq 0 ];then
                    offline_delay_ms=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "is_big_cluster" &> /dev/null
                if [ $? -eq 0 ];then
                    is_big_cluster=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
            done
            unset IFS
            getbigcpulist
            BIGCPUS=$__RET
            if [ -e  $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl ]; then
                cur_min_cpu=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/min_cpus)
                cur_max_cpu=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/max_cpus)
                cur_busy_up_thres=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/busy_up_thres|awk {'print $1'})
                cur_busy_down_thres=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/busy_down_thres|awk {'print $1'})
                cur_offline_delay_ms=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/offline_delay_ms)
                cur_is_big_cluster=$(cat $CPUHOTPLUG_DIR/cpu${BIGCPUS:0:1}/core_ctl/is_big_cluster)
                if [ $min_cpus -eq $cur_min_cpu ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$min_cpus $cur_min_cpu Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/min_cpus when compaired with post boot script"
                fi
                if [ $max_cpus -eq $cur_max_cpu ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$max_cpus $cur_max_cpu Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/max_cpus when compaired with post boot script"
                fi
                if [ $busy_up_thres -eq $cur_busy_up_thres ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$busy_up_thres $cur_busy_up_thres Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_up_thres when compaired with post boot script"
                fi
                if [ $busy_down_thres -eq $cur_busy_down_thres ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$busy_down_thres $cur_busy_down_thres Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_down_thres when compaired with post boot script"
                fi
                if [ $offline_delay_ms -eq $cur_offline_delay_ms ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$offline_delay_ms $cur_offline_delay_ms Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/offline_delay_ms when compaired with post boot script"
                fi
                if [ $is_big_cluster -eq $cur_is_big_cluster ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$is_big_cluster $cur_is_big_cluster Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/is_big_cluster when compaired with post boot script"
                fi
            else
                echo "Warning:sysfs node $CPUHOTPLUG_DIR/cpu0/core_ctl not found"
            fi
        fi
        if [ "$soc_id" -eq "278" ];then #msm8976
            # fetchcontent=$(awk '/#for 8976/{flag=1;next}/#re-enable thermal & BCL core_control now/{flag=0}flag' /etc/init.qcom.post_boot.sh |grep -A15 "# Enable core control")
            fetchcontent=$(grep -A200 "# SoC IDs are 266, 274, 277, 278" /etc/init.qcom.post_boot.sh|grep -A15 "#for 8976")
            export IFS=$'\n'
            for each_line in ${fetchcontent}
            do
                echo $each_line|grep "min_cpus" &> /dev/null
                if [ $? -eq 0 ];then
                    min_cpus=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "max_cpus" &> /dev/null
                if [ $? -eq 0 ];then
                    max_cpus=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "busy_up_thres" &> /dev/null
                if [ $? -eq 0 ];then
                    busy_up_thres=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "busy_down_thres" &> /dev/null
                if [ $? -eq 0 ];then
                    busy_down_thres=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "offline_delay_ms" &> /dev/null
                if [ $? -eq 0 ];then
                    offline_delay_ms=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
                echo $each_line|grep "is_big_cluster" &> /dev/null
                if [ $? -eq 0 ];then
                    is_big_cluster=$(echo $each_line|$TOOLS/busybox awk {'print $2'})
                fi
            done
            unset IFS
            getlittlecpulist
            LITTLECPUS=$__RET
            if [ -e  $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl ]; then
                cur_min_cpu=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/min_cpus)
                cur_max_cpu=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/max_cpus)
                cur_busy_up_thres=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/busy_up_thres|$TOOLS/busybox awk {'print $1'})
                cur_busy_down_thres=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/busy_down_thres|$TOOLS/busybox awk {'print $1'})
                cur_offline_delay_ms=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/offline_delay_ms)
                cur_is_big_cluster=$(cat $CPUHOTPLUG_DIR/cpu${LITTLECPUS:0:1}/core_ctl/is_big_cluster)
                if [ $min_cpus -eq $cur_min_cpu ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$min_cpus $cur_min_cpu Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/min_cpus when compaired with post boot script"
                fi
                if [ $max_cpus -eq $cur_max_cpu ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$max_cpus $cur_max_cpu Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/max_cpus when compaired with post boot script"
                fi
                if [ $busy_up_thres -eq $cur_busy_up_thres ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$busy_up_thres $cur_busy_up_thres Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_up_thres when compaired with post boot script"
                fi
                if [ $busy_down_thres -eq $cur_busy_down_thres ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$busy_down_thres $cur_busy_down_thres Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_down_thres when compaired with post boot script"
                fi
                if [ $offline_delay_ms -eq $cur_offline_delay_ms ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$offline_delay_ms $cur_offline_delay_ms Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/offline_delay_ms when compaired with post boot script"
                fi
                if [ $is_big_cluster -eq $cur_is_big_cluster ]; then
                    passcount=$((passcount + 1))
                else
                    echo "$is_big_cluster $cur_is_big_cluster Miss match value for node $CPUHOTPLUG_DIR/cpu0/core_ctl/is_big_cluster when compaired with post boot script"
                fi
            else
                echo "Warning:sysfs node $CPUHOTPLUG_DIR/cpu0/core_ctl not found"
            fi
        fi
        if [ $passcount -eq 6 ];then
            SUCCESS=$((SUCCESS + 1))
            echo "TestCompareCore_ctlentrywithPostboot:Pass"
        else
            echo "TestCompareCore_ctlentrywithPostboot:Fail"
        fi
    else
        echo "Warning:/etc/init.qcom.post_boot.sh file not found"
    fi
}

function Test_sysfs_core_ctl(){
    # '''
        # Desc : sysfs node check for Core_ctl
    # '''
    passcount=0
    if [ -e /system/lib/modules/core_ctl.ko ];then
        LISTOFNODE=("busy_down_thres" "max_cpus" "not_preferred" "task_thres" "busy_up_thres" "global_state" "min_cpus" "offline_delay_ms" "cpus" "is_big_cluster" "need_cpus" "online_cpus")
    else 
        LISTOFNODE=("busy_down_thres" "disable" "max_cpus" "not_preferred" "task_thres" "busy_up_thres" "global_state" "min_cpus" "offline_delay_ms" "cpus" "is_big_cluster" "need_cpus" "online_cpus")
    fi
    if [ -e  $CPUHOTPLUG_DIR/cpu0/core_ctl ]; then
        res=()
        for reqnode in "${LISTOFNODE[@]}"
        do
            skip=
            for eachnode in "$CPUHOTPLUG_DIR/cpu0/core_ctl"/*
            do
                name=$(basename "$eachnode")
                [[ "$name" == "$reqnode" ]] && { skip=1; break; }
            done
            [[ -n $skip ]] || res+=("$reqnode")
        done
        val="${#res[@]}"
        if [ $val -eq 0 ];then 
            passcount=$((passcount + 1))
        else
            echo "Fail: Some of the Nodes are missing ${res[@]}"
        fi
    else 
        echo "sysfs node $CPUHOTPLUG_DIR/cpu0/core_ctl not found"
    fi
    if [ -e  $CPUHOTPLUG_DIR/cpu4/core_ctl ]; then
        res=()
        for reqnode in "${LISTOFNODES[@]}"
        do
            skip=
            for eachnode in "$CPUHOTPLUG_DIR/cpu4/core_ctl"/*
            do
                name=$(basename "$eachnode")
                [[ "$name" == "$reqnode" ]] && { skip=1; break; }
            done
            [[ -n $skip ]] || res+=("$reqnode")
        done
        val="${#res[@]}"
        if [ $val -eq 0 ];then 
            passcount=$((passcount + 1))
        else
            echo "Fail: Some of the Nodes are missing ${res[@]}"
        fi
        sysfsnode_cpus=$(cat $CPUHOTPLUG_DIR/cpu4/core_ctl/cpus|grep -c Online)
        sysfsnode_onlinecpus=$(cat $CPUHOTPLUG_DIR/cpu4/core_ctl/online_cpus)
        sysfsnode_mincpus=$(cat $CPUHOTPLUG_DIR/cpu4/core_ctl/min_cpus)
        sysfsnode_isbigcluster=$(cat $CPUHOTPLUG_DIR/cpu4/core_ctl/is_big_cluster)
        if [ $sysfsnode_isbigcluster -eq 1 ];then
            if [ $sysfsnode_cpus -eq $sysfsnode_onlinecpus ] && [ $sysfsnode_cpus -eq $sysfsnode_mincpus ];then
                passcount=$((passcount + 1))
            fi
        else
            if [ $sysfsnode_cpus -eq $sysfsnode_onlinecpus ]; then
                passcount=$((passcount + 1))
            fi
        fi
    else 
        echo "sysfs node $CPUHOTPLUG_DIR/cpu4/core_ctl not found"
    fi
    if [ "$passcount" -eq "3" ];then
        SUCCESS=$((SUCCESS + 1))
        echo "TestSysfsNodeCore_ctl:Pass"
    else
        echo "TestSysfsNodeCore_ctl:Fail"
    fi
}

function Test_cluster_migration(){
    #'''
    #    Desc:Increase Load from 10% to 100% using rt-app for cluster migration  
    #'''
    settrace
    starttrace
    if [ -e $JSONFILE ];then
        rm -rf $JSONFILE
    fi
    cat <<EOF > $JSONFILE
{
	"tasks" : {
		"CPULOAD" : {
			"loop" : 1,
			"instance" : 3,
			"phases" : {
				"C0" : {
					"loop" : 100,
					"exec_time" : 2000,
					"sleep" : 18000,
				},
				"C1" : {
					"loop" : 100,
					"exec_time" : 20000,
				},
			},
		},
	},
	"global" : {
		"duration" : 6,
		"calibration" : 720,
		"default_policy" : "SCHED_OTHER",
		"pi_enabled" : false,
		"lock_pages" : false,
		"logdir" : "$FTRACE_LOGS_PATH",
		"log_basename" : "rt-app2",
		"ftrace" : false,
		"gnuplot" : false
	}
}
EOF
    $TOOLS/rt-app $JSONFILE > /dev/null 2>&1
    stoptrace
    search_res=$(grep "core_ctl_eval_need" $FTRACE_LOGS_PATH/trace.txt |grep "updated=1")
    IFS='
'
    for line in $search_res
    do
        # echo "search_result => $line"
        oldneed=$(echo $line |$TOOLS/busybox awk {'print $7,$8'}|$TOOLS/busybox awk -F '[ =]' '{print $2}'| $TOOLS/busybox sed 's/,//g')
        newneed=$(echo $line |$TOOLS/busybox awk {'print $7,$8'}|$TOOLS/busybox awk -F '[ =]' '{print $4}'|$TOOLS/busybox sed 's/,//g')
        # echo "oldneed=>$oldneed,newneed =>$newneed"
        if [[ $newneed -gt $oldneed ]];then
            echo "Test(cluster_migration):Pass"
            SUCCESS=$((SUCCESS + 1))
            break
        else 
            echo "Test(cluster_migration):Fail"
        fi
    done
    unset IFS
}
function Test_bigcore_without_hotplug()
{
    #'''
    #   Desc:Increasing Load from 10 % to 100% with 1 thread using RT-app for use existing big core without hotplug new cores
    #'''
    settrace
    starttrace
	if [ -e 00.json ];then
        rm -rf 00.json
    fi
    cat <<EOF > 00.json
{
	"tasks" : {
		"CPULOAD" : {
			"loop" : 1,
			"instance" : 1,
			"phases" : {
				"C0" : {
					"loop" : 100,
					"exec_time" : 2000,
					"sleep" : 18000,
				},
				"C1" : {
					"loop" : 100,
					"exec_time" : 20000,
				},
			},
		},
	},
	"global" : {
		"duration" : 6,
		"calibration" : 720,
		"default_policy" : "SCHED_OTHER",
		"pi_enabled" : false,
		"lock_pages" : false,
		"logdir" : "$FTRACE_LOGS_PATH",
		"log_basename" : "rt-app2",
		"ftrace" : false,
		"gnuplot" : false
	}
}
EOF
    $TOOLS/rt-app $JSONFILE > /dev/null 2>&1
    stoptrace
    search_res=$(grep "core_ctl_eval_need" $FTRACE_LOGS_PATH/trace.txt |grep "updated=0")
    IFS='
'
    for line in $search_res
    do
        # echo "search_result => $line"
        old_need=$(echo $line |$TOOLS/busybox awk {'print $7,$8'}|$TOOLS/busybox awk -F '[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
        new_need=$(echo $line |$TOOLS/busybox awk {'print $7,$8'}|$TOOLS/busybox awk -F '[ =]' '{print $4}'|$TOOLS/busybox sed 's/,//g')
        # echo "oldneed=>$old_need,newneed =>$new_need"
        if [[ $new_need -gt $old_need ]];then
            echo "Test(No_migration):Pass"
            SUCCESS=$((SUCCESS + 1))
            break
        else 
            echo "Test(No_migration):Fail"
        fi
    done
    unset IFS
}
function Test_offline_delay_ms()
{
    #'''
    #   Decreasing load from 100% to 10% with 3 threads using rt-app to chk offline_delay_ms of core_ctl
    #'''
    # events="sched:sched_switch sched:sched_wakeup sched:sched_wakeup_new sched:sched_enq_deq_task sched:sched_get_nr_running_avg sched:core_ctl_eval_need"
    # events="sched:core_ctl_set_busy sched:core_ctl_eval_need"
    settrace
    starttrace
    if [ -e $JSONFILE ];then
        rm -rf $JSONFILE
    fi
    cat <<EOF > $JSONFILE
{
	"tasks" : {
		"CPULOAD" : {
			"loop" : 1,
			"instance" : 3,
			"phases" : {
				"C0" : {
					"loop" : 100,
					"exec_time" : 20000,
				},
				"C1" : {
					"loop" : 100,
					"exec_time" : 2000,
					"sleep" : 18000,
				},
			},
		},
	},
	"global" : {
		"duration" : 6,
		"calibration" : 720,
		"default_policy" : "SCHED_OTHER",
		"pi_enabled" : false,
		"lock_pages" : false,
		"logdir" : "$FTRACE_LOGS_PATH",
		"log_basename" : "rt-app2",
		"ftrace" : false,
		"gnuplot" : false
	}
}
EOF
    $TOOLS/rt-app $JSONFILE > /dev/null 2>&1
    stoptrace
    oldneed=0
    newneed=0
    endtime=0
    starttime=0
    getbigcpulist
    BIGCPUS=$__RET
    echo "first core of big cluster => ${BIGCPUS:0:1}"
    search_res=$(grep "core_ctl_eval_need" $FTRACE_LOGS_PATH/trace.txt |grep "cpu=${BIGCPUS:0:1}"|$TOOLS/busybox awk {'print $4,$6,$7,$8'})
    reqtimechk1=1
    IFS='
'
    for line in $search_res
    do
        old_need=$(echo $line|$TOOLS/busybox awk {'print $3'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
        new_need=$(echo $line|$TOOLS/busybox awk {'print $4'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
        if [[ $old_need -gt  $new_need ]];then
            endtime=$(echo $line|$TOOLS/busybox awk {'print $1'}|$TOOLS/busybox sed 's/://g')
            [ $reqtimechk1 -eq 0 ] && continue
            starttime=$(echo $line|$TOOLS/busybox awk {'print $1'}|$TOOLS/busybox sed 's/://g')
            reqtimechk1=0
        fi
    done
    unset IFS 
    tmp=$(echo | $TOOLS/busybox awk "{print $endtime*1000 - $starttime*1000}")
    res=$(printf "%.0f" $tmp)
    echo "res => $res"
    if [ "$res" -ge `cat /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms` ];then
        echo "Test(offline_delay_ms):Pass"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "Test(offline_delay_ms):Fail"
    fi
}

function Test_busy_updown_thres()
{
    passcount=0
    settrace
    starttrace
    if [ -e $JSONFILE ];then
        rm -rf $JSONFILE
    fi
    cat <<EOF > $JSONFILE
{
	"tasks" : {
		"CPULOAD" : {
			"loop" : 1,
			"instance" : 3,
			"phases" : {
				"C0" : {
					"loop" : 100,
					"exec_time" : 20000,
				},
				"C1" : {
					"loop" : 100,
					"exec_time" : 2000,
					"sleep" : 18000,
				},
				},
				"C2" : {
					"loop" : 100,
					"exec_time" : 5000,
					"sleep" : 15000,
				},
			},
		},
	},
	"global" : {
		"duration" : 6,
		"calibration" : 720,
		"default_policy" : "SCHED_OTHER",
		"pi_enabled" : false,
		"lock_pages" : false,
		"logdir" : "$FTRACE_LOGS_PATH",
		"log_basename" : "rt-app2",
		"ftrace" : false,
		"gnuplot" : false
	}
}
EOF
    $TOOLS/rt-app $JSONFILE > /dev/null 2>&1
    stoptrace
    sysfsnode_busyupthres=$(cat $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_up_thres)
    upthres=( $sysfsnode_busyupthres )
    req_upthres=${upthres[0]}
    sysfsnode_busydownthres=$(cat $CPUHOTPLUG_DIR/cpu0/core_ctl/busy_down_thres)
    downthres=( $sysfsnode_busydownthres )
    req_downthres=${downthres[0]}
    getbigcpulist
    BIGCPUS=$__RET
    for each_big in ${BIGCPUS}
    do
        search_res=$(grep "core_ctl_set_busy" $FTRACE_LOGS_PATH/trace.txt|grep "cpu=$each_big"|$TOOLS/busybox awk {'print $4,$7,$8,$9'})
        IFS='
'
        for line in $search_res
        do
            old_is_busy=$(echo $line|$TOOLS/busybox awk {'print $3'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
            new_is_busy=$(echo $line|$TOOLS/busybox awk {'print $4'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
            if [[ $new_is_busy -gt  $old_is_busy ]];then
                busy=$(echo $line|$TOOLS/busybox awk {'print $2'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
                if [[ $busy -ge $req_upthres ]];then
                    passcount=$((passcount + 1))
                    # echo "upthres=> $line"
                fi
            fi
            if [[ $new_is_busy -lt  $old_is_busy ]];then
                busy=$(echo $line|$TOOLS/busybox awk {'print $2'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
                if [[ $busy -le $req_downthres ]];then
                    passcount=$((passcount + 1))
                    # echo "downthres => $line"
                fi
            fi
        done
        unset IFS
        if [ "$passcount" -ge 2 ];then
            break
        fi
    done
    if [ "$passcount" -ge 2 ];then
        echo "Test(busy up/down thres):Pass"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "Test(busy up/down thres):Fail"
    fi
}
function Test_task_thres(){
    passcount=0
    # events="sched:sched_switch sched:sched_wakeup sched:sched_wakeup_new sched:sched_enq_deq_task sched:sched_get_nr_running_avg timer:* sched:core_ctl_set_busy sched:core_ctl_eval_need"
    if [ -e $CPUHOTPLUG_DIR/cpu0/core_ctl ]; then
        save_task_thres=$(cat $CPUHOTPLUG_DIR/cpu0/core_ctl/task_thres)
        cur_task_thres=$(cat $CPUHOTPLUG_DIR/cpu0/core_ctl/task_thres)
        hex_cur_task_thres=$(printf "%x\n" $cur_task_thres)
        if [ $hex_cur_task_thres -eq "ffffffff" ];then
            passcount=$((passcount + 1))
        fi
        for retry in $(seq 4)
        do
            echo 4 > $CPUHOTPLUG_DIR/cpu0/core_ctl/task_thres
            if [ $? -eq 0 ];then
                break
            fi
        done
        settrace
        starttrace
        if [ -e $JSONFILE ];then
            rm -rf $JSONFILE
        fi
        cat <<EOF > $JSONFILE
{
	"tasks" : {
		"CPULOAD" : {
			"loop" : 1,
			"instance" : 5,
			"phases" : {
				"C0" : {
					"loop" : 100,
					"exec_time" : 20000,
				},
			},
		},
	},
	"global" : {
		"duration" : 6,
		"calibration" : 720,
		"default_policy" : "SCHED_OTHER",
		"pi_enabled" : false,
		"lock_pages" : false,
		"logdir" : "$FTRACE_LOGS_PATH",
		"log_basename" : "rt-app2",
		"ftrace" : false,
		"gnuplot" : false
	}
}
EOF
        $TOOLS/rt-app $JSONFILE > /dev/null 2>&1
        stoptrace
        getbigcpulist
        BIGCPUS=$__RET
        search_res=$(grep "core_ctl_eval_need" $FTRACE_LOGS_PATH/trace.txt|grep "cpu=$each_big"|$TOOLS/busybox awk {'print $4,$7,$8,$9'})
        IFS='
'
        for line in $search_res
        do
            old_need=$(echo $line|$TOOLS/busybox awk {'print $2'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
            new_need=$(echo $line|$TOOLS/busybox awk {'print $3'}|$TOOLS/busybox awk -F'[ =]' '{print $2}'|$TOOLS/busybox sed 's/,//g')
            req_need=$((new_need - old_need))
            if [[ $req_need -ge 2 ]] && [[ $new_need -eq 4 ]];then
                echo $line|grep "updated=1" > /dev/null
                if [ $? -eq 0 ];then
                    passcount=$((passcount + 1))
                    # echo "line => $line"
                    break
                fi
            fi
        done
        unset IFS
        #restore
        echo $save_task_thres > $CPUHOTPLUG_DIR/cpu0/core_ctl/task_thres
    fi
    if [ "$passcount" -ge 2 ];then
        echo "Test(task_thres):Pass"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "Test(task_thres):Fail"
    fi
}
function cleanup()
{
  rm -rf *.json *.log
}
TestCompareCore_ctlentrywithPostboot
Test_sysfs_core_ctl
Test_cluster_migration
Test_bigcore_without_hotplug
# Test_offline_delay_ms
Test_busy_updown_thres
# Test_task_thres
if [ "$SUCCESS" == "5" ] ; then
    echo SUCCESS
    cleanup
    exit 0
else
    echo FAILED
    cleanup
    exit 1
fi

