#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

ICache
if [ "$?" -eq "0" ]; then
    echo "Test ICache: Success"
    exit 0
else
    echo "Test ICache: Failure"
    exit 1
fi
