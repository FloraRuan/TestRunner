
# Import test suite definitions
source ../../../../init_env

. $TOOLS/functestlib.sh

PACKING='/sys/kernel/hmp/packing_enable'

probe_for_small_task_packing(){
  if [ ! -f $PACKING ]; then
     echo "Small task Packing is not supported in the kernel!"
     exit 1
  fi
}

enable_small_task_packing(){
 __packing_default_state=$( cat "/sys/kernel/hmp/packing_enable" )
 echo "default_packing_state is $__packing_default_state"
 echo "1" > "/sys/kernel/hmp/packing_enable"
 local val=$( cat "/sys/kernel/hmp/packing_enable" )
 if [ $val -eq 0 ]; then
   echo "Write error: Could not write to 'packing_enable'"
   exit 1
 fi
 echo "Updated packing_state is $val"
 sleep 2
}

set_packing_limit(){
__packing_default_limit=$( cat "/sys/kernel/hmp/packing_limit" )
 echo "$1" > "/sys/kernel/hmp/packing_limit"
 echo "default packing limit is $__packing_default_limit"
 local val=$( cat "/sys/kernel/hmp/packing_limit" )
 if [ $val != "$1" ]; then
   echo "Write error: Could not update 'packing_limit'"
   exit 1
 fi
 echo "Updated packing_limit is $val"
 sleep 2
}

restore_small_task_packing_state(){
 echo "$__packing_default_state" > "/sys/kernel/hmp/packing_enable"
}

restore_packing_limit(){
 echo "$__packing_default_limit" > "/sys/kernel/hmp/packing_limit"
}
