#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#To-do:$TOOLS/timerun 600 $eachworkload
source $TOOLS/functestlib.sh

fillmem

blocksize=256
nforks=100
maxfree=$(cat /proc/meminfo|busybox grep MemFree|busybox awk {'print $2'})
memsize=$(($maxfree/1024))
if [ $memsize -lt 1024 ]; then
    $memsize=1024
fi
# memtest64: [-ac][-b blocksize][-f no_forks][-m maxmem] where m should be multiple of 1024
$TOOLS/timerun 600 $TOOLS/mmemtest -b $blocksize -f $nforks -m $memsize
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0
