#!/system/bin/sh
# Import test suite definitions
tmpfile="testing_file"

source ../../../../init_env
# Problems doing the lseek:Invalid argument
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
    cat /proc/meminfo|busybox grep "Active:"|busybox awk {'print $2'}
}

ram_active=$(((`check_ram`)/(1024)))

$TOOLS/mmap002 $ram_active
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0
