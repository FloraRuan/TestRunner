#!/system/bin/sh
# Import test suite definitions
source ../../../../init_env
#import test functions library
source $TOOLS/functestlib.sh
TOUCH_FOLDER=/system/app/
DATA=$TOUCH_FOLDER/SWEBrowser/SWEBrowser.apk
LOGS=/data/local/tmp
# Opens every file provided on the command line and maps it into virtual memory with mmap2
#How much of testrunner framework is currently in memory?
function vmtouch {
$TOOLS/vmtouch -v $TOUCH_FOLDER > $LOGS/touch_default.txt 2>&1
pages_in_memory=$(cat $LOGS/touch_default.txt | grep Resident | awk '{print $3}' | awk -F '[ /]' '{print $1}')
echo "Total number of pages $pages_in_memory"
total_pages=$(cat $LOGS/touch_default.txt | grep Resident | awk '{print $3}' | awk -F '[ /]' '{print $2}')
echo "Total pages in file $total_pages"
current_tocuhed_memory=$(cat $LOGS/touch_default.txt | grep Resident | awk '{print $4}' | awk -F '[ /]' '{print $2}')
echo "Amount of memory currently touched $current_tocuhed_memory"
total_sizeof_file=$(cat $LOGS/touch_default.txt | grep Resident | awk '{print $4}' | awk -F '[ /]' '{print $2}')
echo "Total size of file $total_sizeof_file"
time_elapsed=$(cat $LOGS/touch_default.txt | grep Elapsed | awk '{print $2}')
echo "Time elapsed is $time_elapsed"

# Let's touch all pages into memory 
$TOOLS/vmtouch -vt $TOUCH_FOLDER > $LOGS/touch_all.txt 2>&1
touched_pages1=$(cat $LOGS/touch_all.txt | grep Touched | awk '{print $3}')
current_tocuhed_memory=$(cat $LOGS/touch_all.txt | grep Touched  | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/touch_all.txt | grep Elapsed | awk '{print $2}')

if [ $touched_pages1 -eq $total_pages ]; then
	echo "Touched all pages into memory"
else
	echo "Not touched all pages in memory"
	echo "Test failed"
	exit 0
fi	

# Evict the mapped pages from the file system cache
# They will need to be read in from disk the next time they are accessed.

$TOOLS/vmtouch -ve $TOUCH_FOLDER > $LOGS/evict_pages.txt 2>&1
pid=$!
evicted_pages1=$(cat $LOGS/evict_pages.txt | grep Evicted | awk '{print $3}')
current__tocuhed_memory=$(cat $LOGS/evict_pages.txt | grep Evicted | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/evict_pages.txt | grep Elapsed | awk '{print $2}')
if [ $evicted_pages1 -eq $total_pages ]; then
	echo "Evicted all pages in memory"
else
	echo "Left few pages in memory"
	echo "Test failed"
	kill -9 $pid
	exit 0
fi	
# Maximum file size mentioned with "-m"  to map into virtual memory
$TOOLS/vmtouch -vt -m 2M $TOUCH_FOLDER > $LOGS/touch_max_filesize.txt 2>&1
touched_pages2=$(cat $LOGS/touch_max_filesize.txt | grep Touched | awk '{print $3}')
current__tocuhed_memory=$(cat $LOGS/touch_max_filesize.txt | grep Touched  | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/touch_max_filesize.txt | grep Elapsed | awk '{print $2}')

# Maximum file size mentioned with "-m"  to map into virtual memory
$TOOLS/vmtouch -ve -m 2M $TOUCH_FOLDER > $LOGS/touch_max_filesize.txt 2>&1
evicted_pages2=$(cat $LOGS/touch_max_filesize.txt | grep Evicted | awk '{print $3}')
current__tocuhed_memory=$(cat $LOGS/touch_max_filesize.txt | grep Evicted | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/touch_max_filesize.txt | grep Elapsed | awk '{print $2}')
if [ $touched_pages2 == $evicted_pages2 ]; then
	echo "Touched pages $touched_pages2"
	echo "Evicted pages $evicted_pages2"
	echo "The pages which are tocuhed and evicted back same pages"
else
	echo "Test failed"
fi

#Maps the portion of the file specified by a range instead of the entire file
$TOOLS/vmtouch -vt -p 2K-1M $TOUCH_FOLDER > $LOGS/touch_range.txt 2>&1
touched_pages3=$(cat $LOGS/touch_range.txt | grep Touched | awk '{print $3}')
current__tocuhed_memory=$(cat $LOGS/touch_range.txt | grep Touched  | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/touch_range.txt | grep Elapsed | awk '{print $2}')

#Evict the portion of the file specified by a range instead of the entire file
$TOOLS/vmtouch -ve -p 2K-1M $TOUCH_FOLDER >  $LOGS/evict_range.txt 2>&1
evicted_pages3=$(cat $LOGS/evict_range.txt | grep Evicted  | awk '{print $3}')
current__tocuhed_memory=$(cat $LOGS/evict_range.txt | grep Evicted  | awk '{print $4}' | cut -d "(" -f2 | cut -d ")" -f1)
time_elapsed=$(cat $LOGS/evict_range.txt | grep Elapsed | awk '{print $2}')
if [ $touched_pages3 == $evicted_pages3 ]; then
	echo "Touched pages $touched_pages3"
	echo "Evicted pages $evicted_pages3"
	echo "The pages which are tocuhed and evicted back same pages with range of sizes mentioned"
else
	echo "Test failed"
fi

#Lock pages in physical Memory with mlock()
$TOOLS/vmtouch -dl $TOUCH_FOLDER
#lock physical memory pages for 2 min
sleep 120
pid1=$(ps | grep vmtouch | awk '{print $2}')
echo $pid1
echo "Pages are locked in Physical memory with mlock()"
kill -9 $pid1
#Lock pages in physical Memory with mlockall()
$TOOLS/vmtouch -dL $TOUCH_FOLDER
#lock physical memory pages for 2 min
sleep 120
pid2=$(ps | grep vmtouch | awk '{print $2}')
echo $pid2
echo "Pages are locked in Physical memory with mlockall()"
kill -9 $pid2
}
function cachetouch
{
	echo "Starting CacheTouch Testcase....."
# Cachemaster is similar to VMTOUCH, but with more functions. 
# Such as kick page cache, warmup/readahead data, lock data in mem, 
# stat page cache, stat page cache in realtime mode, by file or directory

echo "stat page cache of file"
$TOOLS/cachemaster -s -f $DATA >  $LOGS/cache_file.txt 2>&1
size_of_file=$(cat $LOGS/cache_file.txt | tail -n 1 | awk '{print $2}' | sed 's/.*://' | cut -d "M" -f1 )
echo $size_of_file

echo "Stat page cache of directory"
$TOOLS/cachemaster -s -d $TOUCH_FOLDER  >  $LOGS/cache_directory.txt 2>&1
size_of_folder=$(cat $LOGS/cache_directory.txt | tail -n 1 | awk '{print $5}' | sed 's/.*://' | cut -d "M" -f1 )
current_cache_size=$(cat $LOGS/cache_directory.txt | tail -n 1 | awk '{print $6}' | sed 's/.*://' | cut -d "M" -f1 )
echo $size_of_folder
echo $current_cache_size

echo "Kick page cache of file"								# Clear cache of a file
$TOOLS/cachemaster -s -f $DATA
$TOOLS/cachemaster -c -f $DATA
$TOOLS/cachemaster -s -f $DATA  >  $LOGS/cache_file.txt 2>&1
current_cache_size=$(cat $LOGS/cache_file.txt | tail -n 1 | awk '{print $3}' | sed 's/.*://' | cut -d "B" -f1 )
if [ $current_cache_size -eq 0 ]; then
	echo "File cache kicked"
else
	echo "Cache clear failed"
	echo "Test failed"
	exit 0
fi	

echo "Kick page cache of directory"
$TOOLS/cachemaster -s -d $TOUCH_FOLDER
$TOOLS/cachemaster -c -d $TOUCH_FOLDER  									# Clear cache of a direcroty
$TOOLS/cachemaster -s -d $TOUCH_FOLDER  >  $LOGS/cache_directory.txt 2>&1	# Stat cache of a direcroty
current_cache_size=$(cat $LOGS/cache_directory.txt | tail -n 1 | awk '{print $6}' | sed 's/.*://' | cut -d "M" -f1 )
ratio=$(($current_cache_size/$size_of_folder * 100))
if [ $ratio -le 5 ]; then
	echo "Directory cache kicked"
else
	echo "Cache clear failed"
	echo "Test failed"
	exit 0
fi
echo "Lock in mem of file"
$TOOLS/cachemaster -l -f $DATA &        					# Lock file
pid1=$!
sleep 10
kill -9 $pid1
$TOOLS/cachemaster -s -f $DATA  >  $LOGS/cache_file.txt 2>&1
current_cache_size=$(cat $LOGS/cache_file.txt | tail -n 1 | awk '{print $3}' | sed 's/.*://' | cut -d "M" -f1 )
if [ $current_cache_size -eq $size_of_file ]; then
	echo "File cache locked in Memory"
else
	echo "Locking file cache failed"
	echo "Test failed"
	exit 0
fi

echo "Lock in mem of directory"
$TOOLS/cachemaster -l -d $TOUCH_FOLDER &					# Lock direcroty
pid2=$!
sleep 10
kill -9 $pid2
$TOOLS/cachemaster -s -d $TOUCH_FOLDER > $LOGS/cache_directory.txt 2>&1
current_cache_size=$(cat $LOGS/cache_directory.txt | tail -n 1 | awk '{print $6}' | sed 's/.*://' | cut -d "M" -f1 )
if [ $current_cache_size -eq $size_of_folder ]; then
	echo "Directory cache locked in Memory"
else
	echo "Locking Directory cache failed"
	echo "Test failed"
	exit 0
fi

echo "Warmup/Readahead of file"
$TOOLS/cachemaster -c -f $DATA															# Clear cache of a file
$TOOLS/cachemaster -s -f $DATA	>  $LOGS/cache_file.txt 2>&1							# Stat cache of a file
$TOOLS/cachemaster -w -f $DATA															# Warmup file
$TOOLS/cachemaster -s -f $DATA	>  $LOGS/cache_file.txt 2>&1							# Warmup direcroty
warmup_cache_size=$(cat $LOGS/cache_file.txt | tail -n 1 | awk '{print $3}' | sed 's/.*://')
echo "File warmup done and size is $warmup_cache_size"

echo "Warmup/Readahead of directory"
$TOOLS/cachemaster -c -f $TOUCH_FOLDER
$TOOLS/cachemaster -s -d $TOUCH_FOLDER > $LOGS/cache_directory.txt 2>&1
$TOOLS/cachemaster -w -d $TOUCH_FOLDER
$TOOLS/cachemaster -s -d $TOUCH_FOLDER > $LOGS/cache_directory.txt 2>&1
warmup_cache_size=$(cat $LOGS/cache_directory.txt | tail -n 1 | awk '{print $6}' | sed 's/.*://')
echo "Directory warmup done and size is $warmup_cache_size"
}
echo "Execute cachetouch and vmtouch"
cachetouch
if [ $? -eq 0 ]; then
	echo "CacheTouch Test Passed"
else
	echo "CacheTouch Test Failed"
fi	
echo "Start VMTouch"
vmtouch
if [ $? -eq 0 ]; then
	echo "VMTouch Test Passed"
else
	echo "VMTouch Test Failed"
fi	
echo "Overall Test Passed"