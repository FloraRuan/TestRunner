#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

RESULT="1"
TYPES="CPULoad CacheBench MemoryLoad sysBench_FileIO QPuppy_Memwatch QPuppy_Memfidget QPuppy_Cacheblast QBlizzard cache_coherency Iozone sysBench_CPU ICache MemTest_malloc Brute_force"
for s in ${TYPES}
do
	echo  "test: $s"
	${s}
	if [ "$?" -eq "$__FALSE" ] ; then
		RESULT="0"
	fi
	if [ "$RESULT" != "0" ] ; then
		echo ""$TESTNAME Failed""
	fi
	echo ""$TESTNAME Passed""
done
