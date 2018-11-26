#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0002
# Assertion: The scheduler has a CPU-level domain with load balancing turned off
TESTNAME="FT0002"
RESULT="1"
getcpuarray
CPUSTRING=$__RET
echo "We have the following CPUs available: $CPUSTRING"
for CPU in $CPUSTRING; do
  getcpuscheddomainflags "$CPU"
  TMP="$__RET"
  if [ "${#TMP}" -eq 0 ] ; then
    echo "Unable to get sched_domain flags on this platform."
    RESULT="0"
    break
  fi
  getprintableschedflags "$TMP"
  echo "cpu$CPU sched_domain at CPU level has flags 0x$TMP : $__RET"
  isbitsetinbitfield "$SD_LOAD_BALANCE" "$TMP"
  if [ "$?" -eq "$__TRUE" ] ; then
    RESULT="0"
    break
  fi
done

if [ "$RESULT" != "1" ] ; then
  echo "$TESTNAME Failed"
  exit 1
fi

echo "$TESTNAME Passed"
exit 0

