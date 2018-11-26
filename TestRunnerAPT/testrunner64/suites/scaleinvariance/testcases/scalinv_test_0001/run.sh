#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# check if the sysfs knobs are in place to turn invariance off
if [ -e "/sys/kernel/hmp/scale_invariant_load" ] ; then
  echo "Prototype HMP-based frequency invariance is present and controllable"
else
  echo "Prototype HMP-based frequency invariance NOT present and controllable"
fi
if [ -e "/sys/devices/system/cpu/cpu0/topology/enable_scaled_cpupower" ] ; then
  echo "Prototype CPU-Power based scale and frequency invariance is present and controllable"
else
  echo "Prototype CPU-Power based scale and frequency invariance NOT present and controllable"
fi


echo "This test always passes, for info only"
echo "Test PASSED"
exit 0


