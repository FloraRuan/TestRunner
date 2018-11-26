#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest15
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest15: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest15: Failure"
    removelogfiles
    exit 1
fi
