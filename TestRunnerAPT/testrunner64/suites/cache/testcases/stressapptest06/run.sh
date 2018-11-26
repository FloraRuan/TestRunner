#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest6
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest6: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest6: Failure"
    removelogfiles
    exit 1
fi
