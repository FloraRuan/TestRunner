#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

echo "Test pipe_test_1m"
$TOOLS/regression output pipe_test_1m
RESULT=$?
if [ "$RESULT" == "0" ] ; then
	echo SUCCESS
else
	echo FAILED
	RESULT=1
fi
exit $RESULT
