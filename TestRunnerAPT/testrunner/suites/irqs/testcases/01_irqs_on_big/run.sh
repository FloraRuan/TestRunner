#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env

# Import functions library
source $TOOLS/functestlib.sh

IRQS_DIR=/proc/irq

if [ ! -d $IRQS_DIR ]; then
  echo "Missing IRQs folder [$IRQS_DIR]"
  echo "Test aborted"
  exit 2
fi

getbigcpumask
BIGS_MASK="0x$__RET"
BIGS_MASK_DEC=`printf "%d" $BIGS_MASK`
echo "big CPUs mask: $BIGS_MASK"

rm -f irqs_on_big_cpus.txt 2>/dev/null
echo "IRQs routed on big CPUs:"
grep "" /proc/irq/*/smp_affinity | grep -v ":0f$" | \
sed -e 's/:/\//' | awk -F'/' '{print $4" "$6}' | \
while read IRQ MASK; do
  IRQ_MASK_DEC=`printf "%d" "0x$MASK"`
  IRQ_ON_BIGS=$(($BIGS_MASK_DEC & IRQ_MASK_DEC))
  [[ $IRQ_ON_BIGS -eq 0 ]] && continue
  IRQ_DESC=$(grep "^[ ]*$IRQ:" /proc/interrupts | awk '{print $10" "$11}')
  printf " %6d: (0x%04X) %-64s\n" "$IRQ" "$IRQ_MASK_DEC" "$IRQ_DESC" \
    >> irqs_on_big_cpus.txt
done

if [ -f irqs_on_big_cpus.txt ]; then
  cat irqs_on_big_cpus.txt
  echo "WARNING: Some IRQ are routed on big CPUs"
  echo "Test failed"
  exit 3
fi

echo "Test Passed"
exit 0

