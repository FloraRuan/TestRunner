#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
# Import functions library
source $TOOLS/functestlib.sh

UINTMAX=4294967295
COUNTS=( 500000000 1000000000 1500000000 2000000000 2500000000 3000000000 3500000000 $UINTMAX)
N=( 1 2 3 4 5)

# Run primePThread output for first 1 million primes
$TOOLS/primePThread -m 1000000 > my_primes_t.txt
echo "primePThread validated for first 1 million primes"
rm my_primes_t.txt

# Validate primeMProc output for first 1 million primes against test file
$TOOLS/primeMProc -m 1000000 > my_primes_p.txt
echo "primePThread validated for first 1 million primes"
rm my_primes_p.txt

# Collect timing numbers for primePThread:
touch thread_timing.txt
for i in ${N[@]}  # 1 - 5 threads
do	
	# for varying sizes of m
	for m in ${COUNTS[@]}
	do
		echo "Running primePThread with $i threads and $m as a max..."
		
		exec 3>&1 4>&2
		output=$( { time $TOOLS/primePThread -q -m $m -c $i 1>&3 2>&4; } 2>&1 ) 
		exec 3>&- 4>&-
		
		#get everything to the right of first "*user "
		user=${output#*user }
		echo $user
		#get everything to the left of the first "s*"
		user=${user%%s*}
		echo $user
		#get everythig to let left of "m*"
		min=${user%%m*}
		echo $min
		#get everything to the right of "*m" and left of ".*"
		sec=${user#*m}
		sec=${sec%%.*}
		echo $sec
		#get everything to the right of "*."
		usec=${user#*.}	
		c="$i, $m, $usec" 
		echo $c
		echo "$c" >> thread_timing.txt	

	done
done

# Collect timing numbers for primeMProc:
touch proc_timing.txt
for i in ${N[@]}   # 1 - 5 threads
do	
	# for varying sizes of m
	for m in ${COUNTS[@]}
	do		
		exec 3>&1 4>&2
		output=$( { time $TOOLS/primeMProc -q -m $m -c $i 1>&3 2>&4; } 2>&1 )
		exec 3>&- 4>&-

		#get everything to the right of first "*user "
		user=${output#*user }
		echo $user
		#get everything to the left of the first "s*"
		user=${user%%s*}
		echo $user
		#get everythig to let left of "m*"
		min=${user%%m*}
		echo $min
		#get everything to the right of "*m" and left of ".*"
		sec=${user#*m}
		sec=${sec%%.*}
		echo $sec
		#get everything to the right of "*."
		usec=${user#*.}
		c="$i, $m, $usec"
		echo $c
		echo "$c" >> proc_timing.txt
	done
done
