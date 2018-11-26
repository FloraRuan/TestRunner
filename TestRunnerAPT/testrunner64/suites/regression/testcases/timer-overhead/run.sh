#!/system/bin/sh
#
source ../../../../init_env

$TOOLS/timer-test
if [ "$?" -ne "0" ]; then
	echo "Test failure."
	exit -1
fi
