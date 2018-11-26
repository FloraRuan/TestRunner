#!/system/bin/bash
#Set the date to somewhere in future 
busybox date -u 061011002016.00
nodefile="nodes.log"
# Import test suite definitions
export TOOLS='/data/local/tmp/testrunner/common'
timestamp=$( date +"%Y-%m-%d %T.%s")

mkdir tmp
cd tmp
export IFS="
"
for entry in $(cat $TOOLS/supported_nodes)
do
    node=$(echo $entry | $TOOLS/busybox tr -d '\r')
    echo "node => $node"
    $TOOLS/timerun 90 $TOOLS/trinity -c ioctl -C 1 --dangerous -V $node > /dev/null 2>&1
done
cd ..
rm -rf tmp/
unset IFS
echo "Test Success."
exit 0
