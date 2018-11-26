#!/system/bin/sh
# Running mq_notify/5-1 testcase from Open POSIX testsuite appears to lead to corrupted memory.
# This is later followed by various kernel crash/BUG messages.
source ../../../../init_env

for i in {1..10}
do 
	$TOOLS/mq-notify
	if [ "$?" -ne "0" ]; then
		echo "mw-notify test failure."
		exit -1
	fi
done

echo "mw-notify test Success."
exit 0