#!/system/bin/sh
# Import test suite definitions
tmpfile="bigfile"

source ../../../../init_env
source $TOOLS/functestlib.sh

fillmem
function del()
{
    if [ -f $tmpfile ]; then 
        rm -rf $tmpfile
    fi
}
# You can run the tests mmap001 with one parameter indicating the size of your RAM in megabites.
function check_ram()
{
    sync
    cat /proc/meminfo|busybox grep "MemTotal"|busybox awk {'print $2'}
}

ram_total=$(((`check_ram`-(1024))/(1024)))

# $TOOLS/timerun 600 $TOOLS/misc001 
$TOOLS/timerun 600 $TOOLS/misc001 $ram_total
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    del
    exit -1
fi
echo "Test Success."
del
exit 0
