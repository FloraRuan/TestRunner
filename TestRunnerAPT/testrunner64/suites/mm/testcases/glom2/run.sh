#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
source $TOOLS/functestlib.sh

fillmem

size=256

$TOOLS/timerun 600 $TOOLS/glom2 $size
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0




