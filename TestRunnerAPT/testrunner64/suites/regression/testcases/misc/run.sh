# /system/bin/bash
# Import test suite definitions
source ../../../../init_env

#import test functions library
# source $SUITES/stress/funclib.sh
# Import functions library
source $TOOLS/functestlib.sh
RESULT=0
# $TOOLS/regression output cpuhog
WLAN_MODULE="/system/lib/modules/pronto/pronto_wlan.ko"
MAXCPU=$(cat /sys/devices/system/cpu/kernel_max)
SIZE=1024
count=0
# global return value
__RET=""

function test_memtest(){
    echo "Starting memtest"
    path=$(which memtest)
    if [ $? -eq 0 ];then
        $path copy_bandwidth --size $SIZE
        $path write_bandwidth --size $SIZE
        $path read_bandwidth --size $SIZE
        export IFS="|"
        CMDS="copy_ldrd_strd|copy_ldmia_stmia|copy_vld1_vst1|copy_vldr_vstr|copy_vldmia_vstmia|memcpy|write_strd|write_stmia|write_vst1|write_vstr|write_vstmia|memset|read_ldrd|read_ldmia|read_vld1|read_vldr|read_vldmia|"
        for each_cmd in ${CMDS}
            do 
                $path per_core_bandwidth --size $SIZE --type ${each_cmd}
            done
        $path multithread_bandwidth --size $SIZE
        for each_cmd in ${CMDS}
            do 
                $path multithread_bandwidth --size $SIZE --type ${each_cmd} --num_threads $MAXCPU
            done
        malloc_param=$(($SIZE/2))
        $path malloc $malloc_param
        $path madvise
        $path resampler
        $path stack
        $path crawl
    else
        echo "Unable to find memtest in DUT"
    fi
}

function testpcm(){
    echo "Starting pcmtest"
    path=$(which pcmtest)
    if [$? -eq 0 ];then
        $path
    else
        echo "Unable to find pcmtest in DUT"
    fi
}

function testbinderAddInts(){
    echo "Starting binderAddInts"
    path=$(which binderAddInts)
    if [ $? -eq 0 ];then
        server_cpu_num=$(($MAXCPU/2))
        iterations=10
        $path -s $server_cpu_num -c $MAXCPU -n $iterations -d 10
    else
        echo "Unable to find binderAddInts in DUT"
    fi
 }
function testpaging(){
    echo "Starting pagingtest"
    path=$(which pagingtest)
    if [ $? -eq 0 ];then
        $path
    else
        echo "Unable to find pagingtest in DUT"
    fi
}
function testsocketTag(){
    echo "Starting socketTag"
    path=$(which socketTag)
    if [ $? -eq 0 ];then
        export IFS="|"
        CMDS="TagData|InsufficientArgsFails|BadCommandFails|NoTagNoUid|InvalidTagFail|ValidTagWithNoUid|ValidUntag|ValidFirsttag|ValidReTag|ValidReTagWithAcctTagChange|ReTagWithUidChange|Valid64BitAcctTag|TagAnotherSocket|TagInvalidSocketFail|UntagInvalidSocketFail|"
        for each_cmd in ${CMDS}
            do 
                $path --${each_cmd}
            done
    else
        echo "Unable to find socketTag in DUT"
    fi
}
function testcpueater(){
    echo "Starting cpueater"
    path=$(which cpueater)
    if [ $? -eq 0 ];then
        busybox nohup $path &
    else
        echo "Unable to find cpueater in DUT"
    fi
}

function testicache()
{
    echo "Starting icache"
    path=$(which icache)
    if [ $? -eq 0 ];then
        $path
    else
        echo "Unable to find icache in DUT"
    fi
}

function testwifiLoadScanAssoc(){
    echo "Starting wifiLoadScanAssoc"
    path=$(which wifiLoadScanAssoc)
    if [ $? -eq 0 ];then
        $path -s 0 -e $SIZE -d 100
    else
        echo "Unable to find wifiLoadScanAssoc in DUT"
    fi
}
function testsched(){
    echo "Starting schedtest"
    path=$(which schedtest)
    if [ $? -eq 0 ];then
        $TOOLS/timerun 600 $path
    else
        echo "Unable to find schedtest in DUT"
    fi
}

function testpf(){
    echo "Starting pftest"
    path=$(which pftest)
    if [ $? -eq 0 ];then
        $path
    else
        echo "Unable to find pftest in DUT"
    fi
}

#rngd is a daemon that runs conditioning tests on a source of random data
function rng_generator()
{
	echo Starting "PRNG Test"
	rng_device="random|urandom|hw_random"
	for each_dev in ${rng_device}
	do
		# checking for Entropy value, If enropy value is less terminate the test
		entropy_val=$(cat /proc/sys/kernel/random/entropy_avail)
		if [ $entropy_val -le 200 ];then
			echo "Entropy is exhuasted and doesn't deliver anymore random data"
			count=$((count+1))
			break   #Break the for loop
		else
			echo "The system is running with enough Entropy source"
		fi	
		$TOOLS/rngd --rng-device=/dev/${each_dev}
		echo "Running random number generator on ${each_dev} device"
		random_val=$(echo $((RANDOM%100000+10000)))
		#If rngtest reports that one of the FIPS tests failed, try it again with more blocks
		cat /dev/${each_dev}| $TOOLS/rngtest -c ${random_val} > log.txt 2>&1
		pid1=$!
		wait $pid1
		res1=$(cat log.txt | grep successes | awk '{print $5}')
		echo "SUCCUSSES :: $res1"
		res2=$(cat log.txt | grep failures | awk '{print $5}')
		echo "FAILURES :: $res2"
		res=$((100*$res2/$res1))
		if [ $res -gt 5 ];then
			count=$((count+1))
		fi
	done	
	if [ $count == 0 ];then
		echo "Test case Passed"
	else
		echo " Test case Failed"	
	fi
}

function version_check()
{
	echo "checking for kernel version and CPU aarchitecture"
	SUB_VERSION=.XX
	version=$(cat /proc/version  | awk '{print $3}' | cut -c0)
	aarch_info=$(cat /proc/cpuinfo  | head -n 1 | awk '{print $3}')
	if [ $version -gt 3 ]; then
		version_info=$(cat /proc/version  | awk '{print $3}' | cut -c0-3)
		echo "Kernel version    :: $version_info$SUB_VERSION"
		echo "CPU aarchitecture :: $aarch_info"
	else
		version_info1=$(cat /proc/version  | awk '{print $3}' | cut -c0-4)
		echo "Kernel version    :: $version_info$SUB_VERSION"
		echo "CPU aarchitecture :: $aarch_info"
	fi
}
function testcase(){
    success=0
    export IFS="|"
    TESTCASES="version_check|rng_generator|test_memtest|testpcm|testbinderAddInts|testpaging|testsocketTag|testcpueater|testicache|testwifiLoadScanAssoc|testsched|testpf|"
    for each_test in ${TESTCASES}
        do 
            ${each_test}
            if [[ $? -eq 0 ]];then
                success=$((success + 1))
            fi
            sleep 3
        done
}
testcase
if [ "$success" == "11" ] ; then
    echo SUCCESS
else
    echo FAILED
    RESULT=1
fi
exit $RESULT
