#!/system/bin/bash
GOVERNOR=userspace
# set userspace governor
function set_governor()
{
  for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  do echo $GOVERNOR > $file
  done
  sleep 1
}
# set lowest frequency everywhere
function set_lowest_freq()
{
  for cpufreq in /sys/devices/system/cpu/cpu*/cpufreq
  do cat $cpufreq/scaling_min_freq > $cpufreq/scaling_setspeed
  done
}

# now cycle each CPU in turn and see the effect on others
function cycle_all_cpus()
{
  for cpu in /sys/devices/system/cpu/cpu*/
  do if [ -f $cpu/cpufreq/cpuinfo_cur_freq ]
     then orig_freq=$(cat $cpu/cpufreq/cpuinfo_cur_freq)
          for freq in $(cat $cpu/cpufreq/scaling_available_frequencies)
          do echo $freq > $cpu/cpufreq/scaling_setspeed
            usleep 500000
            echo -ne "$(basename $cpu)=$freq:"
            dump_current_cpu_freqs
          done
          echo $orig_freq > $cpu/cpufreq/scaling_setspeed
     fi
  done
}

function dump_current_cpu_freqs()
{
  for file in /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
  do echo -ne "\t$(cat $file)"
  done
  echo
}

set_governor
set_lowest_freq
cycle_all_cpus
if [ "$?" -eq "0" ]; then
    echo "Test cpufreqvsclusterfreq: Success"
    exit 0
else
    echo "Test cpufreqvsclusterfreq: Failure"
    exit 1
fi