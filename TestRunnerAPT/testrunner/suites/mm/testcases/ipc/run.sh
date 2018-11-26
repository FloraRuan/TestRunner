#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
source $TOOLS/functestlib.sh

fillmem

segs=128
size=1024
proc=/data
iter=100
# usage: icp001 segs size proc iter rm%
$TOOLS/ipc001 $segs $size $proc $iter rm%
if [ "$?" -ne "0" ]; then
    echo "Test failure."
    exit -1
fi
echo "Test Success."
exit 0




