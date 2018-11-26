#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
source $TOOLS/functestlib.sh

fillmem

freemem=$(cat /proc/meminfo |grep Buffers|busybox awk {'print $2'})
memsize=$(($freemem/1024))
threads=4
$TOOLS/mtest -m $memsize -r $threads -w $threads
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0




