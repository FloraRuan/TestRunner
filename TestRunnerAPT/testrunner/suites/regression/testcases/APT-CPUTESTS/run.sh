#!/system/bin/sh
# ./runner.sh cpufreq cpuhotplug cputopology cpuidle

export TOOLS='/data/local/tmp/testrunner/common'
source $TOOLS/functestlib.sh

disable_core_ctl

./runner.sh cpuhotplug cputopology cpuidle
