# Import test suite definitions
# source ../../init_env

#define globals
__TRUE=1
__FALSE=0
__BIGCPUS=""
__LITTLECPUS=""
__CORESFILE="$BASEDIR/cores"

# global return value
__RET=""

##########################################################################################################
#	FunName : getAndroidBranchName
#	Purpose : Return Current Android Version
##########################################################################################################
cpuThreshold="20"
timeRunValue="15"
function getAndroidBranchName
{
   branch=`getprop ro.build.version.release`
   if [ "${branch:0:3}" == "4.0" ]
	then
		androidversion="ICS"
	elif [ "${branch:0:3}" == "4.1" ]
	then
		androidversion="JB"
	elif [ "${branch:0:3}" == "4.2" ]
	then
		androidversion="JBMR1"
	elif [ "${branch:0:3}" == "4.3" ]
	then
		androidversion="JBMR2"	# HERE JBMR1s settings were used for JBMR2 , hence assigned JBMR2 to JBMR1
	elif [ "${branch:0:3}" == "4.4" ] || [ "${branch:0:3}" == "Key" ]
	then
		androidversion="KK"	# HERE JBMR1s settings were used for JBMR2 , hence assigned JBMR2 to JBMR1
	elif [ "${branch:0:1}" == "L" ] || [ "${branch:0:3}" == "5.0" ]
	then
		androidversion="L"
	elif [ "${branch:0:3}" == "6.0" ] || [ "${branch:0:1}" == "M" ]
	then
		androidversion="M"
	fi
	echo "$androidversion"
}

##########################################################################################################
#	FunName : LimitCPU
#	Purpose : To limit the CPU usage to 1/4 th of available %CPU
##########################################################################################################

function LimitCPU
{
	procName=$1
	PidArray=`busybox pgrep $procName`
	for id in $PidArray
	do
		IdleCPU=`busybox mpstat | busybox awk '{print $11}' | busybox tail -n 1`
		INTIdleCPU=${IdleCPU/.*}
		StressCPU=`busybox expr $INTIdleCPU / 3` ## Always allocate 1/3rd of available cpu if multiple procs exist on same name.
		$TOOLS/cpulimit -p $id -l $StressCPU -z &
	done

}

##########################################################################################################
#	FunName : getCPUValue
#	Purpose : To get available %CPU
##########################################################################################################

function getCPUValue
{
	IdleCPU=`busybox mpstat | busybox awk '{print $11}' | busybox tail -n 1`
	INTIdleCPU=${IdleCPU/.*}
	echo "$INTIdleCPU"
}
##########################################################################################################
#	FunName : forceStopPackage
#	Purpose : fore killl on given package
##########################################################################################################

function forceStopPackage
{
	package=$1
	#PidArray=`ps | grep $package | busybox awk '{ print $2 }'`
	PidArray=`busybox pidof $package`
	index=0
	for id in $PidArray
	do
		MYARRAY[$index]="$id"
		echo "killing pid : ${MYARRAY[$index]}"
		#kill 0 ${MYARRAY[$index]}
		#kill -15 ${MYARRAY[$index]}
		(kill -9 ${MYARRAY[$index]} 2>&1) >/dev/null
		wait ${MYARRAY[$index]} 2>/dev/null
		index=$(($index+1))
	done
	#exit $exitstatuss
}
trap forceStopPackage EXIT

##########################################################################################################
#	FunName : logcatMessage
#	Purpose : Appending logs to logcat at the time of killing process
##########################################################################################################
function logcatMessage
{
	testCase=$1
	operation=$2
	packageName=$3
	if [ $operation == "0" ]
	then
		log -t BGTEST "Starting Testcase : $testCase"
	elif [ $operation == "1" ]
	then
		log -t BGTEST "Stopping Testcase : $testCase"
	else
		log -t BGTEST "$testCase : Killing $packageName"
	fi
}

function trim
{
	inputString=$1
	outputString=`echo $inputString | busybox sed 's/^ *//g' | busybox sed 's/ *$//g'`
	echo $outputString
}

##########################################################################################################
# Function: wakeup
# purpose : It's unlock device, setting screen timeout, and waking up the device.
##########################################################################################################

function wakeup
{
	input keyevent 6
	input keyevent 26
	input keyevent 82
	input keyevent 3
}


##########################################################################################################
# Function: getTarget
# purpose : Returns the Type of target based on SoCid
##########################################################################################################

function getTarget
{
	if [ -d /sys/devices/system/soc ]
	then
		TargetName=`cat /sys/devices/system/soc/soc0/id`
	else
		TargetName=`cat /sys/devices/soc0/soc_id`
	fi
	if [ $TargetName == "109" ] || [ $TargetName == "130" ] || [ $TargetName == "153" ]
	then
		TargetName1="8064"
	elif [ $TargetName == "87" ] || [ $TargetName == "122" ] || [ $TargetName == "123" ] || [ $TargetName == "124" ]
	then
		TargetName1="MSM8960"
	elif [ $TargetName == "116" ] || [ $TargetName == "117" ] || [ $TargetName == "118" ] || [ $TargetName == "119" ] || [ $TargetName == "154" ]
	then
		TargetName1="MSM8930"
	elif [ $TargetName == "129" ] || [ $TargetName == "127" ]
	then
		TargetName1="MSM8625"
	elif [ $TargetName == "70" ] || [ $TargetName == "71" ] || [ $TargetName == "86" ]
	then
		TargetName1="MSM8660"
	elif [ $TargetName == "43" ] || [ $TargetName == "44" ] || [ $TargetName == "61" ] || [ $TargetName == "69" ] || [ $TargetName == "68" ] || [ $TargetName == "67" ]
	then
		TargetName1="7x27"
	elif [ $TargetName == "74" ] || [ $TargetName == "75" ] || [ $TargetName == "85" ]
	then
		TargetName1="8x55"
	elif [ $TargetName == "59" ] || [ $TargetName == "60" ]
	then
		TargetName1="7x30"
	elif [ $TargetName == "98" ]
	then
		TargetName1="B2G"
	elif [ $TargetName == "126" ] || [ $TargetName == "184" ] || [ $TargetName == "194" ] || [ $TargetName == "218" ]
	then
		TargetName1="MSM8974"
	elif [ $TargetName == "104" ]
	then
		TargetName1="9615"
	elif [ $TargetName == "152" ]
	then
		TargetName1="9625"
	elif [ $TargetName == "145" ] || [ $TargetName == "199" ] || [ $TargetName == "200" ]
	then
		TargetName1="MSM8226"
	elif [ $TargetName == "165" ] || [ $TargetName == "147" ] || [ $TargetName == "162" ]
	then
		TargetName1="MSM8610"
	elif [ $TargetName == "206" ]
	then
		TargetName1="MSM8916"
	elif [ $TargetName == "239" ]
	then
		TargetName1="MSM8939"
	elif [ $TargetName == "233" ]
	then
		TargetName1="MSM8936"
	elif [ $TargetName == "207" ]
	then
		TargetName1="MSM8994"
	elif [ $TargetName == "251" ]
	then
		TargetName1="MSM8992"
	elif [ $TargetName == "268" ]
	then
		TargetName1="MSM8929"
	elif [ $TargetName == "246" ]
	then
		TargetName1="MSM8996"
	elif [ $TargetName == "264" ]
	then
		TargetName1="MSM8952"
	elif [ $TargetName == "278" ]
	then
		TargetName1="MSM8976"
	elif [ $TargetName == "245" ]
	then
		TargetName1="MSM8909"
	fi
	echo $TargetName1
}

##########################################################################################################
#	FunName : CPULoad
#	Purpose : loads the cpu based ramdom load value using lookbusy binary

##########################################################################################################

function CPULoad
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "lookbusy"
		echo "Starting CPU load with with ramdom load value <40 - 60>"
		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/lookbusy -c 5-10 -P 2m -r curve -n `cat /proc/cpuinfo| grep processor | busybox wc -l` -p 2m &
		sleep 2
		# LimitCPU "lookbusy"
		if busybox pgrep lookbusy > /dev/null 2>&1; then
			echo "TestResult for CPULoad - PASS"
		else
			echo "TestResult for CPULoad - FAIL"
		fi
		sleep $((10 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for CPULoad - Not Executed as available CPU % is < $cpuThreshold "
	fi


}

##########################################################################################################
#	FunName : CoreSwitch
#	Purpose : switches CPU cores throgh [0-3]
##########################################################################################################


function CoreSwitch
{
	checkTarget=$(getTarget)
	if [ $checkTarget == "MSM8939" ]
	then
		rand=$(intrandfromrange 1 5)
		SwitchCore8939 $rand 7
	else
		corei=1
		NumCores=`cat /sys/devices/system/cpu/possible`
		if [ $NumCores = "0-1" ]
		then
			echo "CoreSwitch_APStress - Toggling Core 1"
			enableCore 1
			disableCore 1
		elif [ $NumCores = "0-3" ]
		then
			rand=$(intrandfromrange 1 2)
			SwitchCore $rand 3
		else
			rand=$(intrandfromrange 1 5)
			SwitchCore $rand 7
		fi
	fi
}


function SwitchCore
{
n=$1
totalCores=$2
corek=0
corej=0
list=0
randExecution=$(intrandfromrange 1 5)
echo "***** No of cores to be enabled -----  $n *********"
echo "***** No of times executed 	  -----  $randExecution   *********"
while [ $list -lt $randExecution ]
do
	while [ $corek -lt $n ]
	do
		randOnline=$(intrandfromrange 1 $totalCores)
		echo "*****   Enabling -----  $randOnline    **********"
		enableCore $randOnline
		MYARRAYCORE[$corek]=$randOnline
		corek=`busybox expr $corek + 1`
	done
	corek=0
	while [ $corej -lt $n ]
	do
		randOffline=${MYARRAYCORE[$corek]}
		echo "*****   Disabling -----  $randOffline    **********"
		disableCore $randOffline
		corej=`busybox expr $corej + 1`
		corek=`busybox expr $corek + 1`
	done
	list=`busybox expr $list + 1`
	corek=0
	corej=0
done
}
##########################################################################################################
#	FunName : hotpluggable_cpus
#	Purpose : check whether the core is hotpluggable
##########################################################################################################

hotpluggable_cpus()
{
	local state=$1
	if [ -f /sys/devices/system/cpu/cpu$2/online ] && grep -q $state /sys/devices/system/cpu/cpu$2/online; then
		echo 1
	else
		echo 0
	fi
}

#########################################################################################################
#	FunName : enableCore
#	Purpose : Enables CPU cores throgh [0-3]
##########################################################################################################

function enableCore
{
	target=$(getTarget)
	if [ $target == "MSM8939" ] || [ $target == "MSM8936"]
	then
		echo "No need of stopping mpdecision for MSM8939"
	else
		stop mpdecision
	fi
	sleep 1
	core=$1
	result=$(hotpluggable_cpus 0 $core) ## Check whether the core is in offline before switch to online
	if [ $result == "1" ]
	then
		case "$core" in
			1) echo 1 > /sys/devices/system/cpu/cpu1/online
				;;

			2) echo 1 > /sys/devices/system/cpu/cpu2/online
				;;

			3) echo 1 > /sys/devices/system/cpu/cpu3/online
				;;

			4) echo 1 > /sys/devices/system/cpu/cpu4/online
				;;

			5) echo 1 > /sys/devices/system/cpu/cpu5/online
				;;

			6) echo 1 > /sys/devices/system/cpu/cpu6/online
				;;

			7) echo 1 > /sys/devices/system/cpu/cpu7/online
				;;

			*) echo "wrong core info provided"
				;;
		esac
	fi
	index=0
	cpuinfo=`cat /sys/devices/system/cpu/cpu*/online`
	for CoreNum in $cpuinfo
	do
		MYARRAY[$index]="$CoreNum"
		index=$(($index+1))
	done

	if [ $target == "MSM8939" ] || [ $target == "MSM8936"]
	then
		echo "No need of  starting mpdecision MSM8939 PL"
	else
		start mpdecision
	fi
	sleep 1
	if [ $index == 0 ] || [ $index <= $core ]
	then
		echo "CoreSwitch_APStress - enableCore - *** error in call to adb for cpu list *** ***"
	fi
	if [ ${MYARRAY[$core]} == 1 ]
	then
		echo "TestResult for CoreSwitch_APStress - enableCore - PASS for $core"
	else
		echo "TestResult for CoreSwitch_APStress - enableCore - FAIL Unable to enable core : $core"
	fi
}

##########################################################################################################
#	FunName : disableCore
#	Purpose : Disables CPU cores throgh [0-3]
##########################################################################################################

function disableCore
{

	core=$1
	target=$(getTarget)
	if [ $target == "MSM8939" ] || [ $target == "MSM8936"]
	then
		echo "No need of  stopping mpdecision MSM8939 PL"
	else
		stop mpdecision
	fi
	sleep 1
	result=$(hotpluggable_cpus 1 $core) ## Check whether the core is in online before switch to offline
	if [ $result == "1" ]
	then
		case "$core" in
			1) echo 0 > /sys/devices/system/cpu/cpu1/online
				;;

			2) echo 0 > /sys/devices/system/cpu/cpu2/online
				;;

			3) echo 0 > /sys/devices/system/cpu/cpu3/online
				;;

			4) echo 0 > /sys/devices/system/cpu/cpu4/online
				;;

			5) echo 0 > /sys/devices/system/cpu/cpu5/online
				;;

			6) echo 0 > /sys/devices/system/cpu/cpu6/online
				;;

			7) echo 0 > /sys/devices/system/cpu/cpu7/online
				;;

			*) echo "wrong core info provided"
				;;
		esac
	fi
	index=0
	cpuinfo=`cat /sys/devices/system/cpu/cpu*/online`
	#echo cpuinfo : $cpuinfo

	for CoreNum in $cpuinfo
	do
		# echo cpu $CoreNum
		MYARRAY[$index]="$CoreNum"
		index=$(($index+1))
	done
#	echo index : $index
	#echo CoreSwitch_APStress - disableCore $core
	if [ $target == "MSM8939" ] || [ $target == "MSM8936" ]
	then
		echo "No need of  starting mpdecision MSM8939 PL"
	else
		start mpdecision
	fi
	sleep 1
	if [ $index == 0 ] || [ $index <= $core ]
	then
		echo "CoreSwitch_APStress - enableCore - *** error in call to adb for cpu list *** ***"
	fi
	if [ ${MYARRAY[$core]} == 0 ]
	then
		echo "TestResult for CoreSwitch_APStress - disableCore - $core- PASS"
	else
		echo "TestResult for CoreSwitch_APStress - disableCore - 	Unable to disable core : $core"
	fi
}

##################################################################################################
#	FunName : CacheBench
#	Purpose : read/writes data between cache and main memory and tests the performance of cache
##################################################################################################

function CacheBench
{
	cpuAvailable=$(getCPUValue)
	local res
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "cachebench"
		echo "Running CacheBench test for 150 seconds "
		echo "CacheBench - Running CacheBench test for 150 seconds "
		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/cachebench -rwbtsp -x 8 -m 32 -d 5 -e 2 &
		sleep 2
		if busybox pgrep cachebench > /dev/null 2>&1; then
			echo "TestResult for CacheBench - PASS"
			res=0
		else
			echo "TestResult for CacheBench - FAIL"
			res=1
		fi
		LimitCPU "cachebench"
		sleep $((10 * timeRunValue))
	else
		echo "TestResult for CacheBench - Not Executed as available CPU % is < $cpuThreshold "
	fi
	echo "$res"
}

##########################################################################################################
#	FunName : MemoryLoad
#	Purpose : Loads the main memory by random load values in the range of 10-75KB
##########################################################################################################

function MemoryLoad
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "memeater"
		intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
		rand=$(intrandfromrange 20 60)
		target=$(getTarget)

		rand=`busybox expr $rand \* 1024`

		echo "MemoryLoad - Starting Memory load with with ramdom load value <$rand>"

		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/memeater -e $rand &
		sleep 2
		LimitCPU "memeater"
		if busybox pgrep memeater > /dev/null 2>&1; then
			echo "TestResult for MemoryLoad - PASS"
		else
			echo "TestResult for MemoryLoad - FAIL"
		fi
		sleep $((10 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi

	else
		echo "TestResult for MemoryLoad - Not Executed as available CPU % is < $cpuThreshold "
	fi


}

#################################################################################################################
#	FunName : TLBTrasher
#	Purpose : creates N nuber of processess with specified number of threads and read/writes pages amongs them
#################################################################################################################

function TLBTrasher
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "tlb-thrasher"
		echo "Running TLBTrasher test for 150 seconds "
		echo "TLBTrasher - Running TLBTrasher test for 150 seconds "
		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/tlb-thrasher --nprocess=15 --nthreads=10 --tlb_size=256 --page_size=4096 --num_iterations=1000 &
		sleep 2
		LimitCPU "tlb-thrasher"
		if busybox pgrep tlb-thrasher > /dev/null 2>&1; then
			echo "TestResult for TLBTrasher - PASS"
		else
			echo "TestResult for TLBTrasher - FAIL"
		fi
		sleep $((10 * timeRunValue))
		busybox killall -9  cpulimit
	else
		echo "TestResult for TLBTrasher - Not Executed as available CPU % is < $cpuThreshold "
	fi

}

#################################################################################################################
#	FunName : QPuppy_Memwatch
#	purpose : Allocate a buffer of <size> bytes, fill it with random data wait <delay> uS,
#     		  This is useful for testing long-term memory stability, to see if some agent is scribbling over DDR
#			  belonging to memwatch
#################################################################################################################

function QPuppy_Memwatch
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "memwatch"
		echo "Running QPuppy_Memwatch test for 900 seconds "
		echo "QPuppy_Memwatch - Running QPuppy_Memwatch test for 150 seconds "

		$TOOLS/timerun $((60 * timeRunValue)) $TOOLS/memwatch 104857600 1000000 & #This will grab 100MB and fill/wait/verify its contents every second
		sleep 2
		LimitCPU "memwatch"
		if busybox pgrep memwatch > /dev/null 2>&1; then
			echo "TestResult for QPuppy_Memwatch - PASS"
		else
			echo "TestResult for QPuppy_Memwatch - FAIL"
		fi
		sleep $((60 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for QPuppy_Memwatch - Not Executed as available CPU % is < $cpuThreshold "
	fi
}


#################################################################################################################
#	FunName : QPuppy_Memfidget
#	purpose : Creates two buffers of buf_size bytes, fills them with random values,
#   		  copies random-sized regions between them and compares the result.
#			  This is useful for generating general dcache and L2 pressure.
#################################################################################################################

function QPuppy_Memfidget
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "memfidget"
		echo "Running QPuppy_Memfidget test for 900 seconds "
		echo "QPuppy_Memfidget - Running QPuppy_Memfidget test for 150 seconds "

		$TOOLS/timerun $((60 * timeRunValue)) $TOOLS/memfidget 50000000 & ##This will create two buffers of 5,000,000 bytes and copy data between them
		sleep 2
		LimitCPU "memfidget"
		if busybox pgrep memfidget > /dev/null 2>&1; then
			echo "TestResult for QPuppy_Memfidget - PASS"
		else
			echo "TestResult for QPuppy_Memfidget - FAIL"
		fi
		sleep $((60 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null ; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for QPuppy_Memfidget - Not Executed as available CPU % is < $cpuThreshold "
	fi

}

#################################################################################################################
#	FunName : QPuppy_Cacheblast
#	purpose : Fills the cache with specified min/max amount of data in the specified min/max delay
#			/data/virtiotests/qpuppy/cacheblast $mincount $maxcount $min_delay $max_delay";
#################################################################################################################

function QPuppy_Cacheblast
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "cacheblast"
		echo "Running QPuppy_Cacheblast test for 900 seconds "
		echo "QPuppy_Cacheblast - Running Cacheblast test for 150 seconds "

		# $TOOLS/timerun $((60 * timeRunValue)) $TOOLS/cacheblast 100 50000 100 100000 &
		$TOOLS/timerun 10 $TOOLS/cacheblast 100 50000 100 100000 &
		sleep 2
		LimitCPU "cacheblast"
		if busybox pgrep cacheblast > /dev/null 2>&1; then
			echo "TestResult for QPuppy_Cacheblast - PASS"
		else
			echo "TestResult for QPuppy_Cacheblast - FAIL"
		fi
		# sleep $((60 * timeRunValue))
		sleep 10
		if busybox pgrep cpulimit &> /dev/null ; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for QPuppy_Cacheblast - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : QPuppy_Stress
#	purpose : stress the CPU with io operations on specified amount of data (VM bytes) in the duration of timeout
#################################################################################################################

function QPuppy_Stress
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "stress"
		#echo "Running QPuppy_Stress test for 150 seconds " [COMMENTED BY PRIYAR]
		echo "Running QPuppy_Stress test for 900 seconds"
		echo "QPuppy_Stress - Running QPuppy_Stress test for 150 seconds "
		target=$(getTarget)
		if [ $target == "MSM8610" ]
		then
			echo "QPuppy_Stress not applicable for MSM8610 PL"
		else
			TotalVmalloc=`cat /proc/meminfo | grep VmallocTotal: | busybox awk '{print $2}'`
			UsedVmalloc=`cat /proc/meminfo | grep VmallocUsed: | busybox awk '{print $2}'`
			AvailableVmalloc=`busybox expr $TotalVmalloc - $UsedVmalloc`
			stressVMBytes=`busybox expr 30 \* $AvailableVmalloc / 100`
			stressVMBytes=`busybox expr $stressVMBytes \* 1024 `  ### Stress 30% of available memory interms of Bytes.

			NumCores=`cat /sys/devices/system/cpu/possible`

			if [ $NumCores = "0-1" ]
			then
				$TOOLS/timerun $((60 * timeRunValue)) $TOOLS/stress --cpu 2 --io 2 --vm 1 --vm-bytes $stressVMBytes &
			elif [ $NumCores = "0-3" ]
			then
				$TOOLS/timerun $((60 * timeRunValue)) $TOOLS/stress --cpu 4 --io 2 --vm 1 --vm-bytes $stressVMBytes &
			else
				$TOOLS/timerun $((60 * timeRunValue)) $TOOLS/stress --cpu 8 --io 2 --vm 1 --vm-bytes $stressVMBytes &
			fi
			sleep 2
			LimitCPU "stress"
		fi

		if busybox pgrep stress > /dev/null 2>&1; then
			echo "TestResult for QPuppy_Stress - PASS"
		else
			echo "TestResult for QPuppy_Stress - FAIL"
		fi
		sleep $((60 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null ; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for QPuppy_Stress - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : QPuppy_FileMonkey
#	purpose : Online / offline CPU cores at random intervals between 50ms and 300ms
#################################################################################################################

function QPuppy_FileMonkey
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		NumCores=`cat /sys/devices/system/cpu/possible`

		if [ $NumCores = "0-1" ]
		then
			FileMonkey_core 1 150
		elif [ $NumCores = "0-3" ]
		then
			FileMonkey_core 1 50
			FileMonkey_core 2 50
			FileMonkey_core 3 50
		else
			checkTarget=$(getTarget)
			if [ $checkTarget == "MSM8939" ]
			then
				tzSensorType=`cat /sys/devices/virtual/thermal/thermal_zone6/type` ##check thermal_zone6 temperature for core1 on actacore
				tzSensorTemp=`cat /sys/devices/virtual/thermal/thermal_zone6/temp`
				if [ $tzSensorType == "tsens_tz_sensor6" -a $tzSensorTemp -le "60" ]
				then
					FileMonkey_core 1 15
				else
					echo "TestResult for QPuppy_FileMonkey - can't run file monkey on core 2/3 as core temparature is : $tzSensorTemp"
				fi
				tzSensorType=`cat /sys/devices/virtual/thermal/thermal_zone7/type` ##check thermal_zone7 temperature for core2 on actacore
				tzSensorTemp=`cat /sys/devices/virtual/thermal/thermal_zone7/temp`
				if [ $tzSensorType == "tsens_tz_sensor7" -a $tzSensorTemp -le "55" ]
				then
					FileMonkey_core 2 15
				else
					echo "TestResult for QPuppy_FileMonkey - can't run file monkey on core 2/3 as core temparature is : $tzSensorTemp"
				fi

				tzSensorType=`cat /sys/devices/virtual/thermal/thermal_zone8/type` ##check thermal_zone8 temperature for core3 on actacore
				tzSensorTemp=`cat /sys/devices/virtual/thermal/thermal_zone8/temp`
				if [ $tzSensorType == "tsens_tz_sensor8" -a $tzSensorTemp -le "55" ]
				then
					FileMonkey_core 3 15
				else
					echo "TestResult for QPuppy_FileMonkey - can't run file monkey on core 2/3 as core temparature is : $tzSensorTemp"
				fi

				tzSensorType=`cat /sys/devices/virtual/thermal/thermal_zone9/type` ##check thermal_zone2 temperature for core4/5/6/7 on actacore
				tzSensorTemp=`cat /sys/devices/virtual/thermal/thermal_zone9/temp`
				if [ $tzSensorType == "tsens_tz_sensor9" -a $tzSensorTemp -le "75" ]
				then
					FileMonkey_core 4 15
					FileMonkey_core 5 15
					FileMonkey_core 6 15
					FileMonkey_core 7 15
				else
					echo "TestResult for QPuppy_FileMonkey - can't run file monkey on core 4/5/6/7 as core temparature is : $tzSensorTemp"
				fi
			else
				#FileMonkey_core 1 128 [COMMENTED BY PRIYAR]
				#FileMonkey_core 2 128
				#FileMonkey_core 3 128
				#FileMonkey_core 4 128
				#FileMonkey_core 5 128
				#FileMonkey_core 6 128
				#FileMonkey_core 7 128
				intrandfromrange() { echo $(( ( RANDOM % ($2 - $1 +1 ) ) + $1 )); }
				rand=$(intrandfromrange 15 30)
				FileMonkey_core 1 $rand
				FileMonkey_core 2 $rand
				FileMonkey_core 3 $rand
				FileMonkey_core 4 $rand
				FileMonkey_core 5 $rand
				FileMonkey_core 6 $rand
				FileMonkey_core 7 $rand
			fi
		fi
	else
		echo "TestResult for QPuppy_FileMonkey - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

function FileMonkey_core
{
	logcatMessage "QPuppy_FileMonkey" "2" "filemonkey"
	forceStopPackage "filemonkey"
	echo "Running QPuppy_FileMonkey test for $2 seconds "
	echo "QPuppy_FileMonkey - Running QPuppy_FileMonkey test for $2 seconds on core : $1"
	#/data/virtiotests/filemonkey /sys/devices/system/cpu/cpu$1/online s 50000 300000  0 1 & [COMMENTED BY PRIYAR]
	$TOOLS/timerun $2 /data/virtiotests/qpuppy/filemonkey /sys/devices/system/cpu/cpu$1/online s 50000 300000 0 1 &
	sleep 2
	LimitCPU "filemonkey"
	if busybox pgrep filemonkey > /dev/null 2>&1; then
		echo "TestResult for QPuppy_FileMonkey - PASS on core : $1"
	else
		echo "TestResult for QPuppy_FileMonkey - FAIL on core : $1"
	fi
	sleep $2
	logcatMessage "QPuppy_FileMonkey" "2" "filemonkey"
	if busybox pgrep cpulimit &> /dev/null ; then
		busybox killall -9  cpulimit
	fi

}

#################################################################################################################
#	FunName : QPuppy_FileMonkeyFrequencyScale
#	purpose : Frequency Scaling on CPU cores at random intervals between 5ms and 50ms
#################################################################################################################

function QPuppy_FileMonkeyFrequencyScale
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		NumCores=`cat /sys/devices/system/cpu/possible`

		if [ $NumCores = "0-1" ]
		then
			FileMonkey_FrequencyScale 1 150
		elif [ $NumCores = "0-3" ]
		then
			FileMonkey_FrequencyScale 1 50
			FileMonkey_FrequencyScale 2 50
			FileMonkey_FrequencyScale 3 50
		else
			FileMonkey_FrequencyScale 1 30
			FileMonkey_FrequencyScale 2 30
			FileMonkey_FrequencyScale 3 30
			FileMonkey_FrequencyScale 4 30
			FileMonkey_FrequencyScale 5 30
			FileMonkey_FrequencyScale 6 30
			FileMonkey_FrequencyScale 7 30
		fi
	else
		echo "TestResult for QPuppy_FileMonkeyFrequencyScale - Not Executed as available CPU % is < $cpuThreshold "
	fi

}

function FileMonkey_FrequencyScale
{
	stop mpdecision
	sleep 2
	logcatMessage "QPuppy_FileMonkeyFrequencyScale" "2" "filemonkey"
	forceStopPackage "filemonkey"
	echo "Running QPuppy_FileMonkeyFrequencyScale test for 150 seconds "
	echo "QPuppy_FileMonkeyFrequencyScale - Running QPuppy_FileMonkeyFrequencyScale test for $2 seconds on core : $1"
	echo 1 > /sys/devices/system/cpu/cpu$1/online
	sleep 1
	CurrentGoverner=`cat /sys/devices/system/cpu/cpu$1/cpufreq/scaling_governor`
	echo "userspace" > /sys/devices/system/cpu/cpu$1/cpufreq/scaling_governor
	sleep 1
	## changing back after praveens comment--was changed before on Pavithras reco
	$TOOLS/timerun $2 /data/virtiotests/qpuppy/filemonkey /sys/devices/system/cpu/cpu$1/cpufreq/scaling_setspeed r 5000 50000 `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies` &
	#/data/virtiotests/filemonkey /sys/devices/system/cpu/cpu$1/cpufreq/scaling_setspeed r 5000 50000 `cat /sys/devices/system/cpu/cpu$1/cpufreq/scaling_available_frequencies` &
	sleep 2
	LimitCPU "filemonkey"
	echo "$CurrentGoverner" > /sys/devices/system/cpu/cpu$1/cpufreq/scaling_governor ##Fall back to previous governer
	start mpdecision
	if busybox pgrep filemonkey > /dev/null 2>&1; then
		echo "TestResult for QPuppy_FileMonkeyFrequencyScale - PASS on core : $1"
	else
		echo "TestResult for QPuppy_FileMonkeyFrequencyScale - FAIL on core : $1"
	fi
	sleep $2
	logcatMessage "QPuppy_FileMonkeyFrequencyScale" "2" "filemonkey"
	busybox killall -9 cpulimit

}

#################################################################################################################
#	FunName : Ftp_Download
#	purpose : Downloads specified file from ftp server
#################################################################################################################
function Ftp_Download
{
	wifistate=`dumpsys wifi | grep Wi-Fi`
	wififlag=0
	rm $ftpPath/5MB.bin
	if [ "$wifistate" == "Wi-Fi is enabled" ]
	then
		wififlag=1  #enabling a flag when wifi is on and we disable it
		echo "WIFI was enabled ,disabling it and enabling Data"
		svc wifi disable
		svc data enbale
		sleep 10
	fi
	`netcfg | grep rmnet_data* | grep UP > /sdcard/rmnet_data.txt`
	if [ -s /sdcard/rmnet_data.txt ]
	then
		echo "Ftp_Download - Running Ftp_Download test for 20 seconds - on DATA "
		busybox ftpget -v -u User2 -p QualFTP200 199.106.113.221 $ftpPath/5MB.bin download/5MB.bin &
		#busybox ftpget -v -u anonymous 172.20.98.94  $ftpPath/10MB-FtpTest.bin pub/Stability/down/10MB-FtpTest.bin &
		sleep 20
		filesize=`ls -l -a $ftpPath/5MB.bin | busybox awk '{ print $4}'`
		if [ "$filesize" -gt "0" ]
		then
			echo "TestResult for Ftp_Download on DATA - PASS"
		else
			if [ "$wififlag" -eq "1" ]
			then
				Ftp_OverWiFi
			else
				echo "TestResult for Ftp_Download, on WiFi/3G - FAIL"
			fi
		fi
	else
		if [ "$wififlag" -eq "1" ]
		then
			Ftp_OverWiFi
		else
			echo "TestResult for Ftp_Download, None of the carriers WiFi/3G enabled - FAIL"
		fi
	fi
}
function Ftp_OverWiFi
{
	svc wifi enable
	sleep 10
	busybox ftpget -v -u User2 -p QualFTP200 199.106.113.221 $ftpPath/5MB.bin download/5MB.bin & ## If FTP fails on DATA, perform over WiFi & Move to next test
	echo "Proceed with FTP DL over WiFi as file is not downloaded over 3G"
	sleep 10
	filesize=`ls -l -a $ftpPath/5MB.bin | busybox awk '{ print $4}'`
	if [ "$filesize" -gt "0" ]
	then
		echo "TestResult for Ftp_Download on WiFi - PASS"
	else
		echo "TestResult for Ftp_Download on WiFi - FAIL"
	fi
}
#################################################################################################################
#	FunName : Ftp_Upload
#	purpose : Uploads specified file to ftp server
#################################################################################################################
function Ftp_Upload
{
	wifistate=`dumpsys wifi | grep Wi-Fi`
	wififlag=0
	echo "Ftp_Upload - Running Ftp_Upload "
	if [ "$wifistate" == "Wi-Fi is enabled" ]
	then
		wififlag=1  #enabling a flag when wifi is on
		echo "WIFI was enabled ,disabling it"
		svc wifi disable
		svc data enable
		sleep 10
	fi
	`netcfg | grep rmnet_data* | grep UP > /sdcard/rmnet_data.txt`
	if [ -s /sdcard/rmnet_data.txt ]
	then
		dd if=/dev/zero of=/sdcard/1MB-FtpTest.bin bs=1024 count=1024 ##create a file of 1MB with dd command and upload it to FTP server
		busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		#busybox ftpput -v -u anonymous 172.20.98.94 pub/Stability/up/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		sleep 10
		if [ "$?" -eq "0" ]
		then
			echo "TestResult for Ftp_Upload on 3G - PASS"
		else
			echo "TestResult for Ftp_Upload on 3G - FAIL"
		fi
	else
		if [ "$wififlag" -eq "1" ]
		then
			wififlag=0 #disabling flag again for wifi on
			svc wifi enable
			sleep 10
			busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
			## Perform FTP upload over WiFi and move to next test as it will not interrupt any FG/BG tests.
			echo "Perform FTP upload on WiFi and move to next test case"
		else
			echo "TestResult for Ftp_Upload, None of the carriers WiFi/3G enabled - FAIL"
		fi
	fi
}


#################################################################################################################
#	FunName : Ftp_Bidirectional
#	purpose : Uploads/Downloads specified file from/to ftp server
#################################################################################################################
function Ftp_Bidirectional
{
	echo "Ftp_Bidirectional - Running Ftp_Bidirectional test for 20 seconds "
	rm $ftpPath/5MB.bin
	wifistate=`dumpsys wifi | grep Wi-Fi`
	wififlag=0
	if [ "$wifistate" == "Wi-Fi is enabled" ]
	then
		wififlag=1  #enabling a flag when wifi is on and we disable it
		echo "WIFI was enabled ,disabling it"
		svc wifi disable
		sleep 10
	fi
	`netcfg | grep rmnet_data* | grep UP > /sdcard/rmnet_data.txt`
	if [ -s /sdcard/rmnet_data.txt ]
	then
		busybox ftpget -v -u User2 -p QualFTP200 199.106.113.221 $ftpPath/5MB.bin download/5MB.bin &
		#busybox ftpget -v -u anonymous 172.20.98.94  $ftpPath/10MB-FtpTest.bin pub/Stability/down/10MB-FtpTest.bin &
		dd if=/dev/zero of=/sdcard/1MB-FtpTest.bin bs=1024 count=1024 ##create a file of 1MB with dd command and upload it to FTP server
		busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		#busybox ftpput -v -u anonymous 172.20.98.94 pub/Stability/up/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		sleep 20
		filesize=`ls -l -a $ftpPath/5MB.bin | busybox awk '{ print $4}'`
		if [ "$filesize" -gt "0" ]
		then
			echo "TestResult for Ftp_Bidirectional ob 3G - PASS"
		else
			if [ "$wififlag" -eq "1" ]
			then
				Ftp_OverWiFi
				busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
			else
				echo "TestResult for Ftp_Bidirectional, on WiFi/3G - FAIL"
			fi
		fi
	else
		if [ "$wififlag" -eq "1" ]
		then
			Ftp_OverWiFi
			busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
			## Perform FTP upload/Download over WiFi and move to next test as it will not interrupt any FG/BG tests.
		else
		echo "TestResult for Ftp_Bidirectional, None of the carriers WiFi/3G enabled - FAIL"
		fi
	fi

}

#################################################################################################################
#	FunName : runQBlizzardInstances
#	purpose : Run QB instances based on instance count parameter passed
#################################################################################################################
function runQBlizzardInstances
{
	for i in `busybox seq 1 $1`;
	do
		$TOOLS/qblizzardAndCons -stress -startSize 0x1000 -endSize 0x800000 -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads 4 &  ## run Stres test
		LimitCPU "qblizzardAndCons"
	done
}

#################################################################################################################
#	FunName : QBlizzard
#	purpose : Memory Stress testing that creates random tests (test algorithm, size, alignments)
#     		  within the constraints of startSize to endSize
#	USAGE	: test startSize endSize totalSize errorcheck repeatcnt statSamples <testsfile>
#		   		test        [P]erf [PC]erf cold-cache [S]tress [C]reate, usually Perf
#		   		startSize   hex              usually 2K   (800)
#		   		endSize     hex              usually 4M   (400000)
#		   		totalSize   hex              usually 128M (8000000)
#		   		errorCheck  [T]rue [F]alse   usually F for [P]erf, True for [S]tress
#		   		repeatcnt   dec              usually 0    (do not repeat,run test once)
#		   		statSamples dec              usually 10   (test samples)
#		   		testsfile   filename of the tests to run  (always optional)
#################################################################################################################

function QBlizzard
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		if busybox pgrep qblizzardAndCons &> /dev/null; then
			busybox killall -9  qblizzardAndCons
		fi
		# busybox killall -9 qblizzardAndCons 	##forceStopPackage is not used as pkill is not killing QBlizzard process
		target=$(getTarget)
		if [ $target == "MSM8994" ] || [ $target == "MSM8952" ]
		then
			#echo "QBlizzard - Running 4 parallel QBlizzard -Stress tests for 900(seconds)/15 Mins " [COMMENTED BY PRIYAR]
			echo "QBlizzard - Running 5 parallel QBlizzard -Stress tests for 900(seconds)/15 Mins "
			runQBlizzardInstances 3
		else
			echo "QBlizzard - Running QBlizzard -Stress test for 150 seconds "
			runQBlizzardInstances 1
		fi
		if busybox pgrep qblizzardAndCons > /dev/null 2>&1; then
			echo "TestResult for QBlizzard - PASS"
		else
			echo "TestResult for QBlizzard - FAIL"
		fi
		# sleep $((60 * timeRunValue))
		sleep 10
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi
		# busybox killall -9  cpulimit
		if busybox pgrep qblizzardAndCons &> /dev/null; then
			busybox killall -9  qblizzardAndCons
		fi
		# busybox killall -9 qblizzardAndCons
	else
		echo "TestResult for QBlizzard - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : lmdd
#	purpose : copies a specified input file to a specified output with possible conversion rates (Variable Block sizes)
#	USAGE	: lmdd if=%s of=%s bs=%dk flush=1 sync=1

#################################################################################################################
function lmdd_test
{
	logcatMessage "lmdd_test" "2" "lmdd"
	forceStopPackage "lmdd"
	echo "Running lmdd test for 150 seconds "
	echo "lmdd - Running lmdd test for 150 seconds "
	count=0

	if [ -e /sdcard/video/720P_H264_AAC.3gp ]
	then
		lmdd if=/sdcard/video/720P_H264_AAC.3gp of=/sdcard/video/test.3gp bs=128 flush=1 sync=1 &
	else
		echo " lmdd_test  - Source file /sdcard/video/720P_H264_AAC.3gp doesn't exist "
		echo " lmdd_test @ Iteration $count  - FAIL "
	fi
	sleep 2
	LimitCPU "lmdd"
	sleep $((10 * timeRunValue))
	if [ -e /sdcard/video/test.3gp ]
	then
		echo "TestResult for lmdd_test @ Iteration $count  - PASS"
	else
		echo "TestResult for lmdd_test @ Iteration $count  - FAIL"
	fi
	busybox killall -9 cpulimit
	forceStopPackage "lmdd"
	rm /sdcard/video/test.3gp

}

#################################################################################################################
#	FunName : Binder_IPC
#	purpose : perform IPC operation on specified core
#################################################################################################################

function Binder_IPC
{
	NumCores=`cat /sys/devices/system/cpu/possible`

	if [ $NumCores = "0-1" ]
	then
		binderInts 1 60
	elif [ $NumCores = "0-3" ]
	then
		binderInts 1 18
		binderInts 2 18
		binderInts 3 18
	else
		binderInts 1 18
		binderInts 2 18
		binderInts 3 18
		binderInts 4 18
		binderInts 5 18
		binderInts 6 18
		binderInts 7 18
	fi

}

function binderInts
{
	stop mpdecision
	sleep 2
	forceStopPackage "binderAddInts"
	echo "binderInts - Running binderInts test for $2 seconds on core : $1 "
	echo "binderInts - Running binderInts test for $2 seconds on core : $1"
	echo 1 > /sys/devices/system/cpu/cpu$1/online
	sleep 1
	$TOOLS/timerun $2 /data/virtiotests/binderAddInts -s $1 -c $1 -d 1 -n $2 &
	sleep 2
	LimitCPU "binderAddInts"
	start mpdecision
	if busybox pgrep binderAddInts > /dev/null 2>&1; then
		echo "TestResult for Binder_IPC on core : $1 - PASS"
	else
		echo "TestResult for Binder_IPC on core : $1 - FAIL"
	fi
	sleep $2
	busybox killall -9 cpulimit
	rm /sdcard/test_binderAddInts.txt
}

#################################################################################################################
#	FunName : CPUeater
#	purpose : Loads the CPU for specified duration
#################################################################################################################

function CPUeater
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "CPUeater - Running CPUeater test for 150 seconds"
		busybox killall cpueater

		$TOOLS/timerun $((10 * timeRunValue)) /data/virtiotests/memory/cpueater &
		sleep 2
		LimitCPU "cpueater"
		if busybox pgrep cpueater > /dev/null 2>&1; then
			echo "TestResult for CPUeater - PASS"
		else
			echo "TestResult for CPUeater - FAIL"
		fi
		sleep $((10 * timeRunValue))
		busybox killall -9  cpulimit

		busybox killall cpueater   ## Forcestop(pkill) will not kill CPUeater , hence using killall to kill it.
	else
		echo "TestResult for CPUeater - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : ICache
#################################################################################################################

function ICache
{
	echo "ICache - Running ICache test for 150 seconds"
	forceStopPackage "icache"

	$TOOLS/timerun $((5 * timeRunValue)) $TOOLS/icache &
	sleep 1
	LimitCPU "icache"
	if busybox pgrep icache > /dev/null 2>&1; then
		echo "TestResult for ICache - PASS"
	else
		echo "TestResult for ICache - FAIL"
	fi
	sleep $((5 * timeRunValue))
	if busybox pgrep cpulimit &> /dev/null; then
		busybox killall -9  cpulimit
	fi
}

#################################################################################################################
#	FunName : MemTest_madvise
#################################################################################################################

function MemTest_madvise
{
	echo "MemTest_madvise - Running MemTest_madvise test for 150 seconds"
	logcatMessage "MemTest_madvise" "2" "memtest"
	forceStopPackage "memtest"

	$TOOLS/timerun $((5 * timeRunValue)) /data/virtiotests/memory/memtest madvise &
	sleep 2
	LimitCPU "memtest"
	if busybox pgrep memtest > /dev/null 2>&1; then
		echo "TestResult for MemTest_madvise - PASS"
	else
		echo "TestResult for MemTest_madvise - FAIL"
	fi
	sleep $((5 * timeRunValue))
	logcatMessage "MemTest_madvise" "2" "memtest"
	busybox killall -9 cpulimit
}

#################################################################################################################
#	FunName : MemTest_malloc
#################################################################################################################
function MemTest_malloc
{
	echo "MemTest_malloc - Running MemTest_malloc test for 150 seconds"
	forceStopPackage "memtest"

	$TOOLS/timerun $((5 * timeRunValue)) $TOOLS/memtest malloc fill &
	sleep 2
	LimitCPU "memtest"
	if busybox pgrep memtest > /dev/null 2>&1; then
		echo "TestResult for MemTest_malloc - PASS"
	else
		echo "TestResult for MemTest_malloc - FAIL"
	fi
	sleep $((5 * timeRunValue))
	if busybox pgrep cpulimit &> /dev/null; then
		busybox killall -9  cpulimit
	fi
}

#################################################################################################################
#	FunName : MemTest_stack
#################################################################################################################
function MemTest_stackNcrawl
{
	echo "MemTest_stackNcrawl - Running MemTest_stackNcrawl test for 600"
	logcatMessage "MemTest_stackNcrawl" "2" "memtest"
	forceStopPackage "memtest"

	stackResult=`$TOOLS/timerun 100 /data/virtiotests/memtest stack &`
	sleep 2
	LimitCPU "memtest"
	sleep 100
	`echo $stackResult | grep "corrupting" > /sdcard/teststack.txt`
	logcatMessage "MemTest_stackNcrawl" "2" "memtest"
	forceStopPackage "memtest"

	crawlResult=`$TOOLS/timerun 500 /data/virtiotests/memtest crawl &`
	sleep 2
	LimitCPU "memtest"
	sleep 500
	`echo $crawlResult | grep "unwinding..." > /sdcard/testcrawl.txt`
	logcatMessage "MemTest_stackNcrawl" "2" "memtest"
	busybox killall -9 cpulimit

	if [ -s /sdcard/teststack.txt ]
	then
		echo "TestResult for MemTest_stackNcrawl <Stack test > - PASS"
	else
		echo "TestResult for MemTest_stackNcrawl <Stack test > - FAIL"
	fi

	if [ -s /sdcard/testcrawl.txt ]
	then
		echo "TestResult for MemTest_stackNcrawl <crawl test > - PASS"
	else
		echo "TestResult for MemTest_stackNcrawl <crawl test > - FAIL"
	fi
	rm /sdcard/teststack.txt
	rm /sdcard/testcrawl.txt
}


#################################################################################################################
#	FunName : cache_coherency
#	Purpose : Tries to maximize randomized traffic to memory from processor and I/O,
#			  with the intent of creating a realistic high load situation
#################################################################################################################
function cache_coherency
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "cache_coherency - Running cache_coherency test for 600"
		forceStopPackage "stressapptest"

		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/stressapptest -M 64 --cc_test -s 10 &
		sleep 2
		LimitCPU "stressapptest"
		if busybox pgrep stressapptest > /dev/null 2>&1; then
			echo "TestResult for cache_coherency - PASS"
		else
			echo "TestResult for cache_coherency - FAIL"
		fi
		sleep $((10 * timeRunValue))
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi
	else
		echo "TestResult for cache_coherency - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : Iozone
#	Purpose : Read/Write File system
#################################################################################################################
function Iozone
{
	echo "Iozone - Running Iozone test for 60 secs"
	forceStopPackage "iozone"

	$TOOLS/timerun $((4 * timeRunValue)) $TOOLS/iozone -s 100m -r 128k -e true -f /data/local/iozone.txt &
	sleep 2
	LimitCPU "iozone"
	if busybox pgrep iozone > /dev/null 2>&1; then
		echo "TestResult for Iozone - PASS"
	else
		echo "TestResult for Iozone - FAIL"
	fi
	sleep $((4 * timeRunValue))
	if busybox pgrep cpulimit &> /dev/null; then
		busybox killall -9  cpulimit
	fi
}

#################################################################################################################
#	FunName : PingTest
#	Purpose : Test Pings from Google
#################################################################################################################
function PingTest
{
	echo "PingTest - Running PingTest test for 150 secs"
	logcatMessage "PingTest" "2" "ping"
	forceStopPackage "ping"

	busybox nohup ping www.google.com > /sdcard/TestPing.txt &

	if busybox pgrep ping > /dev/null 2>&1; then
		echo "TestResult for PingTest - PASS"
	else
		echo "TestResult for PingTest - FAIL"
	fi
	sleep $((10 * timeRunValue))
	logcatMessage "PingTest" "2" "ping"
	forceStopPackage "ping"
}

#################################################################################################################
#	FunName : Brute_force
#	Purpose : Adreno stress test
#################################################################################################################
function Brute_force
{
	echo "Brute_force - Running Iozone test for 150 secs"
	forceStopPackage "brute_force"
	$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/brute_force &
	sleep 2
	LimitCPU "brute_force"
	if busybox pgrep brute_force > /dev/null 2>&1; then
		echo "TestResult for Brute_force - PASS"
	else
		echo "TestResult for Brute_force - FAIL"
	fi
	sleep $((10 * timeRunValue))
	if busybox pgrep cpulimit &> /dev/null; then
		busybox killall -9  cpulimit
	fi

}
#################################################################################################################
#	FunName : dsiDataCall
#	Purpose : Enables Data and performs ftp download & ping tests
#################################################################################################################
function dsiDataCall
{
	echo "dsiDataCall - Running dsiDataCall test for 150 secs"
	logcatMessage "dsiDataCall" "2" "/data/data_test"
	forceStopPackage "/data/data_test"
	svc wifi disable ##disable wifi before enabling dsi call.
	sleep 1
	svc data disable
	sleep 3

	/data/virtiotests/memory/dsi_netctrl_client start
	sleep 2
	/data/virtiotests/memory/dsi_netctrl_client create xx
	sleep 2
	/data/virtiotests/memory/dsi_netctrl_client up xx
	sleep 2 ## Wait till data up
	`netcfg | grep rmnet0 | grep UP > /sdcard/rmnetState.txt`
	if [ -s /sdcard/rmnetState.txt ]
	then
		ip route add default dev rmnet0
		sleep 2
		busybox nohup ping www.google.com > /sdcard/TestPing.txt &
		sleep 15
		if [ -s /sdcard/TestPing.txt ]
		then
			echo "TestResult for dsiDataCall-Ping Test - PASS"
		else
			echo "TestResult for dsiDataCall-Ping Test - Fail"
		fi
		rm /sdcard/TestPing.txt
		#busybox ftpget -v -u User2 -p QualFTP200 199.106.113.221 $ftpPath/2MB.bin download/2MB.bin &
		busybox ftpget -v -u anonymous 172.20.98.94 $ftpPath/10MB-FtpTest.bin pub/Stability/down/10MB-FtpTest.bin &
		dd if=/dev/zero of=/sdcard/1MB-FtpTest.bin bs=1024 count=1024 ##create a file of 1MB with dd command and upload it to FTP server
		#busybox ftpput -v -u User2 -p QualFTP200 199.106.113.221 upload/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		busybox ftpput -v -u anonymous 172.20.98.94 pub/Stability/up/1MB-FtpTest.bin /sdcard/1MB-FtpTest.bin &
		sleep 120
		filesize=`ls -l -a $ftpPath/10MB-FtpTest.bin | busybox awk '{ print $4}'`
		if [ "$filesize" -gt "0" ]
		then
			echo "TestResult for dsiDataCall-Ftp_Download - PASS"
		else
			echo "TestResult for dsiDataCall-Ftp_Download - FAIL"
		fi
		rm $ftpPath/10MB-FtpTest.bin
		echo "TestResult for dsiDataCall - PASS"
		/data/data_test/dsi_netctrl_client release xx
	else
		echo "TestResult for dsiDataCall <rmnet0 interface not found> - FAIL"
	fi
	logcatMessage "dsiDataCall" "2" "/data/data_test"
	forceStopPackage "/data/data_test"
	svc wifi enable
	sleep 1
	svc data enable
	rm /sdcard/rmnetState.txt
}
#################################################################################################################
#	FunName : sysBench_CPU
#	Purpose : SysBench is a modular, cross-platform and multi-threaded benchmark tool for evaluating
#			  OS parameters that are important for a system running a database under intensive load
#################################################################################################################
function sysBench_CPU
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "sysBench_CPU - Running sysBench_CPU test for 150 secs"
		forceStopPackage "sysbench"

		$TOOLS/timerun $((10 * timeRunValue)) $TOOLS/sysbench --test=cpu --cpu-max-prime=1000 run &
		sleep 2
		LimitCPU "sysbench"

		if busybox pgrep sysbench > /dev/null 2>&1; then
			echo "TestResult for sysBench_CPU - PASS"
		else
			echo "TestResult for sysBench_CPU - FAIL"
		fi
		sleep $((10 * timeRunValue))
	else
		echo "TestResult for sysBench_CPU - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : sysBench_FileIO
#	Purpose : SysBench is a modular, cross-platform and multi-threaded benchmark tool for evaluating
#			  OS parameters that are important for a system running a database under intensive load
#################################################################################################################
function sysBench_FileIO
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "sysBench_FileIO - Running sysBench_FileIO test for 15 secs"
		forceStopPackage "sysbench"

		$TOOLS/sysbench --num-threads=16 --test=fileio --file-total-size=250M --file-test-mode=rndrw prepare
		LimitCPU "sysbench"
		wait $!
		#sleep 2
		$TOOLS/sysbench --num-threads=16 --test=fileio --file-total-size=250M --file-test-mode=rndrw run &
		#sleep 2
		if busybox pgrep sysbench > /dev/null 2>&1; then
			echo "TestResult for sysBench_FileIO - PASS"
			wait $!
		else
			$TOOLS/sysbench --num-threads=16 --test=fileio --file-total-size=250M --file-test-mode=rndrw run &
			#sleep 2
			LimitCPU "sysbench"
			if busybox pgrep sysbench > /dev/null 2>&1; then
				echo "TestResult for sysBench_FileIO - PASS"
				wait $!
			else
				echo "TestResult for sysBench_FileIO - FAIL"
			fi
		fi
		sleep 10
		$TOOLS/sysbench --num-threads=16 --test=fileio --file-total-size=250M --file-test-mode=rndrw cleanup
		wait $!
		cd /
		sleep 2
		if busybox pgrep cpulimit &> /dev/null; then
			busybox killall -9  cpulimit
		fi
		forceStopPackage "sysbench"
	else
		echo "TestResult for sysBench_FileIO - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

##################################################################################################################
#	FunName : Cyclic test
#	Purpose : performs CPU-DMA cyclic Test
##################################################################################################################
function Cyclic_test
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "Cyclic_test - Running Cyclic_test test for 60 secs"
		logcatMessage "Cyclic_test" "2" "cyclictest"
		forceStopPackage "cyclictest"

		NumCores=`cat /sys/devices/system/cpu/possible`

		if [ $NumCores = "0-1" ]
		then
			/data/virtiotests/cpu/cyclictest -t1 -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			sleep 30
			#wait $!
			logcatMessage "Cyclic_test" "2" "cyclictest"
			forceStopPackage "cyclictest"
			busybox killall -9  cpulimit

			/data/virtiotests/cpu/cyclictest -t1 -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			#wait $!
			sleep 30
		elif [ $NumCores = "0-3" ]
		then
			rand=$(intrandfromrange 1 3)
			/data/virtiotests/cpu/cyclictest -t$rand -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			sleep 30
			#wait $!
			logcatMessage "Cyclic_test" "2" "cyclictest"
			forceStopPackage "cyclictest"
			busybox killall -9  cpulimit

			/data/virtiotests/cpu/cyclictest -t$rand -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			#wait $!
			sleep 30
		else
			rand=$(intrandfromrange 1 6)
			/data/virtiotests/cpu/cyclictest -t$rand -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			sleep 30
			#wait $!
			logcatMessage "Cyclic_test" "2" "cyclictest"
			forceStopPackage "cyclictest"
			/data/virtiotests/cpu/cyclictest -t$rand -n -w -b -s -f -p80 -i100 -o10 -v &
			sleep 2
			LimitCPU "cyclictest"
			#wait $!
			sleep 30
		fi
		if busybox pgrep cyclictest > /dev/null 2>&1; then
			echo "TestResult for Cyclic_test - PASS"
		else
			echo "TestResult for Cyclic_test - FAIL"
		fi
		logcatMessage "Cyclic_test" "2" "cyclictest"
		busybox killall -9  cpulimit

		forceStopPackage "cyclictest"
	else
		echo "TestResult for Cyclic_test - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : ScreenRecord
#	Purpose : Records the screen movements
#################################################################################################################
function ScreenRecord
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "ScreenRecord - Running ScreenRecord test for 65 secs"
		logcatMessage "ScreenRecord" "2" "screenrecord"
		forceStopPackage "screenrecord"
		version=$(getAndroidBranchName)
		if [ $version == "KK" ]
		then
			screenrecord /sdcard/APStress/record.mp4 &
			wait $!
			#sleep $((4 * timeRunValue))
			if [ -s /sdcard/APStress/record.mp4 ]
			then
				echo "TestResult for ScreenRecord - PASS"
			else
				echo "TestResult for ScreenRecord - FAIL"
			fi
			logcatMessage "ScreenRecord" "2" "screenrecord"
			forceStopPackage "screenrecord"
			rm /sdcard/APStress/record.mp4
		else
			echo "TestResult for ScreenRecord - It will not suppport on version < KK"
		fi
	else
		echo "TestResult for ScreenRecord - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : DryStone
#	Purpose : Run Bench mark on scaled frequencies
#################################################################################################################
function DryStone
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "DryStone - Running DryStone test "
		logcatMessage "DryStone" "2" "dhry"
		forceStopPackage "dhry"
		CPUString=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)
		CPUArray=( $CPUString )
		for i in ${CPUArray[*]}
		do
			echo $i > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
			echo $i > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
			index=$((RANDOM % 5))
			echo $index > /sys/class/kgsl/kgsl-3d0/min_pwrlevel
			echo $index > /sys/class/kgsl/kgsl-3d0/max_pwrlevel
			/data/virtiotests/dhry >> /sdcard/DryStoneResult.txt
		done
		BenchmarkCount=`grep "Dhrystone Benchmark" /sdcard/DryStoneResult.txt | busybox wc -l`
		if [ $BenchmarkCount -gt 0 ]
		then
			echo "TestResult for DryStone - PASS"
		else
			echo "TestResult for DryStone - FAIL"
		fi
		rm /sdcard/DryStoneResult.txt
		logcatMessage "DryStone" "2" "dhry"
		forceStopPackage "dhry"
	else
		echo "TestResult for DryStone - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

#################################################################################################################
#	FunName : UFS_Read_Write
#	Purpose : Continously spawn threads to read and write to the UFS system
#################################################################################################################
function UFS_Read_Write
{
MNT=/data/local
LMDD=/data/local/lmdd
#LMDD=/data/test/lmdd
FILE=`/system/bin/busybox mktemp $MNT/fio.XXXXXXXX`
#FILE=`/data/test/busybox mktemp $MNT/fio.XXXXXXXX`
rm $MNT/fio*

echo "UFS_Read_Write - Running UFS_Read_Write test for 15 minutes"

for i in $(busybox seq 175)
   do
      for j in $(busybox seq 1 3)
	     do
            if [ $j -eq 2 ]; then
               SRC=$FILE
               DST=/dev/null
            else
               SRC=/dev/zero
               DST=$FILE
            fi
			echo "Command Issued:$LMDD if=$SRC of=$DST bs=128k count=400 sync=1 flush=1"
            $LMDD if=$SRC of=$DST bs=128k count=400 sync=1 flush=1
            sync
            echo 3 > /proc/sys/vm/drop_caches
			`ps | grep /data/local/lmdd > /sdcard/UFS.txt`
         done
   done

echo "UFS test completed"

if [ -s /sdcard/UFS.txt ]
	then
		echo "TestResult for UFS_Read_Write - PASS"
	else
		echo "TestResult for UFS_Read_Write - FAIL"
	fi

rm $MNT/fio*

}

function work_generatorTest
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		#stop thermal-engine
		#echo 0 > /sys/module/msm_thermal/core_control/enabled
		forceStopPackage "work_generator"
		echo "Starting work_generatorTest"
		rm /sdcard/work_generatorResult.txt
		NumCores=`cat /sys/devices/system/cpu/possible`
		iteration=0
		if [ $NumCores = "0-3" ]
		then
			/data/virtiotests/work_generator -w memory -lc 3 -bc 12 -il 0 -t 2 [10000,15,15,95] [10000,20,20,95]  > /sdcard/work_generatorResult.txt

			/data/virtiotests/work_generator -w memory -lc 3 -bc 12 -il 100 -t 2 [10000,15,15,50] [10000,15,15,50] >> /sdcard/work_generatorResult.txt

			/data/virtiotests/work_generator -w memory -lc 3 -bc 12 -il 0 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

			/data/virtiotests/work_generator -w memory -lc 3 -bc 12 -il 100 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

		elif [ $NumCores = "0-7" ]
		then
			target=$(getTarget)
			if [ $target == "MSM8939" ]
			then
				while [ $iteration -lt 5 ]
				do
					echo "Running work_generatorTest for Iteration - $iteration"
					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 0 -t 2 [10000,15,15,95] [10000,20,20,95]  > /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 100 -t 2 [10000,15,15,50] [10000,15,15,50] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 0 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 100 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 0 -therm [big,300000] -t 2 [10000,95,95,95] [10000,95,95,95] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 240 -bc 15 -il 100 -therm [big,300000] -t 2 [10000,95,95,95] [10000,95,95,95] >> /sdcard/work_generatorResult.txt

					iteration=`busybox expr $iteration + 1`
				done
			elif [ $target == "MSM8994" ] || [ $target == "MSM8952" ]
			then
				while [ $iteration -lt 5 ]
				do
					echo "Running work_generatorTest for Iteration - $iteration"
					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 0 -t 2 [10000,15,15,95] [10000,20,20,95]  > /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 100 -t 2 [10000,15,15,50] [10000,15,15,50] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 0 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 100 -t 2 [10000,95,95,5] [10000,95,95,5] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 0 -therm [big,200000] -t 2 [10000,95,95,95] [10000,95,95,95] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 100 -therm [big,200000] -t 2 [10000,95,95,95] [10000,95,95,95] >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 0 -t 1 [10000,10,10,95] -pas 95 >> /sdcard/work_generatorResult.txt

					/data/virtiotests/work_generator -w memory -lc 15 -bc 240 -il 0 -t 1 [10000,95,95,5] -pas 95 >> /sdcard/work_generatorResult.txt

					iteration=`busybox expr $iteration + 1`
				done
			fi
		else
			echo "work_generatorResult - Not allowed on Dual core"
		fi
		if grep -q Passed "/sdcard/work_generatorResult.txt"; then
			echo "TestResult for work_generatorTest - PASS"
		else
			echo "TestResult for work_generatorTest - FAIL"
		fi
		rm /sdcard/work_generatorResult.txt
		forceStopPackage "work_generator"
		#echo 1 > /sys/module/msm_thermal/core_control/enabled
		#start thermal-engine
	else
		echo "TestResult for work_generatorTest - Not Executed as available CPU % is < $cpuThreshold "
	fi

}
function stressapptestTest
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "stressapptest"
		echo "Starting stressapptestTest"

		$TOOLS/timerun $((10 * timeRunValue)) /data/virtiotests/stressapptest -M 128 -s 300 -m 1 -i 1 -C 1  -W --listen --cc_test &
		LimitCPU "stressapptest"
		if busybox pgrep stressapptest > /dev/null 2>&1; then
			echo "TestResult for stressapptest - PASS"
		else
			echo "TestResult for stressapptest - FAIL"
		fi
		sleep $((10 * timeRunValue))
		busybox killall -9  cpulimit

	else
		echo "TestResult for stressapptest - Not Executed as available CPU % is < $cpuThreshold "
	fi
}

function overcommitmentTest
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		#stop thermal-engine
		#echo 0 > /sys/module/msm_thermal/core_control/enabled
		iteration=0
		forceStopPackage "overcommitment"
		echo "Starting overcommitmentTest"
		NumCores=`cat /sys/devices/system/cpu/possible`
		if [ $NumCores = "0-3" ]
		then
			/data/virtiotests/overcommitment -test little -lc 3 -bc 12  > /sdcard/overcommitmentResult.txt
			/data/virtiotests/overcommitment -test big -lc 3 -bc 12  -mml 11000 >> /sdcard/overcommitmentResult.txt
		elif [ $NumCores = "0-7" ]
		then
			target=$(getTarget)
			if [ $target == "MSM8939" ]
			then
				while [ $iteration -lt 15 ]
				do
					echo "Running overcommitmentTest for Iteration - $iteration"
					/data/virtiotests/overcommitment -test little -lc 240 -bc 15 > /sdcard/overcommitmentResult.txt ## overcommitmentTest on 8939

					/data/virtiotests/overcommitment -test big -lc 240 -bc 15 -mml 11000 >> /sdcard/overcommitmentResult.txt  ## overcommitmentTest on 8939

					iteration=`busybox expr $iteration + 1`
				done
			else
				while [ $iteration -lt 15 ]
				do
					echo "Running overcommitmentTest for Iteration - $iteration"
					/data/virtiotests/overcommitment -test little -lc 15 -bc 240 > /sdcard/overcommitmentResult.txt  ## overcommitmentTest on 8994

					/data/virtiotests/overcommitment -test big -lc 15 -bc 240 -mml 11000 >> /sdcard/overcommitmentResult.txt  ## overcommitmentTest on 8994

					iteration=`busybox expr $iteration + 1`
				done
			fi
		else
			echo "overcommitmentResult - Not allowed"
		fi
		if grep -q Passed "/sdcard/overcommitmentResult.txt"; then
			echo "TestResult for overcommitmentTest - PASS"
		else
			echo "TestResult for overcommitmentTest - FAIL"
		fi
		rm /sdcard/overcommitmentResult.txt
		forceStopPackage "overcommitment"
		#echo 1 > /sys/module/msm_thermal/core_control/enabled
		#start thermal-engine
	else
		echo "TestResult for overcommitmentTest - Not Executed as available CPU % is < $cpuThreshold "
	fi

}

##########################################################################################
#	FunName : ebizzyTest
#	Purpose : LTP benchmark for scheduler changes
#-n <num>         Number of memory chunks to allocate
#-R               Randomize size of memory to copy and sea
#-s <size>        Size of memory chunks, in bytes
#-S <seconds>     Number of seconds to run
#-t <num>         Number of threads (2 * number cpus by de
###########################################################################################

function ebizzyTest
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		forceStopPackage "ebizzy"
		echo "Starting ebizzyTest"
		$TOOLS/timerun $((10 * timeRunValue)) /data/virtiotests/ebizzy -R -S 150 -s 2048 -n 4 -t 2 &

		if busybox pgrep ebizzy > /dev/null 2>&1; then
			echo "TestResult for ebizzyTest - PASS"
		else
			echo "TestResult for ebizzyTest - FAIL"
		fi
		sleep $((10 * timeRunValue))
	else
		echo "TestResult for ebizzyTest - Not Executed as available CPU % is < $cpuThreshold "
	fi

}

function affinityTest
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		iteration=0
		forceStopPackage "affinity"
		echo "Starting affinityTest"
		#stop thermal-engine
		#echo 0 > /sys/module/msm_thermal/core_control/enabled
		NumCores=`cat /sys/devices/system/cpu/possible`
		if [ $NumCores = "0-3" ]
		then
			while [ $iteration -lt 15 ]
			do
				echo "Running affinityTest for Iteration - $iteration"
				/data/virtiotests/affinity -lc 3 -bc 12 > /sdcard/affinityResult.txt
				iteration=`busybox expr $iteration + 1`
			done
		elif [ $NumCores = "0-7" ]
		then
			target=$(getTarget)
			if [ $target == "MSM8939" ]
			then
				while [ $iteration -lt 15 ]
				do
					echo "Running affinityTest for Iteration (on 8939) - $iteration"
					/data/virtiotests/affinity -lc 240 -bc 15 > /sdcard/affinityResult.txt ## Affinity on 8939
					iteration=`busybox expr $iteration + 1`
				done
			elif [ $target == "MSM8994" ]
			then
				while [ $iteration -lt 15 ]
				do
					echo "Running affinityTest for Iteration (on 8994)- $iteration"
					/data/virtiotests/affinity -lc 15 -bc 240 > /sdcard/affinityResult.txt ## Affinity on 8994
					iteration=`busybox expr $iteration + 1`
				done
			fi
		else
			echo "affinityTest - Not allowed"
		fi
		if grep -q Passed "/sdcard/affinityResult.txt"; then
			echo "TestResult for affinityTest - PASS"
		else
			echo "TestResult for affinityTest - FAIL"
		fi
		rm /sdcard/affinityResult.txt
		#echo 1 > /sys/module/msm_thermal/core_control/enabled
		#start thermal-engine
	else
		echo "TestResult for affinityTest - Not Executed as available CPU % is < $cpuThreshold "
	fi


}

function voltageScaling
{
	CX_CORNERS=( 0 1 2 3 4 5 6 )
	MX_CORNERS=( 0 1 2 3 4 5 6  )
	GFX_CORNERS=( 0 1 2 3 4 5 6 )
	GFX_CORN_COUNT=${#GFX_CORNERS[@]}
	CX_CORN_COUNT=${#CX_CORNERS[@]}
	MX_CORN_COUNT=${#MX_CORNERS[@]}
	BIMC_CORNERS=( 500000 200000 300000 400000 100000 )
	CNOC_CORNERS=( 10000 30000 50000 70000)
	SNOC_CORNERS=( 50000  90000 140000 160000 100000 )
	PNOC_CORNERS=( 10000 30000 50000 70000 100000 )
	optionAraay=( scaling )			##Define option as array because (if needed) we can add sendRPMMessage test which is subset of voltageScaling test
	option_size=${#optionAraay[@]}
	option_index=$(($RANDOM % $option_size))
	option=${optionAraay[$option_index]}
	echo "voltage Scaling - Starting voltageScaling Test with option : $option"
	$option
}

function scaling
{
	selRailArray=( CX MX GFX BIMC SNOC PNOC CNOC )
	selRail_size=${#selRailArray[@]}
	selRail_index=$(($RANDOM % $selRail_size))
	selRail=${selRailArray[$selRail_index]}  ###Select random rail

	modeArray=( nom ) 					##Define mode as array because (if needed) we can add stress/int mode which are subset of "nom" mode
	mode_size=${#modeArray[@]}
	mode_index=$(($RANDOM % $mode_size))
	mode=${modeArray[$mode_index]}  ###Select random Mode

	case "$selRail" in
		MX) SEL_CORN=( ${MX_CORNERS[@]} )
			sel_smp="smpa"
			sel_res=2
			key=corn
		   ;;
		CX) SEL_CORN=( ${CX_CORNERS[@]} )
			sel_smp="smpa"
			sel_res=1
			key=corn
			;;
		GFX) SEL_CORN=( ${GFX_CORNERS[@]} )
			 echo "Enable GFX"
			 echo active smpb 2 1 swen 1 > /d/rpm_send_msg
			 sel_smp="smpb"
			 sel_res=2
			 key=corn
			;;
		BIMC) SEL_CORN=( ${BIMC_CORNERS[@]} )
			 sel_smp="clk2"
			 sel_res=0
			 key=KHz
			;;
		SNOC) SEL_CORN=( ${SNOC_CORNERS[@]} )
			 sel_smp="clk1"
			 sel_res=1
			 key=KHz
			;;
		PNOC) SEL_CORN=( ${PNOC_CORNERS[@]} )
			 sel_smp="clk1"
			 sel_res=0
			 key=KHz
			;;
		CNOC) SEL_CORN=( ${CNOC_CORNERS[@]} )
			 sel_smp="clk1"
			 sel_res=2
			 key=KHz
			;;
		*) echo "Something is really Wrong"
			 ;;
	esac

	if [ $mode == "nom" ]
	then
		echo "Voting up and down in $delay ms"
		for corn in "${SEL_CORN[@]}"
		do
			echo active $sel_smp $sel_res 1 $key $corn > /d/rpm_send_msg/message
			echo "voltageScaling Test Done on - active $sel_smp $sel_res 1 $key $corn"
			sleep 20
		done
	elif [ $mode == "stress" ]
	then
		echo "Stress Voting up and down in $delay ms"
		corn_size=${#SEL_CORN[@]}
		corn_index=$(($RANDOM % $corn_size))
		corn=${SEL_CORN[$corn_index]}
		echo active $sel_smp $sel_res 1 $key $corn > /d/rpm_send_msg/message
		echo "voltageScaling Test Done on - active $sel_smp $sel_res 1 $key $corn"
		sleep 120
	elif [ $mode -ge 0 ] # vote for a specific corner
	then
		echo " Stress voting for a specific value $level"
		echo active $sel_smp $sel_res 1 $key $mode > /d/rpm_send_msg/message
		echo "voltageScaling Test Done on - active $sel_smp $sel_res 1 $key $mode"
		sleep 120
	else
		echo "Wrong Mode selected"
		echo "voltageScaling Test - Wrong Mode selected"
	fi
}


#################################################################################################################
#	FunName : QMESA_Test
#	Purpose : QMESA_32 and QMESA_64
#################################################################################################################
function QMESA_Test
{
	cpuAvailable=$(getCPUValue)
	echo  " cpuAvailable : $cpuAvailable"
	if [ $cpuAvailable -ge $cpuThreshold ]
	then
		echo "QMESA - Running QMESA test for 150 secs"
		logcatMessage "QMESA" "2" "QMESA"

		buildVersion=`getprop ro.product.name`
		echo "$buildVersion"
		if [ $buildVersion == "msm8952_32" ]
		then
			forceStopPackage "QMESA_32"
			sleep 2
			$TOOLS/timerun $((10 * timeRunValue)) /data/virtiotests/QMESA_32 &
			LimitCPU "QMESA_32"
		elif [ $buildVersion == "msm8952_64" ]
		then
			forceStopPackage "QMESA_64"
			sleep 2
			$TOOLS/timerun $((10 * timeRunValue)) /data/virtiotests/QMESA_64 &
			LimitCPU "QMESA_64"
		fi
		sleep 2

		if busybox pgrep QMESA > /dev/null 2>&1; then
			echo "TestResult for QMESA - PASS"
		else
			echo "TestResult for QMESA - FAIL"
		fi
		sleep $((10 * timeRunValue))
		logcatMessage "QMESA" "2" "QMESA"
		if [ $buildVersion == "msm8952_32" ]
		then
			forceStopPackage "QMESA_32"
		elif [ $buildVersion == "msm8952_64" ]
		then
			forceStopPackage "QMESA_64"
		fi
	else
		echo "TestResult for QMESA - Not Executed as available CPU % is < $cpuThreshold "
	fi
}


#This function will wake up every 100 minutes to kill residue from previous background tests
function kill_residue
{
	while [ 1 ]
	do
		sleep 1500
		echo "It's time to clean up the residue processes"
		forceStopPackage "lookbusy"
		forceStopPackage "cachebench"
		forceStopPackage "memeater"
		forceStopPackage "tlb-thrasher"
		forceStopPackage "memwatch"
		forceStopPackage "memfidget"
		forceStopPackage "cacheblast"
		forceStopPackage "stress"
		forceStopPackage "filemonkey"
		forceStopPackage "brute_force"
		forceStopPackage "stressapptest"
		forceStopPackage "iozone"
		forceStopPackage "sysbench"
		forceStopPackage "cyclictest"

		busybox killall qblizzardAndCons ##forceStopPackage will not kill QBlizzard process
	done

}

NumCores=`cat /sys/devices/system/cpu/possible`
if [ $NumCores = "0-1" ]
then
	smallCluster=( 0 )
	bigCluster=( 1 )
elif [ $NumCores = "0-3" ]
then
	smallCluster=( 0 1 )
	bigCluster=( 2 3 )
else
	smallCluster=( 0 1 2 3 )
	bigCluster=( 4 5 6 7 )
fi
scSize=${#smallCluster[@]}
bcSize=${#bigCluster[@]}

hotpluggable_cpus()
{
	local state=$1
	if [ -f /sys/devices/system/cpu/cpu$2/online ] && grep -q $state /sys/devices/system/cpu/cpu$2/online; then
		echo 1
	else
		echo 0
	fi
}

function enableBigCluster {
	i=0
	while [ i -lt $bcSize ]
	do
		result=$(hotpluggable_cpus 0 ${bigCluster[$i]}) ## Check whether the core is in offline before switch to online
		if [ $result == "1" ]
		then
			echo "Enabling: " ${bigCluster[$i]} "\n"
			hotplugUp ${bigCluster[$i]}
		fi
		i=$((i+1))
	done
}

function enableSmallCluster {
	i=0
	while [ i -lt $scSize ]
	do
		result=$(hotpluggable_cpus 0 ${smallCluster[$i]})	## Check whether the core is in offline before switch to online
		if [ $result == "1" ]
		then
			echo "Enabling:"  ${smallCluster[$i]}
			hotplugUp ${smallCluster[$i]}
		fi
		i=$((i+1))
	done
}

function disableBigCluster {
	i=0
	while [ i -lt $bcSize ]
	do
		result=$(hotpluggable_cpus 1 ${bigCluster[$i]})	## Check whether the core is in online before switch to offline
		if [ $result == "1" ]
		then
			echo "Disabling: " ${bigCluster[$i]} "\n"
			hotplugDown ${bigCluster[$i]}
		fi
		i=$((i+1))
	done
}

function disableSmallCluster {
	i=0
	while [ i -lt $scSize ]
	do
		result=$(hotpluggable_cpus 1 ${smallCluster[$i]})	## Check whether the core is in online before switch to offline
		if [ $result == "1" ]
		then
			echo "Disabling: " ${smallCluster[$i]} "\n"
			hotplugDown ${smallCluster[$i]}
		fi
		i=$((i+1))
	done
}

function hotplugUp {
	local core=$1
	echo 1 > /sys/devices/system/cpu/cpu$core/online
}

function hotplugDown {
	local core=$1
	echo 0 > /sys/devices/system/cpu/cpu$core/online
}

function workOnSmallCluster {
	enableSmallCluster
	disableBigCluster
}

function workOnBigCluster {
	enableBigCluster
	disableSmallCluster
}

function workOnBothCluster {
	enableBigCluster
	enableSmallCluster
}

function workOnXCluster {
	while [ 1 ]
	do
		disableBigCluster
		sleep 10
		enableBigCluster
		sleep 10
	done
}

