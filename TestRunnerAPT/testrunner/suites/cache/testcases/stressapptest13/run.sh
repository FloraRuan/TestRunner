#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest13
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest13: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest13: Failure"
    removelogfiles
    exit 1
fi
