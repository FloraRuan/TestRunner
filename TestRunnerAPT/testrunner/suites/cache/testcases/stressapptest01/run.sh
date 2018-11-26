#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest1
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest1: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest1: Failure"
    removelogfiles
    exit 1
fi
