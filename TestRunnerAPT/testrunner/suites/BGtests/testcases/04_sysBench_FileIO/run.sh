#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

sysBench_FileIO
if [ "$?" -eq "0" ]; then
    echo "Test sysBench_FileIO: Success"
    exit 0
else
    echo "Test sysBench_FileIO: Failure"
    exit 1
fi
