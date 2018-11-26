#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

. ../../non_functional_script.sh
echo "Large task pool for HMP migration for at least 10 Hours"
# Stop all android services
if [ $ANDROID -eq 1 ]; then
	stop
fi


#Start + 10hours
get_time
START=$RESULT
let END=$RESULT+36000


while [ $RESULT -le $END ] ; do
	$SHELL_CMD ../stress_test_scn01.1/run.sh
	get_time
done
echo SUCCESS
exit 0
