#!/system/bin/bash
#Set the date to somewhere in future 
busybox date -u 061011002016.00
nodefile="nodes.log"
# Import test suite definitions
source ../../../../init_env
timestamp=$( date +"%Y-%m-%d %T.%s")

function not_exclude()
{
    for x in $($TOOLS/busybox cat $TOOLS/blacklist_nodes)
    do
        node=$(echo $x | $TOOLS/busybox tr -d '\r')
        if [ $node == $1 ]
        then
            return 1
        fi
    done
    return 0
}

function del()
{
    if [ -f $nodefile ]; then 
        rm -rf $nodefile
    fi
}
del

for entry in "/dev"/*
do
    if not_exclude $entry && [ ! -d $entry ]; then 
       echo $timestamp $entry >> $nodefile
       $TOOLS/timerun 20 $TOOLS/busybox cat $entry > /dev/null 2>&1
    fi
done
echo "Test Success."
del
exit 0
