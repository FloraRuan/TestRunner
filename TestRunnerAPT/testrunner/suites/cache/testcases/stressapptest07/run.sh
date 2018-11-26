#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest7
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest7: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest7: Failure"
    removelogfiles
    exit 1
fi
