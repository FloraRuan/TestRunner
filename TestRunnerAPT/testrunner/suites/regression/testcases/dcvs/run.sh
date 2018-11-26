#!/system/bin/sh
#######################################################################################################################
#                                                                                                                     #
#                                                cpufg_test.sh                                                        #
#                                                      v1.0                                                           #
#                                            InDev as of May 03, 2016                                                 #
#                                    Developed for Qualcomm QTI QCT QST Linux APT                                     #
#                                   By Nathaniel Haron (c_nharon@qualcomm.qti.com)                                    #
#                                                                                                                     #
#      ---------------------------------------------------------------------------------------------------------      #
#                                                                                                                     #
#              Tests general rules compliance for node values in Android/Linux CPU Frequency governor core            #
#	                > Out-of-bounds rules for minimum and maximum frequencies                                         #
#	                > Random and garbage value assignments to nodes                                                   #
#	                > Max cannot be set below Min or Min above Max                                                    #
#                                                                                                                     #
#              Tests cluster synchronization in Android/Linux CPU Frequency governor core                             #
#                   > Test for synchronicity in node values within each cluster                                       #
#                                                                                                                     #
#	           Tests the operation of the 'Performance' governor in Android/Linux CPU Frequency governor core         #
#	                > Verify frequency relationship behavior                                                          #
#                                                                                                                     #
#              Tests the operation of the 'Interactive' governor in Android/Linux CPU Frequency governor core         #
#                   > Test 'Interactive' governor nodes for expected values                                           #
#                   > Verify frequency relationship behavior                                                          #
#                                                                                                                     #
#      ---------------------------------------------------------------------------------------------------------      #
#                                                                                                                     #
#              Confidential and Proprietary – Qualcomm Technologies, Inc.                                             #
#              This technical data may be subject to U.S. and international export, re-export, or transfer            #
#              ("export") laws. Diversion contrary to U.S. and international law is strictly prohibited.              #
#                                                                                                                     #
#              Restricted Distribution: Not to be distributed to anyone who is not an employee of either              #
#              Qualcomm or its subsidiaries without the express approval of Qualcomm’s Configuration                  #
#              Management.                                                                                            #
#                                                                                                                     #
#              © 2016 Qualcomm Technologies, Inc                                                                      #
#                                                                                                                     #
#######################################################################################################################


#######################################################################################################################
####################################################   Variables   ####################################################
#######################################################################################################################
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh

# global return value
__RET=""

brave=1												#Flag to continue on failure
verbose=1											#Flag to output all information

working_path=/sys/devices/system/cpu                #Primary paths where the magic happens

default_little_cpulist
default_lil_index=$(echo $__RET|busybox awk {'print $1'})	#Standard number of the first cpu in the little cluster
default_big_cpulist
default_big_index=$(echo $__RET|busybox awk {'print $1'})		        #Standard number of the first cpu in the big cluster
default_governer="interactive"						#Governer to reset to between tests

default_2_2_passes=10
default_3_2_passes=10
default_4_2_passes=10
default_4_3_passes=10

exceptions=",boostpulse,"							#Governer nodes not to be used

#######################################################################################################################
####################################################   Functions   ####################################################
#######################################################################################################################

main(){
	SUCCESS=0
	prepare_setup
	# parse_input "$@"
	run_testing
    if [ "$fails_1_1" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_2_1" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_2_2" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_3_1" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_3_2" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_4_1" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_4_2" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	elif [ "$fails_4_3" -ne "0" ]; then
		SUCCESS=$((SUCCESS + 1))
	fi
	if [ "$SUCCESS" -ne "0" ]; then
		echo "DCVS TEST:FAIL"
		exit 1
	else
		echo "DCVS TEST:PASS"
		exit 0
	fi
}

###################################################    Toolbox    #####################################################

failure(){
	type tput &>/dev/null && [ -t 2 ] && failure(){				#If tput is defined and we are printing to terminal
		[ $(tput colors) -eq 8 ] && >&2 echo -n -e "\e[31m"			#If color is supported, set to red.
		[ $(tput colors) -ge 16 ] && >&2 echo -n -e "\e[91m"		#If many colors are supported, set to bright red.
		statement="[`date +%M:%S`] Failure: ${*^}"					#Add timestamp, capitalize first char
		>&2 echo "${statement::`tput cols`}"						#Print up to tput cols(terminal width)
		statement="${statement:`tput cols`}"						#Remove what we have already printed
		while [ ${#statement} != 0 ] && [ `tput cols` -ge 18 ]; do	#While there is still text and space to print it
			>&2 echo "                  ${statement::$((`tput cols` - 18))}"	#Print the next chunk 
			statement="${statement:$((`tput cols` - 18))}"						#Remove what we just printed
		done																	#(with whitespace to line it up)
		[ $(tput colors) -ge 8 ] && >&2 echo -n -e "\e[0m"			#If colors were supported, reset
		[ $brave ] || exit 1
	} || failure(){
		>&2 echo "[`date +%M:%S`] Failure: ${*}"				#If we are printing to file or ash, just print
		[ $brave ] || exit 1									# Exit if we are not brave
	}
	failure "$*"							
}

warning(){
	type tput &>/dev/null && [ -t 1 ] && warning(){
		[ $(tput colors) -eq 8 ] && echo -n -e "\e[33m"		#If color is supported, set to yellow.
		[ $(tput colors) -ge 16 ] && echo -n -e "\e[93m"	#If many colors are supported, set to bright yellow. 
		statement="[`date +%M:%S`] Warning : ${*^}"
		echo "${statement::`tput cols`}"
		statement="${statement:`tput cols`}"
		while [ ${#statement} != 0 ] && [ `tput cols` -ge 18 ]; do
			echo "                  ${statement::$((`tput cols` - 18))}"
			statement="${statement:$((`tput cols` - 18))}"
		done
		[ $(tput colors) -ge 8 ] && echo -n -e "\e[0m"
	
	} || warning() {
		echo "[`date +%M:%S`] Warning: ${*}"
	}
	warning "$*"
}

comment(){
	type tput &>/dev/null && [ -t 1 ] && comment(){
			if [ $verbose ]; then
				statement="[`date +%M:%S`] Comment : ${*^}"
				echo "${statement::`tput cols`}"
				statement="${statement:`tput cols`}"
				while [ ${#statement} != 0 ] && [ `tput cols` -ge 18 ]; do
					echo "                  ${statement::$((`tput cols` - 18))}"
					statement="${statement:$((`tput cols` - 18))}"
				done
			fi
	} || comment() {
		[ $verbose ] && echo "[`date +%M:%S`] Comment: ${*}"
	}
	comment "$*"
}

header(){
	type tput &>/dev/null && [ -t 1 ] && header(){
			statement="\n[`date +%M:%S`]          ${*^}"
			echo "${statement::`tput cols`}"
			statement="${statement:`tput cols`}"
			while [ ${#statement} != 0 ] && [ `tput cols` -ge 18 ]; do
				echo "                  ${statement::$((`tput cols` - 18))}"
				statement="${statement:$((`tput cols` - 18))}"
			done
	} || header() {
		echo "\n[`date +%M:%S`]          ${*}"
	}
	header "$*"
}

success(){
	type tput &>/dev/null && [ -t 1 ] && success(){
		[ $(tput colors) -eq 8 ] && echo -n -e "\e[32m"		#If color is supported, set to green.
		[ $(tput colors) -ge 16 ] && echo -n -e "\e[92m"	#If many colors are supported, set to bright green. 
		statement="[`date +%M:%S`] Success : ${*^}"
		echo "${statement::`tput cols`}"
		statement="${statement:`tput cols`}"
		while [ ${#statement} != 0 ] && [ `tput cols` -ge 18 ]; do
			echo "                  ${statement::$((`tput cols` - 18))}"
			statement="${statement:$((`tput cols` - 18))}"
		done
		[ $(tput colors) -ge 8 ] && echo -n -e "\e[0m"
	
	} || success() {
		echo "[`date +%M:%S`] Success: ${*}"
	}
	success "$*"
}

parametric_set(){ ## parametric_set <variable_name> <value> # Declare/set a variable by name string
	parametric_set_temp=$1
	shift
	eval "___${parametric_set_temp}=\"${*}\""
}

parametric_get(){ ## $(parametric_get <variable_name>)		# Function to access a variable by name string
	eval "parametric_get_temp=\$___${1}"
	echo "$parametric_get_temp"
}

random_between(){ ## random_between <min> <max>				# Returns a random number between min and max (inclusive) generated from /dev/urandom
	echo "$(( $(busybox tr -cd 0-9 </dev/urandom | busybox head -c 8) % ($2 - $1 + 1) + $1 ))"
}

###########################################   Function to set up environment   ########################################

prepare_setup(){

	initialized=

	header "CPU Frequency governor test script, running at`date +"%r %A %B %d %Y"`"

	type busybox &>/dev/null || install_busybox								#If busybox isn't installed, install it.
	
	setup_traps
	
}

install_busybox(){
	[ -e /data/busybox/busybox ] || failure "Busybox inaccesible"
	chmod 777 /data/busybox/busybox
	/data/busybox/busybox --install || failure "Busybox could not be installed"
	export PATH=/data/busybox:$PATH
}

setup_traps(){
	# for tarp in "SIGHUP:1 SIGINT:2 SIGQUIT:3 SIGTERM:15"; do
		# trap "" ${tarp%:*}
	# done
	trap handle_exit EXIT
}

handle_exit(){

	header "Cleaning up"
	
	reset_all_states
	
	type tput &>/dev/null && [ -t 2 ] && >&2 echo -n -e "\e[0m"
	type tput &>/dev/null && [ -t 1 ] && echo -n -e "\e[0m"
	
	echo "\nExiting..."
}

#############################################   Functions to decode input   ###########################################

parse_input(){

	last_option=''								#Holder for option parsing

	for option in "$@" ; do						#Go through each input and act on them
		option_assign "$option"
	done 
	
	process_input								#Check options for validity and set defaults
}

option_assign(){
	case $1 in
		[!-]*-?*)
			warning "Interpreting \"$1\" as \"${1%-*}\"+\"-${1#-*-}\""	#If we get multiple options stuck together
			option_assign "${1%-*}"										#Operate on all but the last
			option_assign "-${1##*-}"									#Then operate on the last
		;;
		-?*=)
			option_assign "${1%=}"										#Prune trailing equalses
		;;
		-?*=?*)															#If we get an equality
			option_assign "${1%%=*}"									#Operate on the first part
			option_assign "${1##*=}"									#Then operate on the second
		;;
		-?*)
			last_option="$1"											#Set last option in case of further assignments
			parametric_set "option_${1##*-}[0]"	"TRUE"					#Create variable
		;;
		'='|'-'|' '|'')												#Remove stray characters (and lack of characters)
			shift
		;;
		*)
			if [ -z "$last_option" ]; then								#If there hasn't been any options yet, interpret as option
				warning "Interpreting \"$1\" as -\"$1\""
				option_assign "-${1}"
			else														#Otherwise,
				if [ parametric_get "option_${last_option##*-}[0]" = "TRUE" ]; then #If the last option hasn't had any values yet
					parametric_set "option_${last_option##*-}[0]" "$1"				#Then set first element of the last option to this value
				else
					eval "___${parametric_set_temp}+=\"${1}\""						#Otherwise tack it on the end
				fi
			fi
		;;
	esac
}

process_input(){
	if [ "$(parametric_get "option_s")" = "TRUE" ] || [ "$(parametric_get "option_sched")" = "TRUE" ]; then
		comment "Sched is set"
	else
		comment "Sched is not set"
	fi
	
	if [ "$(parametric_get "option_t")" = "TRUE" ] || [ "$(parametric_get "option_test")" = "TRUE" ]; then
		comment "test is set but not passed"
	elif [ "$(parametric_get "option_t")" = "" ] && [ "$(parametric_get "option_test")" = "" ]; then
		comment "test is not set"
	elif [ "$(parametric_get "option_test")" = "" ]; then
		comment "test is $(parametric_get "option_t[@]")"
	else
		comment "test is $(parametric_get "option_test[@]")"
	fi
	
}

print_help(){

	echo "                                                                               "
	echo "Usage:                                                                         "
	echo "   sh ./cpufg_test.sh [options...]                                          "
	echo "                                                                               "
	echo "Options:                                                                       "
	echo "  -h          prints this message, then exits                                  "
	echo "                                                                               "
	echo "Notes:                                                                         "
	echo "  -Nothing so far...                                                           "
	echo "                                                                               "
}

###########################################   Functions to set up tests   #############################################

run_testing(){
	initialize
	test_1
	default_states
	test_2_1
	test_2_2
	default_states
	test_3_1
	test_3_2
	default_states
	test_4_1
	test_4_2
	test_4_3
	final_report
}

initialize(){
	header "Initializing..."
	
	big_index="$(get_state big_index)"
	comment "big_index = $big_index"
	lil_index="$(get_state lil_index)"
	comment "lil_index = $lil_index"
	cpu_index="$(get_state cpu_index)"
	comment "cpu_index = $cpu_index"
	
	get_all_states
	test_cores_on
	default_states
	
	initialized=1
}

test_1(){	#Get a list of available governers from each cluster, then check for Performance, UserSpace and Interactive
	header "Starting Test 1-1"

	fails_1_1=0
	
	local gov_available_big
	local gov_available_lil
	
	gov_available_big="$(get_cpu_state ${big_index} scaling_available_governors)"
	comment "Available governors for Big cluster: $gov_available_big"
	
	gov_available_lil="$(get_cpu_state ${lil_index} scaling_available_governors)"
	comment "Available governors for Little cluster: $gov_available_lil"
	
	if [ "${gov_available_big//performance}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Big cluster does not have Performance governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	if [ "${gov_available_big//userspace}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Big cluster does not have UserSpace governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	if [ "${gov_available_big//interactive}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Big cluster does not have Interactive governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	if [ "${gov_available_lil//performance}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Little cluster does not have Performance governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	if [ "${gov_available_lil//userspace}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Little cluster does not have UserSpace governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	if [ "${gov_available_lil//interactive}" = "${gov_available_big}" ]; then
		warning "(Test 1-1) Little cluster does not have Interactive governer available"
		fails_1_1=$(($fails_1_1 + 1 ))
	fi
	
	if [ "fails_1_1" -eq "0" ]; then
		success "(Test 1-1) Both clusters have Performance, UserSpace and Interactive governers available"
	else
		failure "(Test 1-1) $fails_1_1 failures total in Test 1-1"
	fi
}

test_2_1(){	#Set the cluster indexes' governer to performance, then check that all cores made the switch
	header "Starting Test 2-1"
	
	set_all_states_test governor performance
	fails_2_1=$fails
	
	if [ "fails_2_1" -eq "0" ]; then
		success "(Test 2-1) All cores set to performance governer"
	else
		failure "(Test 2-1) $fails_2_1 failures total in Test 2-1"
	fi
	
}

test_2_2(){	#Get a list of available frequencies from each cluster, randomly set them to max frequency and check that current frequency changed
	header "Starting Test 2-2"
	comment "Big cluster"
	set_match_test ${big_index} $default_2_2_passes scaling_max_freq scaling_cur_freq
	fails_2_2=$fails
	comment "Little cluster"
	set_match_test ${lil_index} $default_2_2_passes scaling_max_freq scaling_cur_freq
	fails_2_2=$(( $fails_2_2 + $fails ))
	
	if [ "$fails_2_2" -eq "0" ]; then
		success "(Test 2-2) All changes to scaling_max_freq were registered and matched by the core"
	else
		failure "(Test 2-2) $fails_2_2 failures total in Test 2-2"
	fi
}

test_3_1(){	#Set the cluster indexes' governer to userspace, then check that all cores made the switch
	header "Starting Test 3-1"
	
	set_all_states_test governor userspace
	fails_3_1=$fails
	
	if [ "fails_3_1" -eq "0" ]; then
		success "(Test 3-1) All cores set to userspace governer"
	else
		failure "(Test 3-1) $fails_3_1 failures total in Test 3-1"
	fi
}

test_3_2(){	#Get a list of available frequencies from each cluster, randomly set them to scaling_setspeed and check that current frequency changed
	header "Starting Test 3-2"
	
	comment "Big cluster"
	set_match_test ${big_index} ${default_3_2_passes} scaling_setspeed scaling_cur_freq
	fails_3_2=$fails
	
	comment "Little cluster"
	set_match_test ${lil_index} ${default_3_2_passes} scaling_setspeed scaling_cur_freq
	fails_3_2=$(( $fails_3_2 + $fails ))
	
	if [ "fails_3_2" -eq "0" ]; then
		success "(Test 3-2) All changes to scaling_setspeed were registered and matched by the core"
	else
		failure "(Test 3-2) $fails_3_2 failures total in Test 3-2"
	fi
}

test_4_1(){	#Set the cluster indexes' governer to interactive, then check that all cores made the switch
	header "Starting Test 4-1"
	
	set_all_states_test governor interactive
	fails_4_1=$fails
	
	if [ "fails_4_1" -eq "0" ]; then
		success "(Test 4-1) All cores set to interactive governer"
	else
		failure "(Test 4-1) $fails_4_1 failures total in Test 4-1"
	fi
}

test_4_2(){	#Get the minimum and maximum available frequencies from each cluster, then try to set min and max to random values outside of them
	header "Starting Test 4-2"
	
	comment "Big cluster"
	out_of_bounds_test ${big_index} ${default_4_2_passes}
	fails_4_2=$fails
	
	comment "Little cluster"
	out_of_bounds_test ${lil_index} ${default_4_2_passes}
	fails_4_2=$(( $fails_4_2 + $fails ))
	
	if [ "fails_4_2" -eq "0" ]; then
		success "(Test 4-2) All out-of-bounds attempts thwarted"
	else
		failure "(Test 4-2) $fails_4_2 failures total in Test 4-2"
	fi
}

test_4_3(){	#Try to set min to value greater than max, and vise versa. Pass if max > min
	header "Starting Test 4-3"
	
	comment "Big cluster"
	minmax_inversion_test ${big_index} ${default_4_3_passes}
	fails_4_3=$fails
	
	comment "Little cluster"
	minmax_inversion_test ${lil_index} ${default_4_3_passes}
	fails_4_3=$(( $fails_4_3 + $fails ))
	
	if [ "fails_4_3" -eq "0" ]; then
		success "(Test 4-3) All min/max inversion attempts thwarted"
	else
		failure "(Test 4-3) $fails_4_3 failures total in Test 4-3"
	fi
}

final_report(){
	header "Final Report"
	echo "              $fails_1_1 failures in 1-1"
	echo "              $fails_2_1 failures in 2-1"
	echo "              $fails_2_2 failures in 2-2"
	echo "              $fails_3_1 failures in 3-1"
	echo "              $fails_3_2 failures in 3-2"
	echo "              $fails_4_1 failures in 4-1"
	echo "              $fails_4_2 failures in 4-2"
	echo "              $fails_4_3 failures in 4-3"
}

##########################################   Functions to carry out tests   ###########################################

set_all_states_test(){ 			## set_all_states_test <state> <value> # Sets all cores' state to value, then checks that it succeeded
	fails=0
	set_cpu_state ${big_index} ${1} ${2}
	set_cpu_state ${lil_index} ${1} ${2}
	
	for i in "${core_list[@]}" ; do
		if [ "$(get_cpu_state ${i} ${1}])" != "${2}" ]; then
			warning "CPU ${i} ${1} is '$(get_cpu_state ${i} ${1}])', should be '${2}'"
			fails=$(($fails + 1 ))
		else
			comment "CPU${i} ${1} succesfully set to ${2}"
		fi		
	done
}

set_match_test(){				## set_match_test <cpu> <passes> <state_to_set> <state_to_test> #
	fails=0
	
	available_frequencies=()
	for freq in $(get_cpu_state ${1} scaling_available_frequencies); do	#Get a list of all available frequencies as reported by the core
		available_frequencies+=("$freq")
	done
	comment "Available frequencies : ${available_frequencies[@]}"
	i=0
	while [ $i -lt ${2} ]; do											#Then for however many passes specified
		j=${available_frequencies[$(( $RANDOM % ${#available_frequencies[@]} ))]}	#Pick one of those frequencies at random
		set_cpu_state ${1} ${3} $j													#Set the specified core node to that frequency
		sleep 0.02																	#And wait for one governer tick
		if [ $j -ne $(get_cpu_state ${1} ${3}) ]; then
			warning "${3} set to $(get_cpu_state ${1} ${3}), should be $j"					#If the setting didn't take,
			fails=$(($fails + 1 ))
		else
			if [ $j -ne $(get_cpu_state ${1} ${4}) ]; then								#Or the node specified to test didn't follow
				warning "${4} frequency set to $(get_cpu_state ${1} ${4}), should be $j"
				fails=$(($fails + 1 ))														#Count it as a failure
			else
				comment "${4} == ${3} == $j"												#Otherwise comment on the success
			fi
		fi
		i=$(($i + 1 ))																#And move on
	done
}

out_of_bounds_test(){			## out_of_bounds_test <cpu> <passes>	#Tests out of bound values for min/max freq
	fails=0
	
	local min
	local max
	available_frequencies=$(get_cpu_state $1 scaling_available_frequencies)
	available_frequencies=${available_frequencies% }
	min="${available_frequencies%% *}"
	max="${available_frequencies##* }"
	comment "Minimum/Maximum allowed frequencies: $min/$max"
	
	i=0
	while [ $i -lt ${2} ]; do
		j=$(( $RANDOM * 100 ))
		set_cpu_state $1 min $(($j % $min))
		if [ $(get_cpu_state $1 min) -lt $min ]; then
			warning "CPU$1 min set below allowed threshold ($min)"
			fails=$(($fails + 1 ))
		else
			comment "min set to $(get_cpu_state $1 min) (min)"
		fi
		set_cpu_state $1 max $(($max + $j))
		if [ $(get_cpu_state $1 max) -gt $max ]; then
			warning "CPU$1 max set above allowed threshold ($max)"
			fails=$(($fails + 1 ))
		else
			comment "max set to $(get_cpu_state $1 max) (max)"
		fi
		i=$(($i + 1 ))
	done
	set_cpu_state $1 min $min
	set_cpu_state $1 max $max
}

minmax_inversion_test(){		## minmax_inversion_test <cpu> <passes>	#Takes turns attempting to set max an min on opposite sides of eah other
	fails=0
	
	local min
	local max
	available_frequencies=$(get_cpu_state $1 scaling_available_frequencies)
	available_frequencies=${available_frequencies% }
	min="${available_frequencies%% *}"
	max="${available_frequencies##* }"
	comment "Minimum/Maximum allowed frequencies: $min/$max"
	
	i=0
	while [ $i -lt ${2} ]; do
		if [ $(( $i % 2 )) -eq 0 ]; then
			set_cpu_state $1 min "$(random_between $min $max)"
			set_cpu_state $1 max "$(random_between $min $(get_cpu_state $1 min))"
		else
			set_cpu_state $1 max "$(random_between $min $max)"
			set_cpu_state $1 min "$(random_between $(get_cpu_state $1 max) $max)"
		fi
		
		if [ $(get_cpu_state $1 min) -gt $(get_cpu_state $1 max) ]; then
			warning "CPU$1 minimum and maximum have crossed each other"
			fails=$(($fails + 1 ))
		else
			comment "min ($(get_cpu_state $1 min)) < max ($(get_cpu_state $1 max))"
		fi
		
		comment "resetting..."
		set_cpu_state $1 min $min
		set_cpu_state $1 max $max
		comment "reset"
		i=$(($i + 1 ))
	done
}

##########################################   Functions to perform operations  #########################################

get_state(){ 					## $(get_state [cpu_index/big_index/lil_index/<parameter>])	#returns the value of a parameter from the working path
	local temp
	case $1 in  
		cpu_index)
			temp="$(get_state possible)"
			temp="${temp##*-}"
			temp="${temp##*,}"
			echo "$temp"
		;;
		big_index)
			echo "$default_big_index"
		;;
		lil_index)
			echo "$default_lil_index"
		;;
		*)
			if [ -r "${working_path}/${1}" ]; then
				cat "${working_path}/${1}"
			else
				failure "Bad get_state() call: ${@}"
			fi
		;;
	esac
}

get_cpu_state(){ 				## $(get_cpu_state <cpu> <parameter>) #returns the value of a parameter in a cpu's path
	case $2 in                                    
		on*) # online
			cat "${working_path}/cpu${1}/online"
		;;
		mi*) # min
			cat "${working_path}/cpu${1}/cpufreq/scaling_min_freq"
		;;
		ma*) # max
			cat "${working_path}/cpu${1}/cpufreq/scaling_max_freq"
		;;
		to*) # top
			cat "${working_path}/cpu${1}/cpufreq/cpuinfo_max_freq"
		;;
		bo*) # bottom
			cat "${working_path}/cpu${1}/cpufreq/cpuinfo_min_freq"
		;;
		cu*) # current
			cat "${working_path}/cpu${1}/cpufreq/scaling_cur_freq"
		;;
		go*) # governer
			cat "${working_path}/cpu${1}/cpufreq/scaling_governor"
		;;
		*)
			if [ -r "${working_path}/cpu${1}/${2}" ]; then
				cat "${working_path}/cpu${1}/${2}"
			elif [ -r "${working_path}/cpu${1}/cpufreq/${2}" ]; then
				cat "${working_path}/cpu${1}/cpufreq/${2}"
			else
				failure "Bad get_cpu_state() call: ${@}"
			fi 
		;;
	esac
}

set_cpu_state(){ 				## set_cpu_state <cpu> [online/min/max/governor/<parameter>] <value>	#sets the value of a parameter in a cpu path
	case $2 in
		on*)
			comment "Setting cpu ${1} to $( [ $3 -eq 1 ] && echo 'ON' || echo 'OFF' )"
			echo "${3}" > "${working_path}/cpu${1}/online"
		;;
		mi*)
			comment "Setting cpu ${1} minimum frequency to ${3}"
			echo "${3}" > "${working_path}/cpu${1}/cpufreq/scaling_min_freq"
		;;
		ma*)
			comment "Setting cpu ${1} maximum frequency to ${3}"
			echo "${3}" > "${working_path}/cpu${1}/cpufreq/scaling_max_freq"
		;;
		go*)
			comment "Setting cpu ${1} governor to ${3}"
			echo "${3}" >  "${working_path}/cpu${1}/cpufreq/scaling_governor"
		;;
		*)
			if [ -w "${working_path}/cpu${1}/$2" ]; then
				comment "Setting cpu${1}/${2} to ${3}"
				echo "${3}" >  "${working_path}/cpu${1}/${2}"
			elif [ -w "${working_path}/cpu${1}/cpufreq/$2" ]; then
				comment "Setting cpu${1}/cpufreq/${2} to ${3}"
				echo "${3}" >  "${working_path}/cpu${1}/cpufreq/${2}"
			else
				failure "Bad set_cpu_state() call: ${@}"
			fi 
		;;
	esac
}

get_gov_state(){ 				## $(get_gov_state <cpu> <parameter>)						#returns the value of a parameter in a cpu's governer path
	if [ -r "${working_path}/cpu${1}/cpufreq/$(get_cpu_state ${1} governor)/${2}" ]; then
		cat  "${working_path}/cpu${1}/cpufreq/$(get_cpu_state ${1} governor)/${2}"
	else
		failure "Bad get_gov_state() call: ${@}"
	fi                               
}

set_gov_state(){ 				## set_gov_state <cpu> <parameter> <value>					#sets the value of a parameter in a cpu's governer path
	local core
	local parameter
	
	core=$1
	shift
	parameter=$1
	shift
	
	if [ -w "${working_path}/cpu${core}/cpufreq/$(get_cpu_state ${core} governor)/${parameter}" ]; then
		comment "Setting cpu ${core} governor's ${parameter} to ${@}"
		echo "${@}" >  "${working_path}/cpu${core}/cpufreq/$(get_cpu_state ${core} governor)/${parameter}"
	else
		failure "Bad set_gov_state() call: ${@}"
	fi                              
}

get_cpu_all(){ 					## $(get_cpu_all <cpu>)										#returns online, min, max, governor of given cpu
	echo "$(get_cpu_state ${1} online) $(get_cpu_state ${1} min) $(get_cpu_state ${1} max) $(get_cpu_state ${1} governor)"
}

set_cpu_all(){ 					## set_cpu_all <cpu> <online min max governor>				#sets online, min, max, governor of given cpu
	set_cpu_state ${1} online ${2}
	set_cpu_state ${1} min ${3}
	set_cpu_state ${1} max ${4}
	set_cpu_state ${1} governor ${5}
}	

default_states(){ 				## default_states 											#Sets all relevant values to testing defaults
	header "Setting cores to default state"

	for i in "${core_list[@]}" ; do
		set_cpu_all $i "1" "$(get_cpu_state ${i} "bottom")" "$(get_cpu_state ${i} "top")" "$default_governer"
	done
}

test_cores_on(){				## test_cores_on											#Tests all cpus and makes a list of which ones can be turned on
	comment "Testing cores..."
	core_list=()
	for i in `seq 0 $cpu_index` ; do	#Turn on all cores
		set_cpu_state ${i} online 1
	done
	for i in `seq 0 $cpu_index` ; do							
		if [ "$(get_cpu_state ${i} online)" -eq "1" ]; then
			core_list+=("${i}")
		fi
	done
	
	test_list="${core_list[@]}"
	if [ "${test_list//$big_index}" = "${test_list}" ] ; then
		failure "Big cluster index (CPU${big_index}) could not be turned on" 
		exit 1
	fi
	if [ "${test_list//$lil_index}" = "${test_list}" ] ; then
		failure "Little cluster index (CPU${lil_index}) could not be turned on"
		exit 1
	fi
	comment "${#core_list[@]} cores succesfully turned on: ${core_list[@]}"
}

get_all_states(){ 				## get_all_states 											#Takes a snapshot of the cpu frequency and governer modules
	comment "Reading states..."
	
	for i in `seq 0 $cpu_index` ; do							#For each core, set an initial value state variable
		parametric_set "cpu${i}_initial" "$(get_cpu_all ${i})"
	done

	get_all_governer_states ${big_index}
	get_all_governer_states ${lil_index}
}

get_all_governer_states(){ 		## get_all_states <cpu> 									#Takes a snapshot of the governer modules
	for file in ${working_path}/cpu${1}/cpufreq/$(get_cpu_state ${1} governor)/*	
	do																	#For each file under the governor of the core
		local_file=${file##*/}
		if [ -r $file ] && [ "${exceptions//,$local_file,}" = "${exceptions}" ]; then	#If it's readable & not blacklisted
			parametric_set "cpu${1}_initial_${local_file}" "$(get_gov_state ${1} ${local_file})" 	#Make a variable for it
			comment "cpu${1} ${local_file} = $(parametric_get "cpu${1}_initial_${local_file}")"		#And assign it
		fi
	done
}

reset_all_states(){ 			## reset_all_states 								#Return all values to initial state. Prior Get_all_states call needed
	if [ $initialized ]; then
		comment "Returning CPUs to initial state..."
		for i in `seq 0 $cpu_index` ; do							#For each core, restore the initial values
			set_cpu_all $i $(parametric_get "cpu${i}_initial")
		done
		reset_all_governer_states ${big_index}
		reset_all_governer_states ${lil_index}
	fi
}

reset_all_governer_states(){	## reset_all_states <cpu>							#Returns all governer values to what was set by get_all_governer_states
	if [ $initialized ]; then								
		for file in ${working_path}/cpu${1}/cpufreq/$(get_cpu_state ${1} governor)/*
		do
			local_file=${file##*/}
			if [ -w $file ] && [ "${exceptions//,$local_file,}" = "${exceptions}" ]; then	
				set_gov_state ${1} ${local_file} $(parametric_get "cpu${1}_initial_${local_file}")
			fi
		done #For each file under the governor of the indices that isn't blacklisted, set it to initial of that value
	fi
}





main "$@" ##########################################  End Of Script  ###################################################
