#!/system/bin/sh
#Note ADB.exe has to be Latest
#Current env is @/data/local/tmp/testrunner
DST="/data/local/tmp/testrunner"

#Root the device only if it is not 
root(){
  deviceid=$1
  USER=`adb -s $deviceid wait-for-device shell whoami| tr -d '[[:space:]]'`
  if [ $USER == "shell" ] ; then
    adb -s $deviceid wait-for-device root
    if [ $? -eq 0 ] ; then
        echo "Root invoked"
    else
        echo "unable to invoke Root access"
    fi
  else
    echo "Already device has root privilege"
  fi
}

#compare version
vercomp() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i v1=($1) v2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#v1[@]}; i<${#v2[@]}; i++))
    do
        v1[i]=0
    done
    for ((i=0; i<${#v1[@]}; i++))
    do
        if [[ -z ${v2[i]} ]]
        then
            # fill empty fields in v2 with zeros
            v2[i]=0
        fi
        if ((10#${v1[i]} > 10#${v2[i]}))
        then
            return 1
        fi
        if ((10#${v1[i]} < 10#${v2[i]}))
        then
            return 2
        fi
    done
    return 0
}

#Remount the device only if it is not 
remount(){
  deviceid=$1
  CHK=`adb -s $deviceid wait-for-device shell mount |grep "/system" |grep -c "ro"`
  if [ $CHK -eq 1 ] ; then
    version=`adb version|awk {'print $5'}` 
    req_ver=1.0.32
    vercomp $req_ver $version
    if [[ $? -eq 0 || $? -gt 1 ]]; then
        # VERITY=`adb disable-verity 2>&1|grep -c "verity disabled"`
        OUTPUT=`adb -s $deviceid disable-verity |grep -c "Verity already disabled"`
        if [ $OUTPUT -eq 0 ]; then
            adb -s $deviceid wait-for-device reboot
            root $deviceid
        fi
        CMD=`adb -s $deviceid wait-for-device remount 2>&1|grep -c "succeed"`
        if [ $CMD -gt 0 ] ; then
            echo "Remount successfully"
        else
            echo "unable to remount the device"
            exit
        fi
    else
        echo "adb version must be greater or equal to 1.0.32"
        exit
    fi
  else
  
    echo "Already system partition has rw permission"
  fi
}

resetDir(){
  local ARCH=`adb -s $deviceid shell "uname -a|grep -c \"aarch64\""| tr -d '[[:space:]]'`
  if [ $ARCH -eq 1 ] ; then
    src=testrunner64
  else
    src=testrunner
  fi
  DST="/data/local/tmp/testrunner"
}

#Pushing the content 
push(){
  deviceid=$1
  local src
  local ARCH=`adb -s $deviceid shell "uname -a|grep -c \"aarch64\""| tr -d '[[:space:]]'`
  if [ $ARCH -eq 1 ] ; then
    src=testrunner64
  else
    src=testrunner
  fi
  if [ -n "$SUITE" ] ; then
    src+="/common"
	DST+="/common"
    adb -s $deviceid push $src $DST
	resetDir
    src+="/suites/$SUITE"
	DST+="/suites/$SUITE"
	adb -s $deviceid push $src $DST
	resetDir
	src+="/init_env"
	adb -s $deviceid push $src $DST
	resetDir
	src+="/testrunner"
	adb -s $deviceid push $src $DST
	resetDir
	src+="/suites.txt"
	adb -s $deviceid push $src $DST	
	else
		adb -s $deviceid push $src $DST 
  fi
  if [ $? -eq 0 ] ; then
    echo "Success"
  else
    echo "Fail"
  fi
  resetDir
  adb -s $deviceid push $src/common/busybox /system/bin
}

#Enabling all the prerequite setttings
execute(){
  deviceid=$1
  export IFS=","
  CMDS="cd /data/local/tmp;chmod -R 777 testrunner,cd /data/local/tmp/testrunner;./init_env,cd /system/bin;busybox ln -s busybox zcat,cd /system/bin;busybox ln -s busybox awk,cd /system/bin;busybox ln -s busybox sed,cd /system/bin;busybox ln -s busybox dd,cd /system/bin;busybox ln -s busybox chattr,cd /system/bin;busybox ln -s busybox seq,cd /system/bin;busybox ln -s busybox diff,cd /system/bin;busybox ln -s busybox hexdump"
  for each_cmd in ${CMDS}:
  do 
    adb -s $deviceid wait-for-device shell ${each_cmd}
  done
  if [ $? -eq 0 ] ; then
    echo "Success"
  else
    echo "Fail"
  fi
}

presetup(){
#Handles multiple devices
adb devices | while read line
do
    if [ ! "$line" = "" ] && [ `echo $line | awk '{print $2}'` = "device" ]
    then
        deviceid=`echo $line | awk '{print $1}'`
        echo "Picking up device : $deviceid "
        root $deviceid
        remount $deviceid
        push $deviceid
        execute $deviceid
    fi
done
}

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -s|--suite)
    SUITE="$2"
    shift
    ;;
    -t|--TEST)
    TEST="$2"
    shift
    ;;
    *)

    ;;
esac
shift 
done

if [ -n "$SUITE" ] ; then
	echo SUITE = "${SUITE}"
fi
if [ -n "$TEST" ] ; then
	echo TEST = "${TEST}"
fi

presetup
