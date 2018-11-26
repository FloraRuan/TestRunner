#!/system/bin/sh
# Test inserting a leap second
# Make sure we can run this test successfully

# source ../../utils/root-check.sh
source ../../../../init_env
source $TOOLS/functestlib.sh

check_root
is_root=$?
if [ "$is_root" -ne "0" ]; then
        exit 3
fi

# Run the test
# insert a leap second one time, and reset the time to within
# 10 seconds of midnight UTC.
$TOOLS/leap-a-day -s -i 1 | tee -a test.out
if [ "$?" -ne "0" ]; then
	echo "Test leap-a-day:Fail"
	exit -1
else
	echo "Test leap-a-day:Pass"
	exit 0
fi

