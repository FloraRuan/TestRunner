#!/system/bin/sh

grep -v event_control |\
grep -v "/sys/fs/selinux/member" |\
grep -v "/sys/fs/selinux/user" |\
grep -v "/sys/fs/selinux/relabel" |\
grep -v "/sys/fs/selinux/create" |\
grep -v "/sys/fs/selinux/access" |\
grep -v "/sys/fs/selinux/context" 

