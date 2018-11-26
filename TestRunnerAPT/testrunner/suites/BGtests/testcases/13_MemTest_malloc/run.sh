#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

MemTest_malloc
if [ "$?" -eq "0" ]; then
    echo "Test MemTest_malloc: Success"
    exit 0
else
    echo "Test MemTest_malloc: Failure"
    exit 1
fi
