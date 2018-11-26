#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

sysBench_CPU
if [ "$?" -eq "0" ]; then
    echo "Test sysBench_CPU: Success"
    exit 0
else
    echo "Test sysBench_CPU: Failure"
    exit 1
fi
