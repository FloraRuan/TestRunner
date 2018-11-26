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

#CRASHPRNG is a new environment variable letting you change the pseudorandom number generator used.
sh -c CRASHPRNG=MT;export CRASHPRNG;$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/crashme-prng_mt.log
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi	
sh -c CRASHPRNG=RAND;export CRASHPRNG;$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/crashme-prng_rand.log
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
sh -c CRASHPRNG=VNSQ;export CRASHPRNG;$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/crashme-prng_vnsq.log
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=RAND
export CRASHPRNG
$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/CRASHME-PRNG_RAND.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=MT
export CRASHPRNG
$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/CRASHME-PRNG_MT.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=VNSQ
export CRASHPRNG
$TOOLS/crashme -64 666 5 -15 3 > $LOG_DIR/CRASHME-PRNG_VNSQ.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=MT
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:00:30 3 > $LOG_DIR/crashme-TEST1-MT.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=RAND
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:00:30 3 > $LOG_DIR/crashme-TEST1-RAND.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=VNSQ
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:00:30 3 > $LOG_DIR/crashme-TEST1-VNSQ.LOG
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=MT
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:05:00 2
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=RAND
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:05:00 2
if [ $? -ne 0 ]; then
	echo "Test failed"
	exit 0
fi
CRASHPRNG=VNSQ
export CRASHPRNG
$TOOLS/crashme 8192 666 100 00:05:00 2
if [ $? -eq 0 ]; then
	echo "Test Passed"
else
	echo "Test failed"
fi
exit 0