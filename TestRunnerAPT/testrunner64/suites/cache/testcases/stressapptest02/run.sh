#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest2
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest2: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest2: Failure"
    removelogfiles
    exit 1
fi