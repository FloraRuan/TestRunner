#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

echo "Test main_pth_str03"
$TOOLS/regression output main_pth_str03
RESULT=$?
if [ "$RESULT" == "0" ] ; then
	echo SUCCESS
else
	echo FAILED
	RESULT=1
fi
exit $RESULT
