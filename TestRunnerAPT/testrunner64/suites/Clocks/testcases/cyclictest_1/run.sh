#!/system/bin/bash
# Import test suite definitions
source ../../../../init_env

#import test functions library
# Import functions library
source $TOOLS/functestlib.sh
# Usage: cyclictest_run [iteration] > histogram_file

NLOOPS=$(awk 'BEGIN{srand();print int(rand()*(10000-2000))+2000 }')

if [ $NLOOPS -gt 0 ]; then
	NLOOPS="-l $NLOOPS"
fi

CPUS=$(ls /sys/devices/system/cpu | busybox grep "cpu[0-9].*" |awk  '{ printf( "%s ", $1 ); } END { printf( "\n" ); }')
echo "#" `cat /proc/cpuinfo | grep Processor | awk '{print $3 " " $4}' `
echo "# CPUS: " $CPUS
echo "# Kernel: " `uname -rvm | cut -c 0-7`
echo "# Iterations" $NLOOPS

$TOOLS/chrt -f 80 time $TOOLS/cyclictest -n -q -p 99 -a -t -i 250 -h 1000 -m $NLOOPS
if [ $? -eq 0 ];then 
    echo "cyclictest: Passed"
else
    echo "cyclictest: Failed"
fi
