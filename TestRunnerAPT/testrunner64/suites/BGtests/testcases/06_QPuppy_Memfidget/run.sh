#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

QPuppy_Memfidget
if [ "$?" -eq "0" ]; then
    echo "Test QPuppy_Memfidget: Success"
    exit 0
else
    echo "Test QPuppy_Memfidget: Failure"
    exit 1
fi
