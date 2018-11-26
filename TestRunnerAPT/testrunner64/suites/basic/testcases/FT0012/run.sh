#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0012
# Assertion: All little CPUs take part in a sched domain populated entirely by other little CPUs
TESTNAME="FT0012"
RESULT="1"
default_little_cpulist
HMPSLOWCPUS=$__RET
echo "The test framework thinks that the slow CPUs are $__RET"
cpustringtobitfield $HMPSLOWCPUS
HMPBITS=$__RET
for CPU in $HMPSLOWCPUS; do
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

