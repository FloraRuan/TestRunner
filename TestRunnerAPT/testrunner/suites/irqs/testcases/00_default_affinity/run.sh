#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# Import functions library
source $TOOLS/functestlib.sh

DEFAULT_AFFINITY_FILE=/proc/irq/default_smp_affinity

if [ ! -f $DEFAULT_AFFINITY_FILE ]; then
  echo "Missing default affinity file [$DEFAULT_AFFINITY_FILE]"
  echo "Test aborted"
  exit 2
fi

getbigcpumask
BIGS_MASK="0x$__RET"
BIGS_MASK_DEC=`printf "%d" $BIGS_MASK`
echo "big CPUs mask: $BIGS_MASK"

DEFAULT_AFFINITY="0x`cat /proc/irq/default_smp_affinity`"
DEFAULT_AFFINITY_DEC=`printf "%d" $DEFAULT_AFFINITY`
echo "default affinity mask: $DEFAULT_AFFINITY"

IRQS_ON_BIGS=$((BIGS_MASK_DEC & DEFAULT_AFFINITY_DEC))
if [ $IRQS_ON_BIGS -ne 0 ]; then
  echo "ERROR: default IRQ mask [$DEFAULT_AFFINITY] includes big CPUs"
  echo "Test failed"
  exit 1
fi

echo "Test Passed"
exit 0

