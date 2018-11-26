#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
source $TOOLS/functestlib.sh

fillmem

maxsize=0

# How many kilobytes free space do we have?
function check_free()
{
    sync
    cat /proc/meminfo |grep MemTotal|busybox awk {'print $2'}
}
Value=$((`check_free`-(1024)))
# if [ $Value -lt 1073741824 ]; then
    # echo "current size of /data is less then 1GB"
    # To-do:??
# fi
freememinkb=$(cat /proc/meminfo |grep MemTotal|busybox awk {'print $3'})
if [ $freememinkb == "kB" ]; then
    maxsize=$(($Value/1048576))
fi
nloops=100
if [ $maxsize -eq 0 ]; then
    maxsize=1
fi
$TOOLS/mstress $maxsize $nloops
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0
