#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

QPuppy_Memwatch
if [ "$?" -eq "0" ]; then
    echo "Test QPuppy_Memwatch: Success"
    exit 0
else
    echo "Test QPuppy_Memwatch: Failure"
    exit 1
fi
