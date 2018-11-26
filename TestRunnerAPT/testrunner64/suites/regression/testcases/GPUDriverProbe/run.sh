#!/system/bin/bash

export TOOLS='/data/local/tmp/testrunner/common'
nodefile="/dev/kgsl-3d0"

count=0
if [ -e $nodefile ]; then 
    content=$(cat $nodefile)
    if [ `echo $content|$TOOLS/busybox grep -c "OH HAI GPU"` -eq "1" ];then
        count=$((count+1))
    else
        echo $content > output.txt
        echo "GPU Driver Probe:Fail(content mismatch)" | $TOOLS/busybox tee console.txt
        exit 1
    fi
else
    echo "GPU Driver Probe:Fail(file not found)" | $TOOLS/busybox tee console.txt
    exit 1
fi
if [ $count -gt 0 ];then
    echo "GPU Driver Probe:Success"
    exit 0
fi

