#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

source $TOOLS/functestlib.sh

fillmem

#To-do:$TOOLS/timerun 600 $workload
loops=100
freemem=$(cat /proc/meminfo |grep MemTotal|busybox awk {'print $2'})
maxmem=$(($freemem/1048576))

$TOOLS/memtester $maxmem $loops
if [ "$?" -ne "0" ]; then
	echo "Test failure."
	exit -1
fi
echo "Test Success."
exit 0




