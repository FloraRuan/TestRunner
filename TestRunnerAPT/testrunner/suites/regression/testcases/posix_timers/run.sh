#!/system/bin/sh
# Test posix timers
# Run the test
source ../../../../init_env

$TOOLS/posix_timers
if [ "$?" -ne "0" ]; then
	echo "posix_timers Failure."
	exit -1
fi
echo "posix_timers Success."
exit 0