#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

# If we given a  time hrs:mns:scs (hours, minutes, seconds) then
#one subprocess will be run to completion, followed by another, 
#until the time limit has been reached
$TOOLS/crashme +256 666 100 00:00:05 4

if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi	
exit 0

