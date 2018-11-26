#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

source $TOOLS/functestlib.sh

fillmem

size=256
c=1
while [ $c -le 50 ]
do
    $TOOLS/glom $size
    (( c++ ))
done
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0




