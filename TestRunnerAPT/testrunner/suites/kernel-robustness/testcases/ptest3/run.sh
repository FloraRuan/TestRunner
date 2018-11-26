#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh

#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

# 100 bytes of random data string and passing 666 & 667 to random number generator 
# with  100 tries before exiting

$TOOLS/crashme 100 666 100
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi	
$TOOLS/crashme 100 667 100
if [ $? -eq 0 ]; then
	echo "Test passed"
else
	echo "Test failed"
fi
exit 0
