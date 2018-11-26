#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#To-do:$TOOLS/timerun 600 $eachworkload
source $TOOLS/functestlib.sh

fillmem
get_vmsize
VM=$__RET
$TOOLS/timerun 600 $TOOLS/memory-stressor $VM
echo "Test Success."
exit 0




