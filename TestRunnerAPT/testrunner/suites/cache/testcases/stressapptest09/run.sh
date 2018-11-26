#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest9
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest9: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest9: Failure"
    removelogfiles
    exit 1
fi