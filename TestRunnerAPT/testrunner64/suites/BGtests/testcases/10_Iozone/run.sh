#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

Iozone
if [ "$?" -eq "0" ]; then
    echo "Test Iozone: Success"
    exit 0
else
    echo "Test Iozone: Failure"
    exit 1
fi
