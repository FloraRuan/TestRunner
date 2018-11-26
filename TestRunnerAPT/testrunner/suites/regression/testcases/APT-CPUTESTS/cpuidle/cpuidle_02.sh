#!/system/bin/sh
# Run a cpuidle program killer

source ../include/functions.sh

CPUIDLE_KILLER="$TOOLS/cpuidle_killer"

check "cpuidle program runs successfully (120 secs)" "$CPUIDLE_KILLER"
test_status_show
