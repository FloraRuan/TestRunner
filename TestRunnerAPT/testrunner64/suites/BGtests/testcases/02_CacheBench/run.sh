#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

CacheBench
if [ "$?" -eq "0" ]; then
    echo "Test CacheBench: Success"
    exit 0
else
    echo "Test CacheBench: Failure"
    exit 1
fi
