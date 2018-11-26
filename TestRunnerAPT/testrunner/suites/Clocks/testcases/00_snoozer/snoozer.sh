# ***********************************************************************************************************************
# **           Confidential and Proprietary – Qualcomm Technologies, Inc.
# **
# **           This technical data may be subject to U.S. and international export, re-export, or transfer
# **           ("export") laws. Diversion contrary to U.S. and international law is strictly prohibited.
# **
# **           Restricted Distribution: Not to be distributed to anyone who is not an employee of either
# **           Qualcomm or its subsidiaries without the express approval of Qualcomm’s Configuration
# **           Management.
# **
# **           © 2013 Qualcomm Technologies, Inc
# ************************************************************************************************************************

LOGFILE="snoozer_log.txt"
echo "Removing old logs"
rm $LOGFILE

echo_to_log()
{
	msg="$1\n"
	echo "$msg"
	echo "$msg" >> $LOGFILE
}

########################################################################################
# Display header
########################################################################################
echo_to_log "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
echo_to_log "                               SNOOZER                                           "
echo_to_log "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
echo_to_log $0 $*

########################################################################################
# Parsing arguments
########################################################################################

total_time=10
num_threads=1
busy=0
cpu=0
gdsc=0
rand=0
timer=0
LOW=10
HIGH=100000
SEED=$$
combo=0
retention_low=0
retention_high=0
retention_freq=0

#For CPU test, search this array of possible PM stats paths and pick
#path that exists on target

pm_stats_path=(
    '/proc/msm_pm_stats'
    '/sys/kernel/debug/lpm_stats/stats'
)

#For GDSC test, search debugfs regulator directory
#and pick node that exists on target

gdsc_all_nodes=(`ls /d/regulator | grep gdsc`)
find_gdsc_node()
{
	g=0
	while [ "$g" -lt "${#gdsc_all_nodes[@]}" ]
	do
		gnode=${gdsc_all_nodes[g]}
		case $gnode in
			$1)
				gdsc_test_nodes=("${gdsc_test_nodes[@]}" "/d/regulator/$gnode/enable")
				echo_to_log "Using GDSC node: $gnode"
				;;
		esac
	((g++))
	done
}

#Change random timers at 10% of total_time intervals.
#eg: for 10s total time, change timers every 1s
RANDITER=10

print_help()
{
	echo_to_log "
	Usage: ./snoozer.sh [OPTION]...
	Snoozer suite for CPU and MM core LPMs

	Nominal CPU test arguments
	-c							Run CPU LPM test
	-h							Print this help message and exit
	-n=							Number of interference timers
	-t=							Test duration in s (10s by default)
	[<cpu(0-7)>,<time in us>]		Specify as many cpu-timer mappings as n.
	"
	echo_to_log "
	GDSC stress test arguments
	-t=							Test duration in s (10s by default)
	-gc							Run Graphics CX GDSC test
	-gx							Run Graphics GX GDSC test
	-m							Run MDP GDSC test
	-v 							Run Venus GDSC test
	-v0							Run Venus Core0 GDSC test
	-v1							Run Venus Core1 GDSC test
	-v2							Run Venus Core2 GDSC test
	"
	echo_to_log "
	Random test arguments
	-r 							Run test with random parameters
	-b                          Run cacheblast test with shuffle
	-s=							Set seed for random sequence. Same seed can be used
								to replay sequence.
	-l=							Lower limit of random timers in us
								(10us by default)
	-h=							Higher limit of random timers in us
								(100000us by default)
	[<cpu(0-7)>,0,<m/s>]			0 will be replaced by random timer
	"
}

for i in "$@"
do
case $i in

	#Common
	-t=*)
		total_time="${i#*=}"
		shift
		;;
	-l=*)
		LOW="${i#*=}"
		shift
		;;
	-h=*)
		HIGH="${i#*=}"
		shift
		;;
	#CPU LPM
	-c)
		cpu=1
		files=("${files[@]}" "cpu_lpm")
		((cpu_arg++))
		shift
		;;
    -r)
		rand=1
		shift
		;;
	-b)
		busy=1
		files=("${files[@]}" "$TOOLS/cacheblast")
		files=("${files[@]}" "$TOOLS/shuffle")
		files=("${files[@]}" "$TOOLS/timerun")
		files=("${files[@]}" "cpu_lpm_cacheblast.sh")
		shift
		;;
	-rl=*)
		retention_low="${i#*=}"
		shift
		;;
	-rh=*)
		retention_high="${i#*=}"
		shift
		;;
	-rf=*)
		retention_freq="${i#*=}"
		shift
		;;
	-s=*)
		SEED="${i#*=}"
		shift
		;;
	-n=*)
		num_threads="${i#*=}"
		((cpu_arg++))
		shift
		;;
	\[*,*])
		timer_params=("${timer_params[@]}" $i)
		((cpu_arg++))
		shift
		;;
	#Venus GDSC
	-v)
		find_gdsc_node "*gdsc*venus"
		shift
		;;
	-v0)
		find_gdsc_node "gdsc*venus*core*0"
		shift
		;;
	-v1)
		find_gdsc_node "gdsc*venus*core*1"
		shift
		;;
	-v2)
		find_gdsc_node "gdsc*venus*core*2"
		shift
		;;
	#Graphics GDSC
	-gc)
		find_gdsc_node "gdsc*oxili*cx"
		shift
		;;
	-gg)
		find_gdsc_node "gdsc*oxili*gx"
		shift
		;;
	#MDP GDSC
	-m)
		find_gdsc_node "gdsc*mdss"
		shift
		;;
	-h)
		print_help
		exit 0
		shift
		;;
	*)
           # unknown option
    ;;
esac
done

########################################################################################
# Initial checks
########################################################################################

if [ $cpu -eq 1 ] && [ $cpu_arg -lt 3 ];
then
	echo_to_log "Number of timers (n) and params for each timer are mandatory for CPU LPM test. Exiting!\n"
	print_help
	exit 1
fi

if [ "${#gdsc_test_nodes[@]}" -gt "0" ]
then
	gdsc=1
	files=("${files[@]}" "$TOOLS/filemonkey")
	for node in "${gdsc_test_nodes[@]}"
	do
		files=("${files[@]}" "$node")
	done
fi


if [ $cpu -ne 1  ] && [ $gdsc -ne 1 ] ;
then
	echo_to_log "Please choose either CPU LPM test or GDSC test. Exiting!\n"
	print_help
	exit 1
fi

if [ $cpu -eq 1 ] && [ $gdsc -eq 1 ] ;
then
	echo_to_log "WARNING: CPU LPMs cannot be guaranteed if GDSC tests are run in parallel"
	combo=1
fi

file_exists()
{
	if [ ! -f "$1" ];
	then
		echo_to_log "$1 not found. Exiting!\n"
		exit 1
	fi
}

echo_to_log "Checking if required files are present\n"
while [ "$f" -lt "${#files[@]}" ]
do
	file_exists ${files[f]}
	chmod 777 ${files[f]}
	((f++))
done

if [ $cpu -eq 1 ]
then
	echo_to_log "Checking if PM STATS node exists\n"
	while [ "$pnode" -lt "${#pm_stats_path[@]}" ]
	do
		if [ -f ${pm_stats_path[pnode]} ];
		then
			PM_STATS=${pm_stats_path[pnode]}
			echo_to_log "PM STATS node is $PM_STATS\n"
			break
		fi
		((pnode++))
	done

	if [ ! "$PM_STATS" ];
	then
		echo_to_log "PM STATS node not present. Exiting!\n"
		exit 1;
	fi
fi

echo_to_log "Sleep for 30s while USB is disconnected"
sleep 30

IRQ_SNAPSHOT=()
grab_irq()
{
	IRQ_SNAPSHOT=`cat /proc/interrupts | grep 20:`
	IRQ_SNAPSHOT=(${IRQ_SNAPSHOT// / })
}

process_irq()
{
	echo "Number of ARCH_TIMER interrupts received:" >> $LOGFILE
	i=0
	while [ $i -lt ${#pre_irq[@]} ]
	do
		if [ "${pre_irq[$i]}" != "20:" ] && [ "${pre_irq[$i]}" != "GIC" ] && [ "${pre_irq[$i]}" != "arch_timer" ];
		then
			echo "cpu$((i-1))=$((${post_irq[$i]}-${pre_irq[$i]}))" >> $LOGFILE
		fi
		((i++))
	done
}

########################################################################################
# Launch tests
########################################################################################

run_test()
{
	#Launch filemonkey in the background, so they can run concurrently
	if [[ $1 == *filemonkey* ]]
	then
		cmd="$1 &"
	else
		cmd=$1
	fi

	echo_to_log "Starting Test: $cmd"

	# Capture number of arch_timer interrupts received per cpu while the test ran
	grab_irq; pre_irq=("${IRQ_SNAPSHOT[@]}")

	# Test invocation
	eval $cmd > out.txt
	cat out.txt >> $LOGFILE

	grab_irq; post_irq=("${IRQ_SNAPSHOT[@]}"); process_irq

	echo_to_log	"\n##############################################################################"
	rm out.txt

}

toggle()
{
	enable=$(<"$1")
	if [ $enable -eq 1 ] ;
	then
		val=0
	else
		val=1
	fi

	echo_to_log "writing $val to $1"
	echo $val | dd of=$1 2> /dev/null
	sleep 5
	enable=$(<"$1")

	if [ $val != $enable ] ;
	then
		echo_to_log "Unable to echo $val to $1. Exiting!"
		exit 1
	fi
}

if [ $gdsc -eq 1 ];
then
	echo_to_log "GDSC STRESS TEST"
	echo_to_log "Stopping Adroid services"
	stop
	sync
	sleep 1

	for node in "${gdsc_test_nodes[@]}"
	do

		val=$(<"$node")
		timeout=0

		echo_to_log "PRECHECK"
		# Sleep 6s waiting for node to read 0. Time out after 10 attempts.
		while [ $val -eq 1 ]
		do
			if [ $timeout -eq 9 ];
			then
				echo_to_log "GDSC not enabled for $node. Trying to enable"
				toggle "$node"
			fi
			if [ $timeout -eq 10 ];
			then
				echo_to_log "Timeout. Cannot start stress test. Exiting!"
				exit 1
			fi

			sleep 6
			val=$(<"$node")
			((timeout++))

		done
		# 0 -> 1
		toggle "$node"
		# 1 -> 0
		toggle "$node"

		#Start stress test
		run_test "$TOOLS/filemonkey $node s $LOW $HIGH 1 0 "
		if [ $combo -ne 1 ];
		then
			sleep $total_time
		fi
	done
fi
retention ()
{
	index=$1
	timer=$2

	cpu_path='/sys/devices/system/cpu/'
	freq_path='cpufreq/scaling_min_freq'

	if [ "$timer" -ge "$retention_low" ] && [ "$timer" -le "$retention_high" ]
	then

		#Stop mpdecision
		stop mpdecision
		pid=(`ps | grep mpdecision`)

		if [ "$pid" -ne "" ];
		then
			echo_to_log "Warning: mpdecision is still running, cannot set retention freq for cpu$index"
		else
			#Retention specific check
			echo 1 > $cpu_path"cpu"$index/online

			#Need to increase the respective cpu freq for rentention to work
			echo $retention_freq > $cpu_path"cpu"$index/$freq_path

			online=$(cat $cpu_path"cpu"$index/online)
			freq=$(cat $cpu_path"cpu"$index/$freq_path)
			echo_to_log "Retention Cpu:$index, Time: $timer, Reqd freq: $retention_freq, Node freq: $freq, Online=$online"
		fi
	fi
}

if [ $cpu == 1 ]
then
	if [ $rand == 1 ]
	then
		RANDOM=$SEED
		count=0
		echo_to_log

		if [ $busy == 1 ]
		then	
			echo_to_log "CACHEBLAST WITH SHUFFLE TEST"
		else 
			echo_to_log "RANDOM CPU LPM TEST"
		fi

		echo_to_log
		echo_to_log "Seed $SEED"

		let "random_time = total_time * RANDITER/100"
		echo_to_log "Random timers generated every $random_time s"

		while [ "$count" -lt "$RANDITER" ]
		do
			index=0
			random_timers=( )
			while [ "$index" -le "${#timer_params[@]}" ]
			do	
				#Scale $timer down within $LOW and $HIGH
				mid=$(( $HIGH - $LOW + 1))
				timer=$(( $RANDOM % $mid + $LOW))
				random_timers=$random_timers' '${timer_params[$index]//,0/,$timer}
				#Calling the retention frequency function to raise the cpu freq if reqd
				retention $index $timer
				((index++))
			done

			if [ $busy == 1 ]
			then
				run_test "./cpu_lpm_cacheblast.sh $PM_STATS $LOW $HIGH $random_time $random_timers"
				# run_test "./cpu_lpm -t $random_time -p $PM_STATS -n $num_threads $random_timers"
			else
				run_test "./cpu_lpm -t $random_time -p $PM_STATS -n $num_threads $random_timers"
			fi
			((count++))
		done
	else
		echo_to_log
		echo_to_log "CPU LPM TEST"
		echo_to_log
		for element in "${timer_params[@]}"
		do
			temp=${element#*\[}
			cpuIndex=${temp%,*}
			temp=${element#*,} #remove all the elements before comma
			timer=${temp%\]*}

			#Calling the retention frequency function to raise the cpu freq if reqd
			retention $cpuIndex $timer
		done

		run_test "./cpu_lpm -t $total_time -p $PM_STATS -n $num_threads `echo ${timer_params[@]}`"
		
	fi
fi

echo_to_log "\nDone running for $total_time s\n"

if [ $gdsc -eq 1 ] ;
then
	echo_to_log "POSTCHECK"
	for node in "${gdsc_test_nodes[@]}"
	do
		toggle "$node"
	done
fi

exit 0