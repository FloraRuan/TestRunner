#!/system/bin/sh
# Test the memfd mechanism
# Run the test
source ../../../../init_env

$TOOLS/memfd_test
if [ "$?" -ne "0" ]; then
	echo "memfd_test:Fail"
	exit -1
fi
echo "memfd_test:Pass"
exit 0