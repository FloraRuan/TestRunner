#!/system/bin/bash

# Source the common functions for the test cases
source ../../functions.sh

stressapptest3
if [ "$?" -eq "0" ]; then
    echo "Test stressapptest3: Success"
    removelogfiles
    exit 0
else
    echo "Test stressapptest3: Failure"
    removelogfiles
    exit 1
fi
