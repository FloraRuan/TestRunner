#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest14
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest14: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest14: Failure"
    removelogfiles
    exit 1
fi
