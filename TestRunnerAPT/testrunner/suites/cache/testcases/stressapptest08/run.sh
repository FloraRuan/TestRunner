#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest8
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest8: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest8: Failure"
    removelogfiles
    exit 1
fi
