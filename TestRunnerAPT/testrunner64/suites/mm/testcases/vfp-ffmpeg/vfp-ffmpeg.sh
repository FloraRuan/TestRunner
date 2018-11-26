#!/system/bin/bash
export TOOLS="/data/local/tmp/testrunner/common"

if [ -z "$1" ]; then
    echo "Usage: $0 <Inputfile (ogg)> [iterations]"
    exit 1
fi

echo
echo "*** vfp ffmpeg Test ***"

if [ ! -e "$1" ]; then
    echo "File $1 does not exist!"
    exit 1
fi

if [ -n "$2" ]; then
    if [ $(echo "$2" | grep -E "^[0-9]+$") ]; then
        iterations=$2
    else
        echo "<iterations> must be a valid number; setting it to 1"
        iterations=1
    fi
else
    iterations=1
fi
# set Location for tmp files 
if [ -z "$LOC" ]; then
    if [ -r /data/local/tmp ]; then
        LOC=/data/local/tmp;
    fi
fi

FILE_NAME="output_file"
ERR_CODE=0

i=1
while test  $i -lt $((iterations+1))  ; do
    echo
    echo "Iteration $i/$iterations:"

    $TOOLS/ffmpeg -i $1 -map 0 $LOC/$FILE_NAME"_"$i.wav > /dev/null 2>&1
    ERR_CODE=$?
    if [ $ERR_CODE -ne 0 ]; then
        echo "ffmpeg not able to create FILE_NAME_$i.wav"
        echo "vfp ffmpeg failed. Abort!!"
        exit 1
    fi

    i=$((i+1))
done

i=1
while test  $i -lt $((iterations+1))  ; do
    echo
    MD5SUM_CHECK=`md5sum $LOC/$FILE_NAME"_"$i.wav | cut -f 1 -d ' '`
    if [ -n $MD5SUM_CHECK ]; then
        if [ $i = 1 ]; then
            TEMP_CHECK=$MD5SUM_CHECK
            echo "vfp ffmpeg test: $MD5SUM_CHECK: PASS"
        elif [ $TEMP_CHECK = $MD5SUM_CHECK ]; then
            TEMP_CHECK=$MD5SUM_CHECK
            echo "vfp ffmpeg test: $MD5SUM_CHECK: PASS"
        else
            echo "vfp ffmpeg test: $MD5SUM_CHECK: FAIL"
            exit 1
        fi
    else
        echo "md5sum not found $LOC/$FILE_NAME"_"$i.wav"
        echo "vfp ffmpeg test: $MD5SUM_CHECK: FAIL"
        exit 1
    fi

    i=$((i+1))
done

i=1
while test  $i -lt $((iterations+1))  ; do
    rm $LOC/$FILE_NAME"_"$i.wav
    i=$((i+1))
done

echo
echo "*** vfp ffmpeg Test completed successfully ***"
exit 0
