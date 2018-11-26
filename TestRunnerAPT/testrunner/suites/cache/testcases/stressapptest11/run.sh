#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest11
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest11: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest11: Failure"
    removelogfiles
    exit 1
fi
