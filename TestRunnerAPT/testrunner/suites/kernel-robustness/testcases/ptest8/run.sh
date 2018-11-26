#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

#Running the test with 3 vfork subprocesses all at once and verbose level with 4s
$TOOLS/crashme +256 666 10 3 4

if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi	
exit 0

