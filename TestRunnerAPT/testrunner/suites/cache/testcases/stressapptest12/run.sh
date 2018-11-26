#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest12
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest12: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest12: Failure"
    removelogfiles
    exit 1
fi
