#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

Brute_force
if [ "$?" -eq "0" ]; then
    echo "Test Brute_force: Success"
    exit 0
else
    echo "Test Brute_force: Failure"
    exit 1
fi
