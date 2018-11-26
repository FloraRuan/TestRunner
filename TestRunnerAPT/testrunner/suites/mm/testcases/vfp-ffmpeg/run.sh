#!/system/bin/bash

./vfp-ffmpeg.sh inputfiles/big_buck_bunny_VORBIS_2Channel_48k_128K_short.OGG
if [ "$?" -eq "0" ]; then
    echo "Test vfp-ffmpeg: Success"
    exit 0
else
    echo "Test vfp-ffmpeg: Failure"
    exit 1
fi
