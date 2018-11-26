#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# Import functions library
source $TOOLS/basics.sh
source $TOOLS/functestlib.sh

RTAPP=$TOOLS/rt-app

BIGTASK_RUNTIME_S=4

cpufreq_powersave() {
  BIGCPU=$1

  # Save current governors setup
  getcpufreqgovernors
  GOVERNORS=$__RET
  echo "Original governors setting:"
  echo $GOVERNORS

  echo "Calibrate big CPU$BIGCPU..."
  setgovernor_manual $BIGCPU "powersave"

  echo "Calibration target CPU setting:"
  grep "" /sys/devices/system/cpu/cpu$BIGCPU/cpufreq/scaling_governor
  grep "" /sys/devices/system/cpu/cpu$BIGCPU/cpufreq/scaling_cur_freq

}

cpufreq_restore() {
  # Recover previous governors setup
  setcpufreqgovernors $GOVERNORS
  getcpufreqgovernors
  GOVERNORS=$__RET
  echo "Recovered governors setting:"
  echo $GOVERNORS
}

rtapp_calibrate() {
  BIGCPU=$1

  # Calibrate RT-App on the big cpu
  sed "s/__CPU__/CPU$BIGCPU/" calibration.json.in > calibration.json
  CALIB=`$RTAPP calibration.json 2>&1 | \
    awk '/pLoad/{gsub(/ns/, "", $5); print $5; exit;}'`

  echo "RT-App calibration for CPU$BIGCPU: $CALIB"
  return $CALIB
}

rtapp_configure() {
  CALIB=$1

  # Conf: tasks header
  cat > bigtasks.json <<EOF
{
	"tasks": {
EOF

  # Conf: big tasks (one per available big core + 1)
  getbigcpulist
  I=0
  for CPUID in L $__RET; do
    let I++
    TASK_ID="rta_t$I"
    TASKS="$TASKS $TASK_ID"
    cat >> bigtasks.json <<EOF
		"$TASK_ID": {
			"loop": 1,
			"run": ${BIGTASK_RUNTIME_S}000000,
		},
EOF
  done

  # Compute expected big tasks runtime on LITTLE cpus
  # Time of a big task + (20% margin)
  MAX_LITTLE_TIME="$BIGTASK_RUNTIME_S.$(($BIGTASK_RUNTIME_S * 5))"

  # Conf: add global section with calibration value
  cat >> bigtasks.json <<EOF
	},
	"global": {
		"default_policy" : "SCHED_OTHER",
		"ftrace" : false,
		"gnuplot" : false,
		"logdir" : "/data/local/schedtest",
		"log_basename" : "rta_bigtasks",
		"lock_pages" : true,
		"calibration" : $CALIB
	},
}
EOF

}


# Calibrate RT-App on the first big CPU
getbigcpulist
for BIGCPU in $__RET; do
  break
done

# We are interested on scheduling behaviors, not performances.
# Thus we run the experiment capping big cluster to the minimum
# frequency, which allows to reduce thermal effects on the result
# of the experiment.

echo 'Switch to [powersave] governor'
cpufreq_powersave $BIGCPU

echo 'Calibrate RT-App on big CPUs'
rtapp_calibrate $BIGCPU

echo "Generate RT-App test configuration"
rtapp_configure $CALIB

echo "Start bigtasks workload..."
ftrace_start 0
$RTAPP bigtasks.json 2>&1
ftrace_stop 0

echo "Restore original CPUFreq configuration"
cpufreq_restore

TRACE_TASKS=$TASKS
getlittlecpumask
CPUS_MASK="0x$__RET"
TIME_MAX="$MAX_LITTLE_TIME"
ftrace_check_tasks

# Report tasks residencies on output (i.e. logfile)
cat tasks_residencies.txt

if [ $RESULT = 0 ] ; then
	echo "SUCCESS"
else
	echo "FAILED"
fi
exit $RESULT

