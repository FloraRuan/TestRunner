#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

check_userspace_exists()
{
RET="0"
for I in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors` ; do
  if [ "${I}" == "userspace" ] ; then
    RET="1"
  fi
  echo "${I}"
done
}

echo "scalinv0002: Check for userspace governor"
echo "Governors available in this kernel for CPU0 are:"
check_userspace_exists
OVERALL_RESULT=${RET}


if [ ${OVERALL_RESULT} != 1 ] ; then
  echo "userspace not found in list of available governors"
  echo "Test FAILED"
  exit 1
else
  echo "userspace found in list of available governors"
  echo "Test PASSED"
  exit 0
fi

