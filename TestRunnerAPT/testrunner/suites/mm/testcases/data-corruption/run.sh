#!/system/bin/bash
./data-corruption.sh images/boxes.ppm
if [ "$?" -eq "0" ]; then
    echo "Test data-corruption: Success"
    exit 0
else
    echo "Test data-corruption: Failure"
    exit 1
fi
