#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

$TOOLS/crashme 0 666 10 > alarm_logs.txt 2>&1
if [ $? -eq 0 ]; then
	echo "Test Passed"
	ALARM=$(cat alarm_logs.txt | grep alarm | head -n 1 |  awk '{print $3}')
	echo "Got alarm signal $ALARM"
	rm -rf alarm_logs.txt
else
	echo "Test failed"
fi	
exit 0
