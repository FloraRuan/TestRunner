#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
#CRASHME: Random input testing and this script tests the operating 
#environment's robustness by invoking random data 

#Invoking file with many calls to crashme
$TOOLS/crashme 1020 234 500 &
$TOOLS/crashme 394 38484 5723 &
$TOOLS/crashme 3784 474 474 &
$TOOLS/crashme 437 4747 38 &
$TOOLS/crashme 47848 4745 123 &
$TOOLS/crashme 4747 4747 3463 &
$TOOLS/crashme 474 46464 262 &
$TOOLS/crashme 37 3644 3723 &
$TOOLS/crashme 374 46464 22 &
$TOOLS/crashme 3747 464 363 &
$TOOLS/crashme 347 4747 44 &
$TOOLS/crashme 37374 374 66 &
$TOOLS/crashme 3737 474 4444 &
$TOOLS/crashme +2000 666 50 00:20:00
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
$TOOLS/crashme +1000.48 0 100 03:00:00 2
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
$TOOLS/crashme +1000 666 50 12:00:00 3
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
$TOOLS/crashme +1000 24131 50
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
$TOOLS/crashme +2000 666 50 00:30:00 2
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
$TOOLS/crashme +2000 666 100 1:00:00
if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi	
exit 0