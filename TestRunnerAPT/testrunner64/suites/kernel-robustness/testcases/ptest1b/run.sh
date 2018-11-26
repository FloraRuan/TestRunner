#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 
LOG_DIR=/data/local/tmp/CRASHME-LOGS
mkdir -p $LOG_DIR
# If we given a  time hrs:mns:scs (hours, minutes, seconds) then
#one subprocess will be run to completion, followed by another, 
#until the time limit has been reached

sh -c CRASHPRNG=MT;export CRASHPRNG;CRASHLOG=$(LOG_DIR)/crashme-test1-mt.log;export CRASHLOG;$TOOLS/crashme 8192 666 100 00:00:30 3
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
sh -c CRASHPRNG=RAND;export CRASHPRNG;CRASHLOG=$(LOG_DIR)/crashme-test1-rand.log;export CRASHLOG;$TOOLS/crashme 8192 666 100 00:00:30 3
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
sh -c CRASHPRNG=VNSQ;export CRASHPRNG;CRASHLOG=$(LOG_DIR)/crashme-test1-vnsq.log;export CRASHLOG;$TOOLS/crashme 8192 666 100 00:00:30 3
if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi
exit 0