#!/system/bin/bash
./cache-coherency-switcher.sh -f big -c 1 -c 2 -s 70
if [ "$?" -eq "0" ]; then
    echo "Test cache-coherency-switcher: Success"
    exit 0
else
    echo "Test cache-coherency-switcher: Failure"
    exit 1
fi
