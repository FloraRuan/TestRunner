#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest10
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest10: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest10: Failure"
    removelogfiles
    exit 1
fi
