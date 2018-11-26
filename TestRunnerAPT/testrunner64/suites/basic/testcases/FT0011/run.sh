#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0011
# Assertion: The little CPUs calculated by the test framework are A7s/A53s
TESTNAME="FT0011"
RESULT="1"
default_little_cpulist
HMPSLOWCPUS=$__RET
echo "The test framework thinks that the slow CPUs are $__RET"
littlecore=`echo $HMPSLOWCPUS|busybox awk {'print $1'}`
CONFIG_TARGET_LITTLE_CPUPART=$( cpupart $littlecore )
LITTLECPUS=""
echo "We have the following CPUs available: $CPUSTRING"
for CPU in $HMPSLOWCPUS; do
  getcputype $CPU
  if [ "x$__RET" == "x$CONFIG_TARGET_LITTLE_CPUPART" ] ; then
    LITTLECPUS="$LITTLECPUS$CPU "
  fi
done

echo "CPUS $LITTLECPUS are the A7/A53 CPUs in this system"
cpustringtobitfield $HMPSLOWCPUS
HMPBITS=$__RET
cpustringtobitfield $LITTLECPUS
LITTLEBITS=$__RET

TEST=$(( (0x$HMPBITS) - (0x$LITTLEBITS) ))
if [ $TEST -ne 0 ] ; then
  RESULT=0
fi

if [ "$RESULT" != "1" ] ; then
  echo "$TESTNAME Failed"
  exit 1
fi

echo "$TESTNAME Passed"
exit 0

