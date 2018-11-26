DOCUMENTATION FOR SNOOZER WITH LOAD:

Usage: ./snoozer.sh -b -r -c [OPTIONS]

Parameters are similar to Random Snoozer, except that the "-b" option is passed in, which tells the shell script to run it with load. 
The snoozer shell script will call the cpu_lpm C executable, 
which runs this command: ./timerun $random_time ./shuffle 0 100000 ./cacheblast 50000 1000000 $low $high. 
Random time is the amount of time the iteration will run, low is by default 10 us and high is 10000 us.

More details at go/snoozer 

Example usage:

./snoozer.sh -c -r -b -t=10 [0,0] [1,0] [2,0] [3,0] [4,0] [5,0] 

./snoozer.sh -c -r -b -t=60 –l=2000 –h=2500 –s=7888 [0,0] [1,0] [2,0] [3,0] [4,0] [5,0]