#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 
LOG_DIR=/data/local/tmp/CRASHME-LOGS
mkdir -vp $LOG_DIR
sh -c CRASHPRNG=RAND;export CRASHPRNG;CRASHLOG=$LOG_DIR/crashme-ptest4.log;export CRASHLOG;$TOOLS/crashme 100 666 100

if [ $? -eq 0 ]; then
	echo "Test passed"
else
	echo "Test failed"
fi
exit 0	
