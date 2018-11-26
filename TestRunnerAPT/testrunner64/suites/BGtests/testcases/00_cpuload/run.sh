#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

#import test functions library
source $SUITES/BGtests/funclib.sh

TESTNAME="CPULoad"
RESULT="1"
commandline_args=("$@")

screencap -p /sdcard/screencapTest.png   ### Take scrreencap for every 1 min
# logcatMessage "${commandline_args[$RandomTest]}" 0
# ${commandline_args[$RandomTest]}
${TESTNAME}
# logcatMessage "${commandline_args[$RandomTest]}" 1
if [ "$?" -eq "$__FALSE" ] ; then
  RESULT="0"
fi
if [ "$RESULT" != "0" ] ; then
  echo ""$TESTNAME Failed""
  exit 1
fi
echo ""$TESTNAME Passed""
exit 0
