#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0008
# Assertion: All big CPUs take part in a sched domain populated entirely by other big CPUs
TESTNAME="FT0008"
RESULT="1"
default_big_cpulist
HMPFASTCPUS=$__RET
echo "The test framework thinks that the fast CPUs are $__RET"
cpustringtobitfield $HMPFASTCPUS
HMPBITS=$__RET
for CPU in $HMPFASTCPUS; do
  getpackagescheddomainbitfield "$CPU"
  echo "cpu$CPU sched_domain at MC level covers CPUs 0x${__RET}."
  TEST=$(( (0x${__RET}) - (0x${HMPBITS}) ))
  if [ $TEST -ne 0 ] ; then
    RESULT=0
    break
  fi
done


if [ "$RESULT" != "1" ] ; then
  echo "$TESTNAME Failed"
  exit 1
fi

echo "$TESTNAME Passed"
exit 0

