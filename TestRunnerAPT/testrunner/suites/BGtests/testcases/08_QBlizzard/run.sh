#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

QBlizzard
if [ "$?" -eq "0" ]; then
    echo "Test QBlizzard: Success"
    exit 0
else
    echo "Test QBlizzard: Failure"
    exit 1
fi
