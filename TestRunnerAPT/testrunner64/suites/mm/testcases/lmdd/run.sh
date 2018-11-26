#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
if [ ! -f /data/local/tmp/hello ]; then
    touch /data/local/tmp/hello
    chmod 777 /data/local/tmp/hello
fi
cdir=`pwd`
# Make sure we can find: ./cmd, df, and netstat
PATH=.:$TOOLS:$PATH:/etc:/usr/etc:/sbin:/usr/sbin
export PATH

sh lmbench $cdir/runlmbench
#killing lat_cmd as part of cleanup
chk=`ps|grep -c lat_cmd`
if [ $chk -gt 0 ]; then 
    busybox killall lat_cmd
fi




