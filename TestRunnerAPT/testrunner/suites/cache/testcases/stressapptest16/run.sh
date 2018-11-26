#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest16
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest16: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest16: Failure"
    removelogfiles
    exit 1
fi
