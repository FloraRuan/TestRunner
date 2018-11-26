#!/system/bin/sh
# test for enable/disable core_ctl

TESTNAME="FT0013"
mount=`mount | busybox grep -c "debugfs /data/debug"`
if [ $mount -eq 1 ]; then 
    umount /data/debug
fi
export TEST_ENV_SETUP=/data/kernel-tests/test_env_setup.sh
chmod -R 777 /data/kernel-tests/ 
cd /data/kernel-tests
chmod 755 cpuhotplug_test.sh
./cpuhotplug_test.sh
if [ $? -eq 0 ];then
    echo "$TESTNAME: Passed"
else
    echo "$TESTNAME Failed"
    exit 1
fi
