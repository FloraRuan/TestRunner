#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

cache_coherency
if [ "$?" -eq "0" ]; then
    echo "Test cache_coherency: Success"
    exit 0
else
    echo "Test cache_coherency: Failure"
    exit 1
fi
