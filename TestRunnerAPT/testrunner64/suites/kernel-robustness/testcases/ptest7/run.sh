#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

# If we given bytes with an explicit plus sign then the storage for the 
# bytes is freshly malloc'ed each time. This can have an effect 
# on machines with seperate I and D cache mechanism

$TOOLS/crashme +256 666 10 3

if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi	
exit 0



