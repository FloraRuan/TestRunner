#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $TOOLS/functestlib.sh


# FT0007
# Assertion: The big CPUs calculated by the test framework are A54s/A57s
TESTNAME="FT0007"
RESULT="1"
default_big_cpulist
HMPFASTCPUS=$__RET
echo "The test framework thinks that the fast CPUs are $__RET"
bigcore=`echo $HMPFASTCPUS|busybox awk {'print $1'}`
CONFIG_TARGET_BIG_CPUPART=$( cpupart $bigcore )
BIGCPUS=""
for CPU in $HMPFASTCPUS; do
  getcputype $CPU
  if [ "x$__RET" == "x$CONFIG_TARGET_BIG_CPUPART" ] ; then
    BIGCPUS="$BIGCPUS$CPU "
  fi
done

echo "CPUS $BIGCPUS are the A53/A57 CPUs in this system"
cpustringtobitfield $HMPFASTCPUS
HMPBITS=$__RET
cpustringtobitfield $BIGCPUS
BIGBITS=$__RET

TEST=$(( (0x$HMPBITS) - (0x$BIGBITS) ))
if [ $TEST -ne 0 ] ; then
  RESULT=0
fi

if [ "$RESULT" != "1" ] ; then
  echo "$TESTNAME Failed"
  exit 1
fi

echo "$TESTNAME Passed"
exit 0

