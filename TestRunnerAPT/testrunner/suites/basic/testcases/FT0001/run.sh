#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0001
# Assertion: The scheduler has a CPU-level domain covering all CPUs
TESTNAME="FT0001"
RESULT="1"
getcpuarray
CPUSTRING=$__RET
echo "We have the following CPUs available: $CPUSTRING"
for CPU in $CPUSTRING; do
  getcpuscheddomainbitfield "$CPU"
  TMP="$__RET"
  echo "cpu$CPU sched_domain at CPU level covers CPUs 0x$TMP"
  for BIT in $CPUSTRING; do
    isbitsetinbitfield "$BIT" "$TMP"
    if [ "$?" -eq "$__FALSE" ] ; then
      RESULT="0"
      break 2
    fi
  done
done

if [ "$RESULT" != "1" ] ; then
  echo ""$TESTNAME Failed""
  exit 1
fi

echo ""$TESTNAME Passed""
exit 0

