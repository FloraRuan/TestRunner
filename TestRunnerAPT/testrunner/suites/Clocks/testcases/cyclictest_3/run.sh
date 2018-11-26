#!/system/bin/bash
# Import test suite definitions
source ../../../../init_env

#import test functions library
# source $SUITES/stress/funclib.sh
# Import functions library
source $TOOLS/functestlib.sh

################################################################
# 
# Cyclictest: Idle Run test
#

function func_freshHeadr()
{
	clear
	sleep 0.2
}

function func_CyHeader1(){
echo -e "Cyclictest: Hi-to-Low Priority Test"
}

# Start of (dislpayed) Script
func_freshHeadr
func_CyHeader1

echo -e "--------------------------------------------------------------------------------"
echo -e "    This test reduces priority with each run of cyclictest, giving an idea\n"
echo -e "    of not only what high-priority maximum latencies will be, but also what\n" 
echo -e "    low-prioriy maximum latencies tend to be.\n"

echo -e "    First (4) tests, have no load. ie: close any cpu hungry apps, please."
echo -e "--------------------------------------------------------------------------------"

echo -e "Starting no CPU load Test" 

# 1st Run
echo -e "cyclictest -n -m --smp -Sp98 -i100 -d0"
echo -e "Priority: fifo/98"
echo -e "press ctrl-c to terminate/end run."
timeout 5m $TOOLS/cyclictest -n -m --smp -Sp98 -i100 -d0

# 2nd Run 
echo -e "Priority: fifo/89"
echo -e "cyclictest -n -m --smp -Sp89 -i100 -d0"
echo -e "press ctrl-c to terminate/end run."
timeout 5m $TOOLS/cyclictest -n -m --smp -Sp89 -i100 -d0

# 3rd Run 
echo -e "cyclictest -n -m --smp -Sp75 -i100 -d0"
echo -e "Priority: fifo/75" 
echo -e "press ctrl-c to terminate/end run."
timeout 5m $TOOLS/cyclictest -n -m --smp -Sp75 -i100 -d0

# 4th Run 
echo -e "cyclictest -n -m --smp -Sp50 -i100 -d0"
echo -e "Priority: fifo/50" 
echo -e "press ctrl-c to terminate/end run."
timeout 5m $TOOLS/cyclictest -n -m --smp -Sp50 -i100 -d0

# 5th Run 
echo -e "cyclictest -n -m --smp -Sp25 -i100 -d0"
echo -e "Priority: fifo/25" 
echo -e "press ctrl-c to terminate/end run."
timeout 5m $TOOLS/cyclictest -n -m --smp -Sp25 -i100 -d0

killall -9 cyclictest

echo "Test passed"
exit 0
