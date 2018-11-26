#!/system/bin/sh
# Program to test DDRStress.
# Released under the Qualcomm License.

# Import test suite definitions
source ../../../../init_env

CORES=`cat /sys/devices/system/cpu/kernel_max`

filemonkey()
{
    for EACHCPU in $( ls -d /sys/devices/system/cpu/cpu* ); do
        CPUID=${EACHCPU:27}
        if [[ "$CPUID" = 'freq' ||  "$CPUID" = 'idle' ]]; then
            continue
        fi
        $TOOLS/filemonkey $EACHCPU/online s 0 0  0 1
    done
}

#shuffle can be used to spawn a given workload and randomly force it to migrate among all available CPUs
shuffle()
{
    WORKLOADS=("$TOOLS/birdbuffer 100 8" "$TOOLS/memwatch 512000 1000000" "$TOOLS/memfidget 3000000" "$TOOLS/cacheblast 100 16000 100 512000")
    for eachworkload in ${WORKLOADS};do
        $TOOLS/timerun 600 $eachworkload
        sleep 2
    done
    $TOOLS/shuffle 300 $TOOLS/cacheblast 100 16000 100 512000
}

#QBlizzard is a system memory benchmarking application
QBlizzard()
{
    # *L1 is generally 1-32KB, L2=32KB-4MB, DDR=4MB++
    # $TOOLS/timerun 600 $TOOLS/QBlizzard -perf -startSize 0x1000 -endSize 0x800000 -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads $CORES
    # $TOOLS/timerun 600 $TOOLS/QBlizzard -stress -startSize 16KB -endSize 0x800000 -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads $CORES
    # $TOOLS/timerun 600 $TOOLS/QBlizzard -rdlat -startSize 0x1000 -endSize 0x800000 -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads $CORES
    # $TOOLS/timerun 600 $TOOLS/QBlizzard -stress -startSize 45KB -endSize 4MB -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads $CORES
    # $TOOLS/timerun 600 $TOOLS/QBlizzard -stress -startSize 4394304 -endSize 60MB -totalSize 0x10000000 -errorCheck TRUE -statSamples 10000 -numThreads $CORES
    $TOOLS/timerun 1800 ./run_qblizzard
    $TOOLS/timerun 1800 ./bmic_clock -f 100000 200000 300000 460800 547200 691200 777600 931200
    $TOOLS/timerun 1800 ./run_random_qblizzard
}
PASSCOUNT=0
export IFS=","
CMDS="shuffle,QBlizzard,"
for each_cmd in ${CMDS}:
  do 
    ${each_cmd}
  if [ $? -eq 0 ];then
    echo "${each_cmd}: Passed"
    PASSCOUNT=$((PASSCOUNT+1))
  else
    echo "${each_cmd}: Failed"
  fi
done

if [ $PASSCOUNT -ge 2 ]; then
    echo "DDRStress: Passed"
else
    echo "DDRStress: Failed"
    exit 1
fi
