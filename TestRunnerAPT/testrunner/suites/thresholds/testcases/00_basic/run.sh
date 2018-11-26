#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# Migration thresolds sysfs attributes
UTFILE=/proc/sys/kernel/sched_upmigrate
DTFILE=/proc/sys/kernel/sched_downmigrate

echo
echo "Migration thresholds configuration:"
UP_UPMIGRATE=`cat $UTFILE`
DW_DOWNMIGRATE=`cat $DTFILE`
echo "  up_upmigrate   : $UP_UPMIGRATE"
echo "  down_threshold : $DW_DOWNMIGRATE"

RESULT="0"

echo
echo "Checking for thresholds boundaries..."
if [ $UP_UPMIGRATE -ge 1023 ]; then
  echo "  ERROR: Up migration threshold saturated!"
  echo "         Must be < 1023"
  RESULT=1
fi
if [ $DW_DOWNMIGRATE -le 0 ]; then
  echo "  ERROR: Down migration threshold saturated!"
  echo "         Must be > 0"
  RESULT=1
fi

echo
echo "Checking for thresholds invertion..."
if [ $UP_UPMIGRATE -le $DW_DOWNMIGRATE ]; then
  echo "  ERROR: Migration thresholds invertion!"
  echo "         up_migration must be > down_migration"
  RESULT=1
fi

echo
if [ $RESULT = 0 ] ; then
  echo "SUCCESS"
else
  echo "FAILED"
fi
exit $RESULT

