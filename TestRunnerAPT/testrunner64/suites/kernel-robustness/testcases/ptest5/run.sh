#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

# If we given negative number as a input to the bytes then the bytes 
#are printed instead of being executed
$TOOLS/crashme -100 666 100

if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi	
exit 0