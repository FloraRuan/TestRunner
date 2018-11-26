#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

echo "Test affinity_notchanged"
$TOOLS/regression output affinity_notchanged
RESULT=$?
if [ "$RESULT" == "0" ] ; then
	echo SUCCESS
else
	echo FAILED
	RESULT=1
fi
exit $RESULT
