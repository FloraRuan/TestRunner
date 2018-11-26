#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

MemoryLoad
if [ "$?" -eq "0" ]; then
    echo "Test MemoryLoad: Success"
    exit 0
else
    echo "Test MemoryLoad: Failure"
    exit 1
fi
