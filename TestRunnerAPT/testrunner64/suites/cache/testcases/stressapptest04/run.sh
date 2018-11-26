#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest4
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest4: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest4: Failure"
    removelogfiles
    exit 1
fi
