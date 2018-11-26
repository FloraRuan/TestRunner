#!/system/bin/sh
#
ARCH=$(uname -m |egrep -c "(aarch64|arm)")
if [ $ARCH -ge 1 ];then
	COUNT=$(for i in `seq 1 1000` ; do grep stack /proc/self/maps; done  | sort -u | uniq -c | wc -l)
else
	exit 3
fi


if [ $COUNT -lt 950 ]; then
	echo "Stack randomness changes < 95% of the time ($COUNT)"
	exit -1
else
	echo "Stack randomness changes of the time ($COUNT)"
	exit 0
fi
