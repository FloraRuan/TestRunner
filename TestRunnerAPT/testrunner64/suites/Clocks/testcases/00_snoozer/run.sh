#!/system/bin/sh
source ../../../../init_env

export TIMESCALE=60
if [ "$CPUS" == "" ]
then
	export CPUS=`ls /sys/devices/system/cpu/ |grep -E 'cpu[0-9]+'`
fi

#Pick random src from SRC
Filepath=("/data/local/tmp/snoozer.txt" "/sdcard/snoozer.txt")
SRC=("/dev/random" "/dev/urandom" "/dev/zero")
BYTES=("128" "64" "32")
CONV=("notrunc" "noerror" "sync" "fsync")
RANDOMSRC=${SRC[$RANDOM % ${#SRC[@]} ]}

# How many kilobytes free space do we have?
check_free()
{
    sync
    dataval=`echo $RANDOMSRC | busybox grep -c "/data"`
    if [ $dataval -eq 1 ]
    then
        busybox df /data | busybox tail -1 | busybox awk '{print $4}'
    else
        busybox df /data | busybox tail -1 | busybox awk '{print $4}'
    fi
}

Value=$((`check_free`-(1024)))

randomdata()
{
	#Pick random path from Filepath
	RANDOMFILE=${Filepath[$RANDOM % ${#Filepath[@]} ]}

	## Pick random src from SRC
	# RANDOMSRC=${SRC[$RANDOM % ${#SRC[@]} ]}

	#Pick random bytes from BYTES
	RANDOMBYTES=${BYTES[$RANDOM % ${#BYTES[@]} ]}

	#Pick random conv from CONV
	RANDOMCONV=${CONV[$RANDOM % ${#CONV[@]} ]}

	busybox dd if=$RANDOMSRC of=$RANDOMFILE bs=$RANDOMBYTES conv=$RANDOMCONV seek=$Value&
}

scale()
{
	echo `busybox expr $1 \\* $TIMESCALE`
}

for c in $CPUS
	do
		param+=" [${c//[!0-9]/},0]"
		cpucount=$(( cpucount + 1 ))
	done
randomdata
PID=$!
./snoozer.sh -c -t=`scale 1` -n=1 [1,650]
./snoozer.sh -c -t=`scale 2` -n=8 [0,650] [1,650] [2,650] [3,650] [4,650] [5,650] [6,650] [7,650]
./snoozer.sh -c -t=`scale 2` -n=8 [0,150] [1,250] [2,350] [3,450] [4,550] [5,650] [6,750] [7,850]
./snoozer.sh -c -r -l=100 -h=500 -t=`scale 1` -n=1 [0,0] [3,0]
./snoozer.sh -c -r -l=10 -h=5000 -t=`scale 1` -n=8 [0,0] [1,0] [2,0] [3,0] [4,0] [5,0] [6,0] [7,0]
./snoozer.sh -c -r -t=`scale 1` -n=8 [0,0] [1,0] [2,0] [3,0] [4,0] [5,0] [6,0] [7,0]
./snoozer.sh -t=`scale 1` -gx -v -m -b -n=$cpucount -t=`scale 1` $param
./snoozer.sh -t=`scale 4` -gc -gx -m -v -v0 -v1 -v2 -n=$cpucount -t=`scale 1` $param
./snoozer.sh -t=`scale 2` -v1 -c -n=1 [3,100]
./snoozer.sh -t=`scale 4` -gc -gx -m -v -v0 -v1 -v2 -c -r -n=8 [0,0] [1,0] [2,0] [3,0] [4,0] [5,0] [6,0] [7,0]
./snoozer.sh -c -v1 -b -n=$cpucount -t=`scale 1` $param
./snoozer.sh -v2 -c -b -n=$cpucount -t=`scale 2` $param
./snoozer.sh -v0 -b -c -n=$cpucount -t=`scale 1` $param
./snoozer.sh -c -m -b -n=$cpucount -t=`scale 3` $param
./snoozer.sh -c -gc -b -n=$cpucount -t=`scale 2` $param
./snoozer.sh -c -gx -b -n=$cpucount -t=`scale 1` $param
./snoozer.sh -c -v -m -b -n=$cpucount -t=`scale 2` $param
./snoozer.sh -c -gc -v -m -b -n=$cpucount -t=`scale 4` $param
./snoozer.sh -c -gc -gx -v -m -b -n=$cpucount -t=`scale 1` $param
./snoozer.sh -c -m -v1 -v2 -n=$cpucount -t=`scale 1` $param
./snoozer.sh -c -r -b -n=$cpucount -t=`scale 2` $param
if [ -e /proc/$PID ]
# if ps -p $PID > /dev/null
then
   echo "$PID is running"
   kill -9 $PID
fi
if [ -e ${Filepath[0]} ] || [ -e ${Filepath[0]} ] ; then
   echo "removing snoozer.txt file"
   rm -f ${Filepath[0]} ${Filepath[1]}
   exit 0
fi
